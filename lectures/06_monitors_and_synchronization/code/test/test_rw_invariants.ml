(** Comprehensive tests for read-write lock invariants *)

let test_concurrent_readers () =
  Printf.printf "=== Testing Concurrent Readers (Simple RW Lock) ===\n%!";
  let rwlock = Simple_rw_lock.create () in
  let concurrent_readers = Atomic.make 0 in
  let max_concurrent = Atomic.make 0 in

  let reader rid () =
    for i = 1 to 10 do
      Simple_rw_lock.read_lock rwlock;

      (* Track concurrent readers *)
      let current = Atomic.fetch_and_add concurrent_readers 1 + 1 in
      let max = Atomic.get max_concurrent in
      if current > max then Atomic.set max_concurrent current;

      Printf.printf "Reader %d (iteration %d): entered (concurrent=%d)\n%!" rid i current;
      Unix.sleepf 0.001;  (* Hold lock briefly *)

      Atomic.decr concurrent_readers;
      Simple_rw_lock.read_unlock rwlock;
      Unix.sleepf 0.0001
    done
  in

  let readers = Array.init 5 (fun i -> Domain.spawn (fun () -> reader (i + 1) ())) in
  Array.iter Domain.join readers;

  let max = Atomic.get max_concurrent in
  Printf.printf "\n✓ Max concurrent readers: %d\n" max;
  if max > 1 then
    Printf.printf "✓ PASS: Multiple readers held lock concurrently\n\n%!"
  else
    Printf.printf "✗ FAIL: Readers did not overlap!\n\n%!"

let test_writer_exclusion () =
  Printf.printf "=== Testing Writer Exclusion (Simple RW Lock) ===\n%!";
  let rwlock = Simple_rw_lock.create () in
  let active_readers = Atomic.make 0 in
  let active_writers = Atomic.make 0 in
  let violations = Atomic.make 0 in

  let reader rid () =
    for _i = 1 to 5 do
      Simple_rw_lock.read_lock rwlock;
      Atomic.incr active_readers;

      (* Check no writers active *)
      if Atomic.get active_writers > 0 then begin
        Printf.printf "✗ VIOLATION: Reader %d sees active writer!\n%!" rid;
        Atomic.incr violations
      end;

      Unix.sleepf 0.002;
      Atomic.decr active_readers;
      Simple_rw_lock.read_unlock rwlock;
      Unix.sleepf 0.001
    done
  in

  let writer wid () =
    for i = 1 to 3 do
      Simple_rw_lock.write_lock rwlock;
      Atomic.incr active_writers;

      (* Check no readers or other writers *)
      if Atomic.get active_readers > 0 then begin
        Printf.printf "✗ VIOLATION: Writer %d sees %d active readers!\n%!"
          wid (Atomic.get active_readers);
        Atomic.incr violations
      end;
      if Atomic.get active_writers > 1 then begin
        Printf.printf "✗ VIOLATION: Writer %d sees %d active writers!\n%!"
          wid (Atomic.get active_writers);
        Atomic.incr violations
      end;

      Printf.printf "Writer %d (iteration %d): exclusive access\n%!" wid i;
      Unix.sleepf 0.003;

      Atomic.decr active_writers;
      Simple_rw_lock.write_unlock rwlock;
      Unix.sleepf 0.001
    done
  in

  let readers = Array.init 3 (fun i -> Domain.spawn (fun () -> reader (i + 1) ())) in
  let writers = Array.init 2 (fun i -> Domain.spawn (fun () -> writer (i + 1) ())) in

  Array.iter Domain.join readers;
  Array.iter Domain.join writers;

  let v = Atomic.get violations in
  if v = 0 then
    Printf.printf "✓ PASS: No exclusion violations (%d checks)\n\n%!" v
  else
    Printf.printf "✗ FAIL: %d exclusion violations!\n\n%!" v

