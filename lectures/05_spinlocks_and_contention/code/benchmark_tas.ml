(* benchmark_tas.ml
 *
 * Benchmark program for TAS Lock
 *)

let () =
  let threads, iterations = Spinlocks.Benchmark.parse_args () in
  Spinlocks.Benchmark.run_single
    (module Spinlocks.TASLock.TASLock)
    threads iterations
