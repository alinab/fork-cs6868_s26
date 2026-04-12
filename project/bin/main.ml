open Scheduler

let threshold = ref 30

let rec fib_seq n =
  if n <= 1 then n
  else fib_seq (n-1) + fib_seq (n-2)

let rec fib_par ctx n =
  if n <= !threshold then fib_seq n
  else
    let left_fut  = fork ctx (fun ctx -> fib_par ctx (n-1)) in
    let right_fut = fork ctx (fun ctx -> fib_par ctx (n-2)) in
    let left      = join ctx left_fut in
    let right     = join ctx right_fut in
    left + right

let time f =
  let t0 = Unix.gettimeofday () in
  let result = f () in
  let t1 = Unix.gettimeofday () in
  (result, t1 -. t0)

let run_once ~num_workers ~n =
  let result_fut = Future.create () in
  let root = Task (fun ctx ->
    Future.fill result_fut (fib_par ctx n)
  ) in
  let (steals, elapsed) = time (fun () ->
    run ~num_workers ~initial_tasks:[root]
  ) in
  (match Future.get result_fut with
  | Some result ->
      let expected = fib_seq n in
      if result <> expected then
        Printf.printf "  INCORRECT: expected=%d got=%d\n" expected result
  | None ->
      failwith "result future was never filled");
  (steals, elapsed)

let run_experiment ~n ~runs =
  let (seq_result, seq_time) = time (fun () -> fib_seq n) in
  Printf.printf "fib(%d) = %d\n" n seq_result;
  Printf.printf "sequential baseline: %.4fs\n\n" seq_time;
  Printf.printf "%-12s %-12s %-10s %-10s %-10s\n"
    "workers" "threshold" "avg_steals" "avg_time" "speedup";
  Printf.printf "%s\n" (String.make 57 '-');
  let worker_counts = [1; 2; 4; 8; 16] in
  let thresholds    = [20; 25; 30; 35] in
  List.iter (fun w ->
    List.iter (fun t ->
      threshold := t;
      let times  = Array.make runs 0.0 in
      let steals = Array.make runs 0 in
      for i = 0 to runs - 1 do
        let (s, elapsed) = run_once ~num_workers:w ~n in
        steals.(i) <- s;
        times.(i)  <- elapsed
      done;
      let avg_time   = Array.fold_left (+.) 0.0 times /. float_of_int runs in
      let avg_steals = Array.fold_left (+) 0 steals / runs in
      let speedup    = seq_time /. avg_time in
      Printf.printf "%-12d %-12d %-10d %-10.4f %-10.2f\n"
        w t avg_steals avg_time speedup
    ) thresholds;
    Printf.printf "%s\n" (String.make 57 '-')
  ) worker_counts

let () =
  run_experiment ~n:38 ~runs:5


