(* benchmark_ttas.ml
 *
 * Benchmark program for TTAS Lock
 *)

let () =
  let threads, iterations = Spinlocks.Benchmark.parse_args () in
  Spinlocks.Benchmark.run_single
    (module Spinlocks.TTASLock.TTASLock)
    threads iterations
