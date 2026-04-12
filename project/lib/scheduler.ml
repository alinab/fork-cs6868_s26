(* A task is just executing a function for now (unit-> unit *)
(* A later refinement does two things to redefine a task:
    - a task takes a context (ctx) and returns a unit (* explained below *)
    - wraps the task in a Task type
    *)
type task = Task of (ctx -> unit)

(* The abstract type ctx is now defined as a type with
   - the current domain/worker id
   - the pool containing of all deques
   *)
and ctx = {
    worker_id : int;
    pool      : deque_pool
}

and
(* A deque_pool is a type containing:
   - an array of deques, one for each domain into which tasks are
     put into and stolen from across domains.
   - size denotes the number of total domains
   - pending denotes the counter of unfinished tasks; incremented
     every time a task is added to a deque and decremented when
     a task finishes running
   *)
deque_pool = {
    deques  : task Deque.t array;
    pending : int Atomic.t;
    size    : int          (* number of domains *)
}

(* The policy for stealing across domains is (for now) randomly picking up
   a domain to steal tasks from *)
let try_steal ctx =
    let init_rand = Random.State.make_self_init () in
    let victim = ref (Random.State.int init_rand ctx.pool_size) in

    (* ensure tasks are stolen from other domains *)
    while !victim = ctx.worker_id do
        victim := Random.State.int rng ctx.pool.size
    done;
    (* once another victim domain is determined *)
    match Deque.steal ctx.pool.deques.(!victim) with
    | Deque.Value task ->
            run_task task ctx;
            Atomic.decr ctx.pool.pending (* one less pending task *)
    | Deque.Empty
    | Deque.Abort -> ()


(* If join were to keep waiting for a result, then work across domains
   would be blocked. The work_until loop ensures that while the current
   task is waiting to be completed and return a value, ** other tasks **
   are popped from the current domain's deque'a bottom and executed. *)
let work_until ctx cond =
    while not (cond ()) do
        match Deque.pop_bottom ctx.pool.deques.(ctx.worker_id) with
        | Deque.Value task ->
                run_task task ctx; (* run the task popped from the domain's
                                      own deque *)
                Atomic.decr ctx.pool.pending (* one less pending task *)
        | Deque.Empty
        | Deque.Abort -> try_steal ctx (* steal tasks from other deques when
                                        a domain's own deque is empty or
                                        a previous steal by the current
                                        domain failed *)


let fork ctx f =
    (* create a future to hold the value *)
    let fut = Future.create () in

    (* f is of type ctx -> unit. Wrapping this in the Task constructor
       makes later pattern-matching in function easier *)
    let task = Task (fun ctx ->
        let result = f ctx in (* execute the task give the context *)
        Future.fill fut result
    ) in

    (* The pending is updated before the task is pushed to
       the bottom of the queue. ? *)
    ignore (Atomic.fetch_and_add ctx.pool.pending 1);
    Deque.push_bottom ctx.pool.deques.(ctx.worker_id) task;

    (* the fut does not wait for the task to finish and returns *)
    fut

let join ctx fut =
  work_until ctx (fun () -> Future.is_done fut);
  match Future.get fut with
  | Some v -> v
  | None   -> assert false

