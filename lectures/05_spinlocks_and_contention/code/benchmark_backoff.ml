(* benchmark_backoff.ml
 *
 * Benchmark program for Backoff Lock
 *)

let () =
  let threads, iterations = Spinlocks.Benchmark.parse_args () in
  Spinlocks.Benchmark.run_single
    (module Spinlocks.BackoffLock.DefaultBackoffLock)
    threads iterations
