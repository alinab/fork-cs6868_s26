(* benchmark_sequential_bottleneck.ml
 * 
 * Demonstrates Amdahl's Law - no speedup when there's a sequential bottleneck
 * Measures execution time with increasing threads when critical section dominates
 *)

module type LOCK = sig
  type t
  val create : unit -> t
  val lock : t -> unit
  val unlock : t -> unit
  val name : string
end

(* Simulate work inside critical section (sequential bottleneck) *)
let sequential_work () =
  let sum = ref 0 in
  for i = 1 to 10000 do
    sum := !sum + i
  done;
  !sum

(* Simulate minimal parallel work outside critical section *)
let parallel_work () =
  let sum = ref 0 in
  for i = 1 to 100 do
    sum := !sum + i
  done;
  !sum

let benchmark_with_bottleneck (module L : LOCK) num_threads iterations =
  let lock = L.create () in
  
  let thread_work () =
    for _ = 1 to iterations do
      (* Small amount of parallel work *)
      let _ = parallel_work () in
      
      (* Large sequential bottleneck - all threads wait here *)
      L.lock lock;
      let _ = sequential_work () in  (* Significant work inside lock *)
      L.unlock lock;
    done
  in
  
  let start_time = Unix.gettimeofday () in
  let domains = List.init num_threads (fun _ -> Domain.spawn thread_work) in
  List.iter Domain.join domains;
  let end_time = Unix.gettimeofday () in
  
  end_time -. start_time

(* Lock registry *)
let lock_registry = [
  ("tas", (module struct
    include Spinlocks.TASLock.TASLock
    let name = "TAS"
  end : LOCK));
  ("ttas", (module struct
    include Spinlocks.TTASLock.TTASLock
    let name = "TTAS"
  end : LOCK));
  ("backoff", (module struct
    include Spinlocks.BackoffLock.DefaultBackoffLock
    let name = "Backoff"
  end : LOCK));
  ("alock", (module struct
    include Spinlocks.ALock.ALock
    let name = "ALock"
  end : LOCK));
]

let parse_locks lock_str =
  let names = String.split_on_char ',' lock_str in
  List.map (fun name ->
    let name = String.trim (String.lowercase_ascii name) in
    match List.assoc_opt name lock_registry with
    | Some lock -> lock
    | None -> 
        Printf.eprintf "Unknown lock: %s\n" name;
        Printf.eprintf "Available locks: tas, ttas, backoff, alock\n";
        exit 1
  ) names

let () =
  let iterations = ref 10000 in
  let runs = ref 5 in
  let max_threads = ref 8 in
  let locks_str = ref "ttas" in
  
  let speclist = [
    ("--locks", Arg.Set_string locks_str, "Comma-separated list of locks (default: ttas; options: tas,ttas,backoff,alock)");
    ("--iterations", Arg.Set_int iterations, "Iterations per thread (default: 10000)");
    ("--max-threads", Arg.Set_int max_threads, "Maximum number of threads (default: 8)");
    ("--runs", Arg.Set_int runs, "Number of runs (default: 5)");
  ] in
  
  Arg.parse speclist (fun _ -> ()) "Benchmark sequential bottleneck (Amdahl's Law)";
  
  let locks = parse_locks !locks_str in
  
  Printf.printf "=== Sequential Bottleneck Benchmark (Amdahl's Law) ===\n\n%!";
  Printf.printf "Configuration: %d iterations/thread × %d runs, up to %d threads\n" 
    !iterations !runs !max_threads;
  Printf.printf "Critical section has 100x more work than parallel section\n\n%!";
  
  (* Get lock names for header *)
  let lock_names = List.map (fun lock_mod ->
    let module L = (val lock_mod : LOCK) in
    L.name
  ) locks in
  
  (* Get baselines for all locks *)
  let baselines = List.map (fun lock_mod ->
    let times_1 = List.init !runs (fun _ -> 
      Gc.full_major ();
      benchmark_with_bottleneck lock_mod 1 !iterations
    ) in
    List.fold_left (+.) 0.0 times_1 /. float_of_int !runs
  ) locks in
  let avg_baseline = List.fold_left (+.) 0.0 baselines /. float_of_int (List.length baselines) in
  
  (* Print header *)
  Printf.printf "%-10s" "Threads";
  List.iter (fun name -> Printf.printf " %-12s" (name ^ "(s)")) lock_names;
  Printf.printf " %-12s\n%!" "Ideal(s)";
  
  (* Print separator *)
  let separator_width = 10 + (List.length lock_names * 13) + 13 in
  Printf.printf "%s\n%!" (String.make separator_width '-');
  
  (* Benchmark each thread count *)
  for threads = 1 to !max_threads do
    Printf.printf "%-10d" threads;
    
    (* Run each lock at this thread count *)
    List.iter (fun lock_mod ->
      let times = List.init !runs (fun _ -> 
        Gc.full_major ();
        benchmark_with_bottleneck lock_mod threads !iterations
      ) in
      let avg_time = List.fold_left (+.) 0.0 times /. float_of_int !runs in
      Printf.printf " %-12.3f" avg_time;
    ) locks;
    
    (* Print ideal time (stays constant) *)
    Printf.printf " %-12.3f\n%!" avg_baseline;
  done;
  
  Printf.printf "\nNote: Ideal stays constant - sequential bottleneck prevents any speedup\n%!"
