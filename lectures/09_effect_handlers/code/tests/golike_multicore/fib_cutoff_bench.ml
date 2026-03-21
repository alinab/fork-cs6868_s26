open Golike_multicore

let rec fib_seq n =
  if n < 2 then n else fib_seq (n - 1) + fib_seq (n - 2)

let rec fib_par cutoff n =
  if n < cutoff then fib_seq n
  else
    let p = Promise.async (fun () -> fib_par cutoff (n - 1)) in
    let r2 = fib_par cutoff (n - 2) in
    Promise.await p + r2

let time f =
  let t0 = Unix.gettimeofday () in
  let v = f () in
  let dt = Unix.gettimeofday () -. t0 in
  (v, dt)

let () =
  let n = ref 42 in
  let iters = ref 3 in
  let mode = ref "cutoff" in
  Arg.parse
    [ "-n", Arg.Set_int n, " Fibonacci number (default: 42)";
      "-iters", Arg.Set_int iters, " Iterations per data point (default: 3)";
      "-mode", Arg.Set_string mode, " Benchmark mode: cutoff | domains (default: cutoff)" ]
    (fun _ -> ())
    "fib_cutoff_bench [-n N] [-iters I] [-mode cutoff|domains]";
  let n = !n and iters = !iters and mode = !mode in
  let max_domains = Domain.recommended_domain_count () in

  (* Sequential baseline — best of iters *)
  let expected = fib_seq n in
  let t_seq =
    let best = ref infinity in
    for _ = 1 to iters do
      let (_, dt) = time (fun () -> fib_seq n) in
      best := Float.min !best dt
    done;
    !best
  in
  Printf.printf "fib(%d) = %d\n" n expected;
  Printf.printf "Sequential: %.3f s\n" t_seq;
  Printf.printf "Max domains: %d\n\n" max_domains;

  match mode with
  | "cutoff" ->
    Printf.printf "cutoff,time_s,speedup,num_tasks\n%!";
    let cutoffs = [10; 15; 18; 20; 22; 25; 28; 30; 35; 38; 40] in
    List.iter (fun cutoff ->
      let best = ref infinity in
      for _ = 1 to iters do
        let result = ref 0 in
        let ((), dt) = time (fun () ->
          Sched.run ~num_domains:max_domains (fun () ->
            result := fib_par cutoff n
          )
        ) in
        assert (!result = expected);
        best := Float.min !best dt
      done;
      let num_tasks = if cutoff >= n then 1 else fib_seq (n - cutoff + 1) in
      Printf.printf "%d,%.4f,%.2f,%d\n%!" cutoff !best (t_seq /. !best) num_tasks
    ) cutoffs

  | "domains" ->
    Printf.printf "domains,time_s,speedup\n%!";
    let best_cutoff = 25 in
    Printf.printf "# cutoff=%d\n%!" best_cutoff;
    let domain_counts =
      let rec go d acc =
        if d > max_domains then List.rev acc
        else go (d + 1) (d :: acc)
      in go 1 []
    in
    List.iter (fun num_domains ->
      let best = ref infinity in
      for _ = 1 to iters do
        let result = ref 0 in
        let ((), dt) = time (fun () ->
          Sched.run ~num_domains (fun () ->
            result := fib_par best_cutoff n
          )
        ) in
        assert (!result = expected);
        best := Float.min !best dt
      done;
      Printf.printf "%d,%.4f,%.2f\n%!" num_domains !best (t_seq /. !best)
    ) domain_counts

  | _ ->
    Printf.eprintf "Unknown mode: %s (use cutoff or domains)\n" mode;
    exit 1
