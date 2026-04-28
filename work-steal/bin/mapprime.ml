let warmup_runs = 3

(* --- Primality test ------------------------------------------------------- *)

let is_prime n =
  if n < 2 then false
  else if n = 2 then true
  else if n mod 2 = 0 then false
  else
    let i = ref 3 in
    let result = ref true in
    while !i * !i <= n && !result do
      if n mod !i = 0 then result := false;
      i := !i + 2
    done;
    !result

(* --- Sequential map ------------------------------------------------------- *)

let map_seq arr =
  Array.map is_prime arr

(* --- Parallel map — work-stealing ----------------------------------------- *)

let par_map_ws (ctx : Scheduler.ctx) threshold arr result lo hi =
  let rec go ctx lo hi =
    if hi - lo <= threshold then
      for i = lo to hi - 1 do
        result.(i) <- is_prime arr.(i)
      done
    else
      let mid       = lo + (hi - lo) / 2 in
      let left_fut  = Scheduler.fork ctx
        (fun ctx -> go ctx lo mid) in
      let right_fut = Scheduler.fork ctx
        (fun ctx -> go ctx mid hi) in
      Scheduler.join ctx left_fut;
      Scheduler.join ctx right_fut
  in
  go ctx lo hi

(* --- Parallel map — naive ------------------------------------------------- *)

let par_map_naive (ctx : Naive_scheduler.ctx) threshold arr result lo hi =
  let rec go ctx lo hi =
    if hi - lo <= threshold then
      for i = lo to hi - 1 do
        result.(i) <- is_prime arr.(i)
      done
    else
      let mid       = lo + (hi - lo) / 2 in
      let left_fut  = Naive_scheduler.fork ctx
        (fun ctx -> go ctx lo mid) in
      let right_fut = Naive_scheduler.fork ctx
        (fun ctx -> go ctx mid hi) in
      Naive_scheduler.join ctx left_fut;
      Naive_scheduler.join ctx right_fut
  in
  go ctx lo hi

(* --- Run helpers ---------------------------------------------------------- *)

let make_input n =
  (* use values in [2, 1_000_000] to make primality interesting *)
  Array.init n (fun _ -> 2 + Random.int 999_999)

let run_ws ~num_workers ~steal_policy ~threshold ~arr ~expected =
  let n      = Array.length arr in
  let result = Array.make n false in
  let done_fut = Future.create () in
  let root = Scheduler.Task (fun ctx ->
    par_map_ws ctx threshold arr result 0 n;
    Future.fill done_fut true
  ) in
  let (stats, elapsed) = Benchmark.time (fun () ->
    Scheduler.run ~num_workers ~steal_policy ~initial_tasks:[root]
  ) in
  (match Future.get done_fut with
  | Some _ -> assert (result = expected)
  | None   -> failwith "future not filled");
  (stats, elapsed)

let run_naive ~num_workers ~threshold ~arr ~expected =
  let n      = Array.length arr in
  let result = Array.make n false in
  let done_fut = Future.create () in
  let root = Naive_scheduler.Task (fun ctx ->
    par_map_naive ctx threshold arr result 0 n;
    Future.fill done_fut true
  ) in
  let (_, elapsed) = Benchmark.time (fun () ->
    Naive_scheduler.run ~num_workers ~initial_tasks:[root]
  ) in
  (match Future.get done_fut with
  | Some _ -> assert (result = expected)
  | None   -> failwith "future not filled");
  elapsed

(* --- Experiment ----------------------------------------------------------- *)

let run_experiment ~n ~runs =
  let worker_counts = [1; 2; 4; 8; 16] in
  let thresholds    = [500; 1000; 2000; 5000] in
  let policies      = [Scheduler.Random; Scheduler.RoundRobin] in

  (* generate input and sequential expected result once *)
  Printf.printf "Generating input array n=%d...\n%!" n;
  let arr      = make_input n in
  let expected = map_seq arr in
  Printf.printf "Input generated.\n%!";

  (* sequential baseline *)
  Printf.printf "Computing sequential baseline...\n%!";
  ignore (map_seq arr);                          (* single warmup *)
  let seq_times = Array.init runs (fun _ ->
    let (_, t) = Benchmark.time (fun () -> ignore (map_seq arr)) in t
  ) in
  let seq_time = Benchmark.mean seq_times in
  let seq_sd   = Benchmark.std_dev seq_times in
  Printf.printf "sequential baseline: %.4fs +/- %.4fs\n\n%!" seq_time seq_sd;

  Printf.printf "Warming up...\n%!";
  for _ = 1 to warmup_runs do
    ignore (run_ws ~num_workers:1 ~steal_policy:Scheduler.Random
              ~threshold:1000 ~arr ~expected);
    ignore (run_naive ~num_workers:1 ~threshold:1000 ~arr ~expected)
  done;
  Printf.printf "Warmup done.\n\n%!";

  Benchmark.run_sections
    ~runs
    ~seq_time
    ~worker_counts
    ~thresholds
    ~policies
    ~run_ws:(fun ~num_workers ~steal_policy ~threshold ->
      run_ws ~num_workers ~steal_policy ~threshold ~arr ~expected)
    ~run_naive:(fun ~num_workers ->
      run_naive ~num_workers ~threshold:1000 ~arr ~expected)

let () =
  Random.self_init ();
  run_experiment ~n:1_000_000 ~runs:10
