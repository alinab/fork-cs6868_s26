let warmup_runs = 3

let sequential_sort arr lo hi =
  let sub = Array.sub arr lo (hi - lo) in
  Array.sort compare sub;
  Array.blit sub 0 arr lo (hi - lo)

let merge src dst lo mid hi =
  let i = ref lo in
  let j = ref mid in
  let k = ref lo in
  while !i < mid && !j < hi do
    if src.(!i) <= src.(!j) then begin
      dst.(!k) <- src.(!i); incr i
    end else begin
      dst.(!k) <- src.(!j); incr j
    end;
    incr k
  done;
  while !i < mid do
    dst.(!k) <- src.(!i); incr i; incr k
  done;
  while !j < hi do
    dst.(!k) <- src.(!j); incr j; incr k
  done

let is_sorted arr =
  let n = Array.length arr in
  let ok = ref true in
  for i = 0 to n - 2 do
    if arr.(i) > arr.(i + 1) then ok := false
  done;
  !ok

let rec par_mergesort_ws (ctx : Scheduler.ctx) threshold src dst lo hi =
  if hi - lo <= threshold then begin
    Array.blit src lo dst lo (hi - lo);
    sequential_sort dst lo hi
  end else begin
    let mid       = lo + (hi - lo) / 2 in
    let left_fut  = Scheduler.fork ctx
      (fun ctx -> par_mergesort_ws ctx threshold dst src lo mid) in
    let right_fut = Scheduler.fork ctx
      (fun ctx -> par_mergesort_ws ctx threshold dst src mid hi) in
    Scheduler.join ctx left_fut;
    Scheduler.join ctx right_fut;
    merge src dst lo mid hi
  end

let rec par_mergesort_naive (ctx : Naive_scheduler.ctx) threshold src dst lo hi =
  if hi - lo <= threshold then begin
    Array.blit src lo dst lo (hi - lo);
    sequential_sort dst lo hi
  end else begin
    let mid       = lo + (hi - lo) / 2 in
    let left_fut  = Naive_scheduler.fork ctx
      (fun ctx -> par_mergesort_naive ctx threshold dst src lo mid) in
    let right_fut = Naive_scheduler.fork ctx
      (fun ctx -> par_mergesort_naive ctx threshold dst src mid hi) in
    Naive_scheduler.join ctx left_fut;
    Naive_scheduler.join ctx right_fut;
    merge src dst lo mid hi
  end

let run_ws ~num_workers ~steal_policy ~threshold ~n =
  let arr = Array.init n (fun _ -> Random.int 1_000_000) in
  let tmp = Array.copy arr in
  let result_fut = Future.create () in
  let root = Scheduler.Task (fun ctx ->
    par_mergesort_ws ctx threshold arr tmp 0 n;
    Future.fill result_fut (is_sorted tmp)
  ) in
  let (stats, elapsed) = Benchmark.time (fun () ->
    Scheduler.run ~num_workers ~steal_policy ~initial_tasks:[root]
  ) in
  (match Future.get result_fut with
  | Some sorted -> assert sorted
  | None        -> failwith "future not filled");
  (stats, elapsed)

let run_naive ~num_workers ~threshold ~n =
  let arr = Array.init n (fun _ -> Random.int 1_000_000) in
  let tmp = Array.copy arr in
  let result_fut = Future.create () in
  let root = Naive_scheduler.Task (fun ctx ->
    par_mergesort_naive ctx threshold arr tmp 0 n;
    Future.fill result_fut (is_sorted tmp)
  ) in
  let (_, elapsed) = Benchmark.time (fun () ->
    Naive_scheduler.run ~num_workers ~initial_tasks:[root]
  ) in
  (match Future.get result_fut with
  | Some sorted -> assert sorted
  | None        -> failwith "future not filled");
  elapsed

let run_experiment ~n ~runs =
  let worker_counts = [1; 2; 4; 8; 16] in
  let thresholds    = [500; 1000; 2000; 5000] in
  let policies      = [Scheduler.Random; Scheduler.RoundRobin] in

  (* sequential baseline *)
  Printf.printf "Computing sequential baseline for mergesort n=%d...\n%!" n;
  for _ = 1 to warmup_runs do
    let arr = Array.init n (fun _ -> Random.int 1_000_000) in
    Array.sort compare arr
  done;
  let seq_times = Array.init runs (fun _ ->
    let arr = Array.init n (fun _ -> Random.int 1_000_000) in
    let (_, t) = Benchmark.time (fun () -> Array.sort compare arr) in t
  ) in
  let seq_time = Benchmark.mean seq_times in
  let seq_sd   = Benchmark.std_dev seq_times in
  Printf.printf "sequential baseline: %.4fs +/- %.4fs\n\n%!" seq_time seq_sd;

  Printf.printf "Warming up...\n%!";
  for _ = 1 to warmup_runs do
    ignore (run_ws ~num_workers:1 ~steal_policy:Scheduler.Random
              ~threshold:1000 ~n);
    ignore (run_naive ~num_workers:1 ~threshold:1000 ~n)
  done;
  Printf.printf "Warmup done.\n\n%!";

  Benchmark.run_sections
    ~runs
    ~seq_time
    ~worker_counts
    ~thresholds
    ~policies
    ~run_ws:(fun ~num_workers ~steal_policy ~threshold ->
      run_ws ~num_workers ~steal_policy ~threshold ~n)
    ~run_naive:(fun ~num_workers ->
      run_naive ~num_workers ~threshold:1000 ~n)

let () =
  Random.self_init ();
  run_experiment ~n:1_000_000 ~runs:10

