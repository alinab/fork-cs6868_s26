open Golike_multicore

module Promise_locked = struct
  let async f =
    let p = Ivar_locked.create () in
    Sched.fork (fun () -> Ivar_locked.fill p (f ()));
    p
  let await p = Ivar_locked.read p
end

module Promise_lockfree = struct
  let async f =
    let p = Ivar_lockfree.create () in
    Sched.fork (fun () -> Ivar_lockfree.fill p (f ()));
    p
  let await p = Ivar_lockfree.read p
end

let rec fib_seq n =
  if n < 2 then n else fib_seq (n - 1) + fib_seq (n - 2)

let n = 40
let cutoff = 25
let num_domains = Domain.recommended_domain_count ()
let expected = fib_seq n

let bench_locked () =
  let rec fib n =
    if n < cutoff then fib_seq n
    else
      let p1 = Promise_locked.async (fun () -> fib (n - 1)) in
      let p2 = Promise_locked.async (fun () -> fib (n - 2)) in
      Promise_locked.await p1 + Promise_locked.await p2
  in
  let result = ref 0 in
  Sched.run ~num_domains (fun () -> result := fib n);
  assert (!result = expected);
  !result

let bench_lockfree () =
  let rec fib n =
    if n < cutoff then fib_seq n
    else
      let p1 = Promise_lockfree.async (fun () -> fib (n - 1)) in
      let p2 = Promise_lockfree.async (fun () -> fib (n - 2)) in
      Promise_lockfree.await p1 + Promise_lockfree.await p2
  in
  let result = ref 0 in
  Sched.run ~num_domains (fun () -> result := fib n);
  assert (!result = expected);
  !result

let time f =
  let iters = 5 in
  let times = Array.init iters (fun _ ->
    let t0 = Unix.gettimeofday () in
    ignore (f () : int);
    Unix.gettimeofday () -. t0
  ) in
  Array.sort Float.compare times;
  (* median *)
  times.(iters / 2)

let () =
  Printf.printf "fib(%d), cutoff=%d, %d domains\n\n" n cutoff num_domains;

  let t_seq = time (fun () -> fib_seq n) in
  Printf.printf "Sequential:     %.3f s\n" t_seq;

  let t_locked = time bench_locked in
  Printf.printf "Ivar_locked:    %.3f s  (speedup %.1fx)\n" t_locked (t_seq /. t_locked);

  let t_lockfree = time bench_lockfree in
  Printf.printf "Ivar_lockfree:  %.3f s  (speedup %.1fx)\n" t_lockfree (t_seq /. t_lockfree)
