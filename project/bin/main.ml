open Scheduler

let threshold = ref 4

let rec par_sum ctx arr lo hi =
  if hi - lo <= !threshold then begin
    let s = ref 0 in
    for i = lo to hi - 1 do s := !s + arr.(i) done;
    !s
  end else begin
    let mid       = lo + (hi - lo) / 2 in
    let left_fut  = fork ctx (fun ctx -> par_sum ctx arr lo mid) in
    let right_fut = fork ctx (fun ctx -> par_sum ctx arr mid hi) in
    let left      = join ctx left_fut in
    let right     = join ctx right_fut in
    left + right
  end

let time f =
  let t0 = Unix.gettimeofday () in
  let result = f () in
  let t1 = Unix.gettimeofday () in
  (result, t1 -. t0)

let run_once ~num_workers ~n =
  let arr      = Array.init n (fun i -> i + 1) in
  let expected = n * (n + 1) / 2 in
  let result_fut = Future.create () in
  let root = Task (fun ctx ->
    Future.fill result_fut (par_sum ctx arr 0 n)
  ) in
  let (steals, elapsed) = time (fun () ->
    run ~num_workers ~initial_tasks:[root]
  ) in
  (match Future.get result_fut with
  | Some result -> assert (result = expected)
  | None        -> failwith "result future was never filled");
  (steals, elapsed)

let run_experiment ~n ~runs =
  let worker_counts = [1; 2; 4; 8; 16] in
  let thresholds = [64; 128; 256; 512; 1024; 2048; 4096] in
  (* measure sequential baseline first *)
  let arr      = Array.init n (fun i -> i + 1) in
  let (_, seq_time) = time (fun () ->
    let s = ref 0 in
    Array.iter (fun x -> s := !s + x) arr;
    !s
  ) in
  Printf.printf "sequential baseline: %.4fs\n\n" seq_time;
  Printf.printf "%-12s %-12s %-10s %-10s %-10s %-10s\n"
    "workers" "threshold" "avg_steals" "avg_time" "speedup" "correct";
  Printf.printf "%s\n" (String.make 70 '-');
  List.iter (fun w ->
    List.iter (fun t ->
      threshold := t;
      let times  = Array.make runs 0.0 in
      let steals = Array.make runs 0 in
      let all_correct = ref true in
      for i = 0 to runs - 1 do
        let (s, elapsed) = run_once ~num_workers:w ~n in
        steals.(i) <- s;
        times.(i)  <- elapsed;
      done;
      let avg_time =
        Array.fold_left (+.) 0.0 times /. float_of_int runs in
      let avg_steals =
        Array.fold_left (+) 0 steals / runs in
      let speedup = seq_time /. avg_time in
      Printf.printf "%-12d %-12d %-10d %-10.4f %-10.2f %-10b\n"
        w t avg_steals avg_time speedup !all_correct
    ) thresholds
  ) worker_counts

let () =
  run_experiment ~n:1_000_000 ~runs:10

