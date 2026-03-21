open Golike_multicore

let rec fib_seq n =
  if n < 2 then n else fib_seq (n - 1) + fib_seq (n - 2)

let rec fib_par cutoff n =
  if n < cutoff then fib_seq n
  else
    let p = Promise.async (fun () -> fib_par cutoff (n - 1)) in
    let r2 = fib_par cutoff (n - 2) in
    Promise.await p + r2

let () =
  let n = ref 40 in
  let cutoff = ref 25 in
  Arg.parse
    [ "-n", Arg.Set_int n, " Fibonacci number to compute (default: 40)";
      "-cutoff", Arg.Set_int cutoff, " Sequential cutoff (default: 25)" ]
    (fun _ -> ())
    "fib [-n N] [-cutoff C]";
  let n = !n and cutoff = !cutoff in
  let expected = fib_seq n in
  Printf.printf "fib(%d) = %d\n%!" n expected;

  (* Sequential baseline *)
  let t0 = Unix.gettimeofday () in
  ignore (fib_seq n : int);
  let t_seq = Unix.gettimeofday () -. t0 in
  Printf.printf "Sequential:  %.3f s\n%!" t_seq;

  (* Parallel *)
  let num_domains = Domain.recommended_domain_count () in
  let result = ref 0 in
  let t0 = Unix.gettimeofday () in
  Sched.run ~num_domains (fun () ->
    result := fib_par cutoff n
  );
  let t_par = Unix.gettimeofday () -. t0 in
  assert (!result = expected);
  Printf.printf "Parallel:    %.3f s  (%d domains, cutoff %d)\n%!"
    t_par num_domains cutoff;
  Printf.printf "Speedup:     %.1fx\n%!" (t_seq /. t_par)