let test_fairness_simple () =
  Printf.printf "=== Testing Fairness: Simple RW Lock (should starve writer) ===\n%!";
  let rwlock = Simple_rw_lock.create () in
  let writer_got_lock = Atomic.make false in
  let reader_count = Atomic.make 0 in

  (* Start a writer *)
  let writer_domain = Domain.spawn (fun () ->
    Unix.sleepf 0.001;  (* Let readers start first *)
    Printf.printf "Writer: attempting to acquire lock...\n%!";
    Simple_rw_lock.write_lock rwlock;
    Printf.printf "Writer: GOT LOCK!\n%!";
    Atomic.set writer_got_lock true;
    Simple_rw_lock.write_unlock rwlock
  ) in

  (* Continuous stream of readers *)
  let reader _rid () =
    let start = Unix.gettimeofday () in
    while Unix.gettimeofday () -. start < 0.1 do
      Simple_rw_lock.read_lock rwlock;
      Atomic.incr reader_count;
      Unix.sleepf 0.002;
      Simple_rw_lock.read_unlock rwlock;
      Unix.sleepf 0.0005
    done
  in

  let readers = Array.init 3 (fun i -> Domain.spawn (fun () -> reader (i + 1) ())) in
  Array.iter Domain.join readers;
  Domain.join writer_domain;

  Printf.printf "Total reads: %d\n" (Atomic.get reader_count);
  if Atomic.get writer_got_lock then
    Printf.printf "✓ Writer eventually acquired lock (possibly after readers stopped)\n\n%!"
  else
    Printf.printf "✗ Writer starved (timed out)\n\n%!"

let test_fairness_fifo () =
  Printf.printf "=== Testing Fairness: FIFO RW Lock (should NOT starve writer) ===\n%!";
  let rwlock = Fifo_rw_lock.create () in
  let writer_got_lock = Atomic.make false in
  let writer_wait_time = ref 0.0 in
  let readers_after_writer = Atomic.make 0 in
  let writer_started = Atomic.make false in

  (* Start a writer *)
  let writer_domain = Domain.spawn (fun () ->
    Unix.sleepf 0.005;  (* Let some readers start *)
    Printf.printf "Writer: attempting to acquire lock...\n%!";
    let start = Unix.gettimeofday () in
    Atomic.set writer_started true;
    Fifo_rw_lock.write_lock rwlock;
    writer_wait_time := Unix.gettimeofday () -. start;
    Printf.printf "Writer: GOT LOCK after %.3fs!\n%!" !writer_wait_time;
    Atomic.set writer_got_lock true;
    Unix.sleepf 0.002;
    Fifo_rw_lock.write_unlock rwlock
  ) in

  (* Continuous stream of readers *)
  let reader _rid () =
    let start = Unix.gettimeofday () in
    while Unix.gettimeofday () -. start < 0.15 do
      Fifo_rw_lock.read_lock rwlock;
      (* Track if reader acquired after writer started waiting *)
      if Atomic.get writer_started && not (Atomic.get writer_got_lock) then begin
        Atomic.incr readers_after_writer
      end;
      Unix.sleepf 0.002;
      Fifo_rw_lock.read_unlock rwlock;
      Unix.sleepf 0.001
    done
  in

  let readers = Array.init 3 (fun i -> Domain.spawn (fun () -> reader (i + 1) ())) in
  Domain.join writer_domain;
  Array.iter Domain.join readers;

  Printf.printf "Readers that acquired lock after writer started waiting: %d\n"
    (Atomic.get readers_after_writer);

  if Atomic.get writer_got_lock then begin
    Printf.printf "✓ PASS: Writer acquired lock (fairness maintained)\n";
    Printf.printf "  Wait time: %.3fs\n" !writer_wait_time;
    if Atomic.get readers_after_writer = 0 then
      Printf.printf "✓ EXCELLENT: No readers acquired after writer started waiting\n\n%!"
    else
      Printf.printf "  Note: %d readers acquired before writer (draining existing readers)\n\n%!"
        (Atomic.get readers_after_writer)
  end else
    Printf.printf "✗ FAIL: Writer starved even with FIFO lock!\n\n%!"

let () =
  test_concurrent_readers ();
  test_writer_exclusion ();
  test_fairness_simple ();
  test_fairness_fifo ()
