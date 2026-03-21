open Golike_multicore

let () =
  (* ---- Test 1: Basic async/await ---- *)
  Printf.printf "Test 1: Basic async/await\n%!";
  Sched.run (fun () ->
    let p = Promise.async (fun () -> 42) in
    assert (Promise.await p = 42);
    Printf.printf "  PASSED\n%!"
  );

  (* ---- Test 2: Multiple awaiters ---- *)
  Printf.printf "Test 2: Multiple awaiters\n%!";
  Sched.run (fun () ->
    let p = Promise.async (fun () ->
      Sched.yield ();
      99
    ) in
    let r1 = Atomic.make 0 in
    let r2 = Atomic.make 0 in
    Sched.fork (fun () -> Atomic.set r1 (Promise.await p));
    Sched.fork (fun () -> Atomic.set r2 (Promise.await p));
    ignore (Promise.await p : int);
    (* Yield to let forked fibers complete — in multicore they may
       still be in the scheduler queue after our await returns. *)
    while Atomic.get r1 = 0 || Atomic.get r2 = 0 do Sched.yield () done;
    assert (Atomic.get r1 = 99);
    assert (Atomic.get r2 = 99);
    Printf.printf "  PASSED\n%!"
  );

  (* ---- Test 3: Many fibers across domains ---- *)
  Printf.printf "Test 3: Many fibers across domains\n%!";
  let n = 1000 in
  let counter = Atomic.make 0 in
  Sched.run (fun () ->
    for _ = 1 to n do
      Sched.fork (fun () ->
        Atomic.incr counter
      )
    done
  );
  assert (Atomic.get counter = n);
  Printf.printf "  PASSED (%d fibers)\n%!" n
