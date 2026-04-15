open Scheduler

let threshold = ref 1000

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

let rec par_mergesort_ws (ctx : Scheduler.ctx) src dst lo hi =
  if hi - lo <= !threshold then begin
    Array.blit src lo dst lo (hi - lo);
    sequential_sort dst lo hi
  end else begin
    let mid = lo + (hi - lo) / 2 in
    (* alternate src and dst at each level to avoid races *)
    let left_fut  = Scheduler.fork ctx
      (fun ctx -> par_mergesort_ws ctx dst src lo mid) in
    let right_fut = Scheduler.fork ctx
      (fun ctx -> par_mergesort_ws ctx dst src mid hi) in
    Scheduler.join ctx left_fut;
    Scheduler.join ctx right_fut;
    merge src dst lo mid hi
  end

(* parallel mergesort — naive *)
let rec par_mergesort_naive (ctx : Naive_scheduler.ctx) src dst lo hi =
  if hi - lo <= !threshold then begin
    Array.blit src lo dst lo (hi - lo);
    sequential_sort dst lo hi
  end else begin
    let mid = lo + (hi - lo) / 2 in
    let left_fut  = Naive_scheduler.fork ctx
      (fun ctx -> par_mergesort_naive ctx dst src lo mid) in
    let right_fut = Naive_scheduler.fork ctx
      (fun ctx -> par_mergesort_naive ctx dst src mid hi) in
    Naive_scheduler.join ctx left_fut;
    Naive_scheduler.join ctx right_fut;
    merge src dst lo mid hi
  end


let is_sorted arr =
  let n = Array.length arr in
  let ok = ref true in
  for i = 0 to n - 2 do
    if arr.(i) > arr.(i+1) then ok := false
  done;
  !ok

let time f =
  let t0 = Unix.gettimeofday () in
  let result = f () in
  let t1 = Unix.gettimeofday () in
  (result, t1 -. t0)

let run_experiment ~n ~runs =
  let worker_counts = [1; 2; 4; 8; 16] in
  let thresholds    = [1000; 5000] in

  (* sequential baseline *)
  let arr = Array.init n (fun _ -> Random.int 1_000_000) in
  let (_, seq_time) = time (fun () -> Array.sort compare arr) in

  Printf.printf "n=%d sequential baseline: %.4fs\n\n" n seq_time;
  Printf.printf "%-12s %-12s %-12s %-10s %-10s %-10s\n"
    "scheduler" "workers" "threshold" "avg_steals" "avg_time" "speedup";
  Printf.printf "%s\n" (String.make 70 '-');

  List.iter (fun w ->
    List.iter (fun t ->
      threshold := t;
      let times  = Array.make runs 0.0 in
      let steals = Array.make runs 0 in
      for i = 0 to runs - 1 do
       let arr = Array.init n (fun _ -> Random.int 1_00_000) in
       let tmp = Array.copy arr in
       let result_fut = Future.create () in
       let root = Scheduler.Task (fun ctx ->
         par_mergesort_ws ctx arr tmp 0 n;
         Future.fill result_fut (is_sorted tmp)
       ) in
       let (s, elapsed) = time (fun () ->
         Scheduler.run ~num_workers:w ~initial_tasks:[root]
       ) in
       (match Future.get result_fut with
       | Some sorted -> assert sorted
       | None -> failwith "future not filled");
       steals.(i) <- s;
       times.(i)  <- elapsed
     done;


      let avg_time   = Array.fold_left (+.) 0.0 times /. float_of_int runs in
      let avg_steals = Array.fold_left (+) 0 steals / runs in
      Printf.printf "%-12s %-12d %-12d %-10d %-10.4f %-10.2f\n"
        "ws" w t avg_steals avg_time (seq_time /. avg_time);
      (* naive *)
      let times = Array.make runs 0.0 in

      for i = 0 to runs - 1 do
       let arr = Array.init n (fun _ -> Random.int 1_00_000) in
       let tmp = Array.copy arr in
       let result_fut = Future.create () in
       let root = Naive_scheduler.Task (fun ctx ->
         par_mergesort_naive ctx arr tmp 0 n;
         Future.fill result_fut (is_sorted tmp)
       ) in
       let (_, elapsed) = time (fun () ->
         Naive_scheduler.run ~num_workers:w ~initial_tasks:[root]
       ) in
       (match Future.get result_fut with
       | Some sorted -> assert sorted
       | None -> failwith "future not filled");
       times.(i) <- elapsed
      done;

      let avg_time = Array.fold_left (+.) 0.0 times /. float_of_int runs in
      Printf.printf "%-12s %-12d %-12d %-10s %-10.4f %-10.2f\n"
        "naive" w t "-" avg_time (seq_time /. avg_time)
    ) thresholds;
    Printf.printf "%s\n" (String.make 70 '-')
  ) worker_counts

let () =
  Random.self_init ();
  run_experiment ~n:1_00_000 ~runs:5

