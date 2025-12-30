(* tune_backoff.ml
 *
 * Benchmark different MIN/MAX delay configurations for Backoff Lock
 * to find optimal parameters for different thread counts
 *)

(* Test different parameter combinations *)
let run_tuning_benchmarks threads iterations =
  Printf.printf "=== Backoff Lock Parameter Tuning ===\n\n%!";
  Printf.printf "Configuration: %d threads × %d iterations\n" threads iterations;
  Printf.printf
    "Testing different (MIN_DELAY, MAX_DELAY) combinations using \
     Domain.cpu_relax\n\n\
     %!";

  (* Parameter combinations to test *)
  let params =
    [
      (1, 16);
      (1, 32);
      (1, 64);
      (1, 128);
      (1, 256);
      (1, 512);
      (2, 64);
      (2, 128);
      (2, 256);
      (4, 128);
      (4, 256);
      (4, 512);
      (8, 256);
      (8, 512);
      (16, 512);
    ]
  in

  Printf.printf "%-20s %-12s %-15s\n%!" "Parameters" "Time (sec)" "Throughput";
  Printf.printf "%s\n%!" (String.make 55 '-');

  let results =
    List.map
      (fun (min_d, max_d) ->
        let lock_mod = Spinlocks.BackoffLock.make_custom_lock min_d max_d in
        let elapsed, correct, _, _ =
          Spinlocks.Benchmark.benchmark_lock lock_mod threads iterations
        in
        let throughput = float_of_int (threads * iterations) /. elapsed in
        Printf.printf "(%3d, %4d)         %-12.4f %-15.0f\n%!" min_d max_d
          elapsed throughput;
        ((min_d, max_d), elapsed, throughput, correct))
      params
  in

  Printf.printf "\n%!";

  (* Find the best configuration *)
  let best =
    List.fold_left
      (fun ((_, _, best_tp, _) as best_result)
           ((_, _, tp, _) as current_result) ->
        if tp > best_tp then current_result else best_result)
      (List.hd results) (List.tl results)
  in

  let (min_d, max_d), elapsed, throughput, _ = best in
  Printf.printf "Best configuration:\n";
  Printf.printf "  MIN_DELAY: %d, MAX_DELAY: %d\n" min_d max_d;
  Printf.printf "  Time: %.4f seconds\n" elapsed;
  Printf.printf "  Throughput: %.0f ops/sec\n%!" throughput

let () =
  let threads = ref 8 in
  let iterations = ref 10000 in

  let usage = "Usage: tune_backoff [--threads N] [--iterations N]" in
  let specs =
    [
      ("--threads", Arg.Set_int threads, "Number of threads (default: 8)");
      ( "--iterations",
        Arg.Set_int iterations,
        "Iterations per thread (default: 10000)" );
    ]
  in

  Arg.parse specs (fun _ -> ()) usage;

  run_tuning_benchmarks !threads !iterations
