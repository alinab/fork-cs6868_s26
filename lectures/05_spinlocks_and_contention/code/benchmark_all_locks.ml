(* benchmark_all_locks.ml - Comprehensive benchmark of all lock types *)

let benchmark_lock (module L : Spinlocks.Lock.LOCK) num_threads iterations_per_thread runs =
  let times = ref [] in
  
  for _run = 1 to runs do
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
      Printf.printf "ERROR: expected %d, got %d\n%!" expected !counter
  done;
  
  !times

let avg times = 
  let sum = List.fold_left (+.) 0.0 times in
  sum /. float_of_int (List.length times)

let () =
  let iterations = ref 50000 in
  let runs = ref 5 in

  let speclist = [
    ("--iterations", Arg.Set_int iterations, "Iterations per thread (default: 50000)");
    ("--runs", Arg.Set_int runs, "Number of runs (default: 5)");
  ] in

  Arg.parse speclist (fun _ -> ()) "Benchmark all locks";

  Printf.printf "=== Spinlock Performance Comparison ===\n\n%!";
  Printf.printf "Configuration: %d iterations/thread × %d runs\n\n%!" !iterations !runs;
  
  Printf.printf "%-15s" "Threads";
  Printf.printf " %12s %12s %12s %12s\n" "TAS" "TTAS" "Backoff" "ALock";
  Printf.printf "%s\n" (String.make 80 '-');

  for threads = 1 to 8 do
    Printf.printf "%-15d" threads;
    
    (* TAS Lock *)
    let tas_times = benchmark_lock (module Spinlocks.TASLock.TASLock) threads !iterations !runs in
    let tas_throughput = (float_of_int (threads * !iterations)) /. (avg tas_times) in
    Printf.printf " %10.0fK" (tas_throughput /. 1000.0);
    
    (* TTAS Lock *)
    let ttas_times = benchmark_lock (module Spinlocks.TTASLock.TTASLock) threads !iterations !runs in
    let ttas_throughput = (float_of_int (threads * !iterations)) /. (avg ttas_times) in
    Printf.printf " %10.0fK" (ttas_throughput /. 1000.0);
    
    (* Backoff Lock *)
    let backoff_times = benchmark_lock (module Spinlocks.BackoffLock.DefaultBackoffLock) threads !iterations !runs in
    let backoff_throughput = (float_of_int (threads * !iterations)) /. (avg backoff_times) in
    Printf.printf " %10.0fK" (backoff_throughput /. 1000.0);
    
    (* ALock *)
    let alock_times = benchmark_lock (module Spinlocks.ALock.DefaultALock) threads !iterations !runs in
    let alock_throughput = (float_of_int (threads * !iterations)) /. (avg alock_times) in
    Printf.printf " %10.0fK" (alock_throughput /. 1000.0);
    
    Printf.printf "\n%!";
  done;
  
  Printf.printf "\nThroughput in thousands of ops/sec (K = 1000)\n%!"
