open Scheduler

let time f =
  let t0 = Unix.gettimeofday () in
  let result = f () in
  let t1 = Unix.gettimeofday () in
  (result, t1 -. t0)

let mean arr =
  Array.fold_left (+.) 0.0 arr /. float_of_int (Array.length arr)

let std_dev arr =
  let m = mean arr in
  let variance = Array.fold_left (fun acc x ->
    acc +. (x -. m) *. (x -. m)
  ) 0.0 arr /. float_of_int (Array.length arr) in
  sqrt variance

let print_header () =
  Printf.printf "%-10s %-12s %-8s %-10s %-22s %-8s %-6s %-8s\n"
    "scheduler" "policy" "workers" "threshold"
    "steal_ratio" "avg(s)" "sd(s)" "speedup";
  Printf.printf "%s\n" (String.make 88 '-')

let print_row scheduler policy workers threshold
              steal_ratio avg_time sd_time speedup =
  Printf.printf "%-10s %-12s %-8d %-10d %-22s %-8.4f %-6.4f %-8.2f\n"
    scheduler policy workers threshold steal_ratio avg_time sd_time speedup

let run_sections ~runs ~seq_time ~worker_counts ~thresholds ~policies
                 ~run_ws ~run_naive =

  (* work-stealing — one section per policy *)
  List.iter (fun policy ->
    let policy_str = match policy with
      | Random     -> "random"
      | RoundRobin -> "round-robin"
    in
    Printf.printf "\n=== Work-stealing (%s victim) ===\n%!" policy_str;
    print_header ();
    List.iter (fun w ->
      List.iter (fun t ->
        Printf.printf "  running ws workers=%d threshold=%d policy=%s...\n%!"
          w t policy_str;
        let ws_times  = Array.make runs 0.0 in
        let ws_steals = Array.make runs 0 in
        let ws_tasks  = Array.make runs 0 in
        for i = 0 to runs - 1 do
          let (stats, elapsed) =
            run_ws ~num_workers:w ~steal_policy:policy ~threshold:t in
          ws_times.(i)  <- elapsed;
          ws_steals.(i) <- stats.steal_count;
          ws_tasks.(i)  <- stats.task_count
        done;
        let avg_time   = mean ws_times in
        let sd_time    = std_dev ws_times in
        let tot_steals = Array.fold_left (+) 0 ws_steals in
        let tot_tasks  = Array.fold_left (+) 0 ws_tasks in
        let ratio      = if tot_tasks = 0 then 0.0
                         else float_of_int tot_steals
                              /. float_of_int tot_tasks
        in
        print_row "ws" policy_str w t
          (Printf.sprintf "%d/%d(%.1f%%)"
            tot_steals tot_tasks (ratio *. 100.0))
          avg_time sd_time (seq_time /. avg_time)
      ) thresholds
    ) worker_counts;
    Printf.printf "%s\n" (String.make 88 '-')
  ) policies;

  (* naive — one section, no steal policy *)
  Printf.printf "\n=== Naive shared-queue scheduler ===\n%!";
  print_header ();
  List.iter (fun w ->
    Printf.printf "  running naive workers=%d...\n%!" w;
    let naive_times = Array.make runs 0.0 in
    for i = 0 to runs - 1 do
      naive_times.(i) <- run_naive ~num_workers:w
    done;
    let avg_time_n = mean naive_times in
    let sd_time_n  = std_dev naive_times in
    List.iter (fun t ->
      print_row "naive" "-" w t "-"
        avg_time_n sd_time_n (seq_time /. avg_time_n)
    ) thresholds
  ) worker_counts;
  Printf.printf "%s\n" (String.make 88 '-')
