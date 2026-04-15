type task = Task of (ctx -> unit)

and ctx = {
  pool : pool;
}

and pool = {
  queue   : task Queue.t;
  mutex   : Mutex.t;
  pending : int Atomic.t;
  size    : int;
}

let run_task (Task f) ctx = f ctx

let create_pool n = {
  queue   = Queue.create ();
  mutex   = Mutex.create ();
  pending = Atomic.make 0;
  size    = n;
}

let push pool task =
  Mutex.lock pool.mutex;
  Queue.push task pool.queue;
  Mutex.unlock pool.mutex

let pop pool =
  Mutex.lock pool.mutex;
  let task = if Queue.is_empty pool.queue then None
             else Some (Queue.pop pool.queue)
  in
  Mutex.unlock pool.mutex;
  task

let complete pool = Atomic.decr pool.pending

let spawn ctx task = Atomic.incr ctx.pool.pending;
                       push ctx.pool task

let fork ctx f =
  let fut = Future.create () in
  let task = Task (fun ctx ->
    let result = f ctx in
    Future.fill fut result
  ) in
  spawn ctx task;
  fut

let join ctx fut =
  while not (Future.is_done fut) do
    match pop ctx.pool with
    | Some task ->
        run_task task ctx;
        complete ctx.pool
    | None -> ()
  done;
  match Future.get fut with
  | Some v -> v
  | None   -> assert false

let worker_loop ctx =
  while Atomic.get ctx.pool.pending > 0 do
    match pop ctx.pool with
    | Some task ->
        run_task task ctx;
        complete ctx.pool
    | None -> ()
  done

let run ~num_workers ~initial_tasks =
  let pool = create_pool num_workers in
  Atomic.set pool.pending (List.length initial_tasks);
  List.iter (push pool) initial_tasks;
  let domains = Array.init (num_workers - 1) (fun _ ->
    Domain.spawn (fun () -> worker_loop { pool })
  ) in
  worker_loop { pool };
  Array.iter Domain.join domains
