(* Reify policy for stealing as a type *)
type steal_policy =
  | Random
  | RoundRobin

(* A task is just executing a function for now (unit-> unit *)
(* A later refinement does two things to redefine a task:
    - a task takes a context (ctx) and returns a unit (* explained below *)
    - wraps the task in a Task type
    *)
and task = Task of (ctx -> unit)

(* The abstract type ctx is now defined as a type with
   - the current domain/worker id
   - the pool containing of all deques
   *)
and ctx = {
    pool      : deque_pool;
    worker_id : int;
    rng       : Random.State.t;
    steal_policy : steal_policy
}

(* A deque_pool is a type containing:
   - an array of deques, one for each domain into which tasks are
     put into and stolen from across domains.
   - size denotes the number of total domains
   - pending denotes the counter of unfinished tasks; incremented
     every time a task is added to a deque and decremented when
     a task finishes running
   *)
and deque_pool = {
    deques  : task Deque.t array;
    pending : int Atomic.t;
    size    : int;          (* number of domains *)
    next_worker : int Atomic.t;
    steal_count : int Atomic.t;
    task_count : int Atomic.t;  (* the total number of tasks completed *)
    steal_policy : steal_policy
}

let make_ctx pool worker_id = {
    pool = pool ;
    worker_id = worker_id;
    rng       = Random.State.make_self_init ();
    steal_policy = pool.steal_policy
}

let create_pool n policy = {
    deques = Array.init n (fun _ -> Deque.create 10);
    pending = Atomic.make 0;
    size    = n;
    next_worker = Atomic.make 0;
    steal_count = Atomic.make 0;
    task_count  = Atomic.make 0;
    steal_policy = policy
 }

let run_task (Task tsk) ctx = tsk ctx

let try_steal_from ctx victim =
 (* once another victim domain is determined *)
  match Deque.steal ctx.pool.deques.(victim) with
  | Deque.Value task ->
      Atomic.fetch_and_add ctx.pool.steal_count 1 |> ignore;
      run_task task ctx;
      Atomic.decr ctx.pool.pending;
      Atomic.incr ctx.pool.task_count
  | Deque.Empty | Deque.Abort -> ()


(* Updated: stealing across domains now occurs according to the policy set *)
let try_steal ctx =
  match ctx.steal_policy with
  | Random ->
      let victim = ref (Random.State.int ctx.rng ctx.pool.size) in
      while !victim = ctx.worker_id do
        (* ensure tasks are stolen from other domains *)
        victim := Random.State.int ctx.rng ctx.pool.size
      done;
      try_steal_from ctx !victim
  | RoundRobin ->
      let stolen = ref false in
      let i = ref 1 in
      while not !stolen && !i < ctx.pool.size do
        let victim = (ctx.worker_id + !i) mod ctx.pool.size in
        (match Deque.steal ctx.pool.deques.(victim) with
        | Deque.Value task ->
            Atomic.fetch_and_add ctx.pool.steal_count 1 |> ignore;
            run_task task ctx;
            Atomic.decr ctx.pool.pending;
            Atomic.incr ctx.pool.task_count;
            stolen := true
        | Deque.Empty | Deque.Abort -> ());
        incr i
      done

(* If join were to keep waiting for a result, then work across domains
   would be blocked. The work_until loop ensures that while the current
   task is waiting to be completed and return a value, ** other tasks **
   are popped from the current domain's deque bottom and executed. *)
let work_until ctx cond =
    while not (cond ()) do
        match Deque.pop_bottom ctx.pool.deques.(ctx.worker_id) with
        | Deque.Value task ->
                run_task task ctx; (* run the task popped from the domain's
                                      own deque *)
                Atomic.decr ctx.pool.pending; (* one less pending task *)
                Atomic.incr ctx.pool.task_count (* one more task completed *)
        | Deque.Empty
        | Deque.Abort ->
                try_steal ctx;
                (* steal tasks from other deques when a domain's own deque is empty or
                a previous steal by the current domain failed *)
    done

let fork ctx f =
    (* create a future to hold the value *)
    let fut = Future.create () in

    (* f in (Task f) is of type ctx -> unit. Wrapping this in the Task constructor
       makes later pattern-matching in function easier *)
    let task = Task (fun ctx ->
        let result = f ctx in (* execute the task given the context *)
        Future.fill fut result
    ) in

    (* The pending count is updated before the task is pushed to
       the bottom of the queue. This is because if workers from other
       domains were to try and steal from this one, they would see
       existing tasks plus this count. In the case of only task,
       they would either:
           - be able to steal this one if the push_bottom is successful
           - be unsuccessful and the steal attempt would have to be later
           retried.*)
    Atomic.incr ctx.pool.pending;
    Deque.push_bottom ctx.pool.deques.(ctx.worker_id) task;

    (* the fut does not wait for the task to finish and returns *)
    fut

let join ctx fut =
  work_until ctx (fun () -> Future.is_done fut);
  match Future.get fut with
  | Some v -> v
  | None   -> assert false


let submit pool task =
    (* select the next worker/domain from the pool; fetch and add
     as well as modulo the size of the pool ensures that the
     next submitted task is to a deque within the pool *)
    let d = (Atomic.fetch_and_add pool.next_worker 1) mod pool.size in
    Atomic.incr pool.pending;
    Deque.push_bottom pool.deques.(d) task

let work_loop ctx =
  work_until ctx (fun () -> Atomic.get ctx.pool.pending = 0)

type stats = {
  steal_count : int;
  task_count  : int;
  steal_ratio : float;
}

let run ~num_workers ~steal_policy ~initial_tasks =
  let pool = create_pool num_workers steal_policy in

  (* submit puts the initial task into the pool using a round-robin
       counter maintained in the pool. This is ensure that the initial
       distributions of tasks to all deques in the pool is as balanced
       as possible *)
  List.iter (submit pool) initial_tasks;

  let work_domains = Array.init (num_workers - 1) (fun i ->
    Domain.spawn (fun () -> work_loop (make_ctx pool (i + 1)))
  ) in
  (* current domain becomes worker 0 *)
  work_loop (make_ctx pool 0);

  (* wait for all domains *)
  Array.iter Domain.join work_domains;

  let sc = Atomic.get pool.steal_count in
  let tc = Atomic.get pool.task_count in
  {
    steal_count = sc;
    task_count  = tc;
    steal_ratio = if tc = 0 then 0.0
                  else float_of_int sc /. float_of_int tc;
  }
