let warmup_runs = 3

(* --- Sequential Fibonacci ----------------------------------------------- *)

let rec fib_seq n =
  if n <= 1 then n
  else fib_seq (n - 1) + fib_seq (n - 2)

(* --- Parallel Fibonacci — work-stealing --------------------------------- *)

let rec fib_par_ws (ctx : Scheduler.ctx) threshold n =
  if n <= threshold then fib_seq n
  else
    let left_fut  = Scheduler.fork ctx
      (fun ctx -> fib_par_ws ctx threshold (n - 1)) in
    let right_fut = Scheduler.fork ctx
      (fun ctx -> fib_par_ws ctx threshold (n - 2)) in
    let left  = Scheduler.join ctx left_fut in
    let right = Scheduler.join ctx right_fut in
    left + right

(* --- Parallel Fibonacci — naive ----------------------------------------- *)

let rec fib_par_naive (ctx : Naive_scheduler.ctx) threshold n =
  if n <= threshold then fib_seq n
  else
    let left_fut  = Naive_scheduler.fork ctx
      (fun ctx -> fib_par_naive ctx threshold (n - 1)) in
    let right_fut = Naive_scheduler.fork ctx
      (fun ctx -> fib_par_naive ctx threshold (n - 2)) in
    let left  = Naive_scheduler.join ctx left_fut in
    let right = Naive_scheduler.join ctx right_fut in
    left + right

(* --- Run helpers -------------------------------------------------------- *)

let run_ws ~num_workers ~steal_policy ~threshold ~n ~expected =
  let result_fut = Future.create () in
  let root = Scheduler.Task (fun ctx ->
    Future.fill result_fut (fib_par_ws ctx threshold n)
  ) in
  let (stats, elapsed) = Benchmark.time (fun () ->
    Scheduler.run ~num_workers ~steal_policy ~initial_tasks:[root]
  ) in
  (match Future.get result_fut with
  | Some result -> assert (result = expected)
  | None        -> failwith "future not filled");
  (stats, elapsed)

let run_naive ~num_workers ~threshold ~n ~expected =
  let result_fut = Future.create () in
  let root = Naive_scheduler.Task (fun ctx ->
    Future.fill result_fut (fib_par_naive ctx threshold n)
  ) in
  let (_, elapsed) = Benchmark.time (fun () ->
    Naive_scheduler.run ~num_workers ~initial_tasks:[root]
  ) in
  (match Future.get result_fut with
  | Some result -> assert (result = expected)
  | None        -> failwith "future not filled");
  elapsed

(* --- Experiment --------------------------------------------------------- *)

let run_experiment ~n ~runs =
  let worker_counts = [1; 2; 4; 8; 16] in
  let thresholds    = [20; 25; 30] in
  let policies      = [Scheduler.Random; Scheduler.RoundRobin] in

  (* sequential baseline — compute expected once, time separately *)
  Printf.printf "Computing sequential baseline for fib(%d)...\n%!" n;
  let expected = fib_seq n in
  Printf.printf "fib(%d) = %d\n%!" n expected;
  ignore (fib_seq n);                        (* single warmup *)
  let seq_times = Array.init runs (fun _ ->
    let (_, t) = Benchmark.time (fun () -> ignore (fib_seq n)) in t
  ) in
  let seq_time = Benchmark.mean seq_times in
  let seq_sd   = Benchmark.std_dev seq_times in
  Printf.printf "sequential baseline: %.4fs +/- %.4fs\n\n%!" seq_time seq_sd;

  Printf.printf "Warming up...\n%!";
  for _ = 1 to warmup_runs do
    ignore (run_ws ~num_workers:1 ~steal_policy:Scheduler.Random
              ~threshold:25 ~n ~expected);
    ignore (run_naive ~num_workers:1 ~threshold:25 ~n ~expected)
  done;
  Printf.printf "Warmup done.\n\n%!";

  Benchmark.run_sections
    ~runs
    ~seq_time
    ~worker_counts
    ~thresholds
    ~policies
    ~run_ws:(fun ~num_workers ~steal_policy ~threshold ->
      run_ws ~num_workers ~steal_policy ~threshold ~n ~expected)
    ~run_naive:(fun ~num_workers ->
      run_naive ~num_workers ~threshold:25 ~n ~expected)

let () =
  Random.self_init ();
  run_experiment ~n:38 ~runs:10

