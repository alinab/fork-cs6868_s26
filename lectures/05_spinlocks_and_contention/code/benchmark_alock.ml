(* benchmark_alock.ml
 *
 * Benchmark program for Array Lock
 *)

let () =
  let threads, iterations = Spinlocks.Benchmark.parse_args () in
  Spinlocks.Benchmark.run_single
    (module Spinlocks.ALock.DefaultALock)
    threads iterations
