(* compare_ttas_variants.ml - Compare safe vs unsafe TTAS *)

let benchmark_lock (module L : Spinlocks.Lock.LOCK) num_threads iterations_per_thread runs =
  let times = ref [] in
  
  for run = 1 to runs do
    let lock = L.create () in
    let counter = ref 0 in

    let thread_work () =
      for _ = 1 to iterations_per_thread do
        L.lock lock;
        counter := !counter + 1;
        L.unlock lock
      done
    in

    let start_time = Unix.gettimeofday () in
    let domains = List.init num_threads (fun _ -> Domain.spawn thread_work) in
    List.iter Domain.join domains;
    let end_time = Unix.gettimeofday () in
    
    let elapsed = end_time -. start_time in
    times := elapsed :: !times;
    
    let expected = num_threads * iterations_per_thread in
    if !counter <> expected then
      Printf.printf "ERROR in run %d: expected %d, got %d\n%!" run expected !counter
  done;
  
  !times

let avg times = 
  let sum = List.fold_left (+.) 0.0 times in
  sum /. float_of_int (List.length times)

let min_max times =
  let sorted = List.sort compare times in
  (List.hd sorted, List.hd (List.rev sorted))

let () =
  let threads = ref 8 in
  let iterations = ref 100000 in
  let runs = ref 5 in

  let speclist = [
    ("--threads", Arg.Set_int threads, "Number of threads (default: 8)");
    ("--iterations", Arg.Set_int iterations, "Iterations per thread (default: 100000)");
    ("--runs", Arg.Set_int runs, "Number of runs (default: 5)");
  ] in

  Arg.parse speclist (fun _ -> ()) "Compare TTAS variants";

  Printf.printf "=== TTAS Variants Comparison ===\n\n%!";
  Printf.printf "Configuration: %d threads × %d iterations × %d runs\n\n%!" 
    !threads !iterations !runs;

  Printf.printf "Running Safe TTAS...\n%!";
  let safe_times = benchmark_lock (module Spinlocks.TTASLock.TTASLock) !threads !iterations !runs in
  let safe_avg = avg safe_times in
  let safe_min, safe_max = min_max safe_times in
  
  Printf.printf "Running Unsafe TTAS...\n%!";
  let unsafe_times = benchmark_lock (module Spinlocks.TTASLockUnsafe) !threads !iterations !runs in
  let unsafe_avg = avg unsafe_times in
  let unsafe_min, unsafe_max = min_max unsafe_times in

  let total_ops = float_of_int (!threads * !iterations) in
  
  Printf.printf "\n%-20s %12s %12s %12s %12s\n" 
    "Variant" "Avg Time" "Min Time" "Max Time" "Avg Throughput";
  Printf.printf "%s\n" (String.make 80 '-');
  
  Printf.printf "%-20s %10.4fs %10.4fs %10.4fs %10.0f ops/s\n"
    "Safe TTAS" safe_avg safe_min safe_max (total_ops /. safe_avg);
  
  Printf.printf "%-20s %10.4fs %10.4fs %10.4fs %10.0f ops/s\n"
    "Unsafe TTAS" unsafe_avg unsafe_min unsafe_max (total_ops /. unsafe_avg);
  
  Printf.printf "\n";
  Printf.printf "Speedup: %.2fx\n" (safe_avg /. unsafe_avg)
