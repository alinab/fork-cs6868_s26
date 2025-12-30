(* Benchmark.ml
 *
 * Shared benchmarking infrastructure for all lock implementations
 *)

(* Benchmark a lock with a given number of threads and iterations *)
let benchmark_lock (module L : Lock.LOCK) num_threads iterations_per_thread =
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

  let expected = num_threads * iterations_per_thread in
  let actual = !counter in
  let correct = expected = actual in

  (elapsed, correct, actual, expected)

(* Run a single benchmark and print results *)
let run_single (module L : Lock.LOCK) threads iterations =
  Printf.printf "=== %s Benchmark ===\n\n%!" L.name;
  Printf.printf "Testing with %d threads\n" threads;
  Printf.printf "Each thread performs %d lock/unlock cycles\n\n%!" iterations;

  let elapsed, correct, actual, expected =
    benchmark_lock (module L) threads iterations
  in
  let throughput = float_of_int (threads * iterations) /. elapsed in
  let status = if correct then "✓" else "✗" in

  Printf.printf "%-15s: %d\n%!" "Threads" threads;
  Printf.printf "%-15s: %d\n%!" "Iterations" iterations;
  Printf.printf "%-15s: %.4f seconds\n%!" "Time" elapsed;
  Printf.printf "%-15s: %.0f ops/sec\n%!" "Throughput" throughput;
  Printf.printf "%-15s: %s\n%!" "Correctness" status;

  if not correct then
    Printf.printf "  Warning: Expected %d, got %d\n%!" expected actual;

  Printf.printf "\n%!"

(* Compare multiple locks with same configuration *)
let compare_locks locks threads iterations =
  Printf.printf "=== Lock Comparison ===\n\n%!";
  Printf.printf "Configuration: %d threads × %d iterations\n\n%!" threads
    iterations;

  Printf.printf "%-20s %-12s %-15s %-10s\n%!" "Lock" "Time (sec)" "Throughput"
    "Correct?";
  Printf.printf "%s\n%!" (String.make 65 '-');

  List.iter
    (fun ((module L : Lock.LOCK) as lock_mod) ->
      let elapsed, correct, actual, expected =
        benchmark_lock lock_mod threads iterations
      in
      let throughput = float_of_int (threads * iterations) /. elapsed in
      let status = if correct then "✓" else "✗" in

      Printf.printf "%-20s %-12.4f %-15.0f %-10s\n%!" L.name elapsed throughput
        status;

      if not correct then
        Printf.printf "  Warning: Expected %d, got %d\n%!" expected actual)
    locks;

  Printf.printf "\n%!"

(* Parse command-line arguments *)
let parse_args () =
  let threads = ref 4 in
  let iterations = ref 10000 in

  let usage = "Usage: benchmark [--threads N] [--iterations N]" in
  let specs =
    [
      ("--threads", Arg.Set_int threads, "Number of threads (default: 4)");
      ( "--iterations",
        Arg.Set_int iterations,
        "Iterations per thread (default: 10000)" );
    ]
  in

  Arg.parse specs (fun _ -> ()) usage;
  (!threads, !iterations)
