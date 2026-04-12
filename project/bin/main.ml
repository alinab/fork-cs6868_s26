let threshold = ref 0

let rec par_sum ctx arr lo hi =
  if hi - lo <= !threshold then begin
    let s = ref 0 in
    for i = lo to hi - 1 do s := !s + arr.(i) done;
    !s
  end else begin
    let mid = lo + (hi - lo) / 2 in
    let left_fut = Scheduler.fork ctx (fun ctx -> par_sum ctx arr lo mid) in
    let right_fut = Scheduler.fork ctx (fun ctx -> par_sum ctx arr mid hi) in
        (* par_sum ctx arr mid hi in *)
    let left     = Scheduler.join ctx left_fut in
    let right    = Scheduler.join ctx right_fut in
    left + right
  end


let run_experiment ~num_workers ~n ~runs =
  let arr      = Array.init n (fun i -> i + 1) in
  let expected = n * (n + 1) / 2 in
  let thresholds = [4; 16; 64; 256; 1024] in
  List.iter (fun t ->
    threshold := t;
    let all_correct  = ref true in
    let steal_counts = Array.init runs (fun _ ->
      let result_fut = Future.create () in
      let root = Scheduler.Task (fun ctx ->
        Future.fill result_fut (par_sum ctx arr 0 n)
      ) in
      let steals = Scheduler.run ~num_workers ~initial_tasks:[root] in
      (match Future.get result_fut with
      | Some result ->
          if result <> expected then begin
            all_correct := false;
            Printf.printf "  INCORRECT: expected=%d got=%d\n" expected result
          end
      | None ->
          all_correct := false;
          failwith "result future was never filled");
      steals
    ) in
    let total    = Array.fold_left (+) 0 steal_counts in
    let avg      = total / runs in
    let variance = Array.fold_left (fun acc x ->
      acc + (x - avg) * (x - avg)
    ) 0 steal_counts / runs in
    let min_s    = Array.fold_left min max_int steal_counts in
    let max_s    = Array.fold_left max min_int steal_counts in
    Printf.printf
      "threshold=%4d  avg=%4d  min=%4d  max=%4d  variance=%6d  correct=%b\n"
      t avg min_s max_s variance !all_correct
  ) thresholds


let () =
    let worker_counts = [2; 4; 8; 16] in
     List.iter (fun w ->
     Printf.printf "\n=== num_workers=%d ===\n" w;
     run_experiment ~num_workers:w ~n:1_000_000 ~runs:10
    ) worker_counts

