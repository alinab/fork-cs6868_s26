(** Test specifically for the read_lock deadlock bug *)

let test_fifo_deadlock_scenario () =
  Printf.printf "=== Testing FIFO Deadlock Scenario ===\n%!";
  Printf.printf "Scenario: Reader A in CS, Writer waits, Reader B tries to enter\n\n%!";

  let rwlock = Fifo_rw_lock.create () in
  let reader_a_entered = Atomic.make false in
  let writer_waiting = Atomic.make false in
  let reader_b_trying = Atomic.make false in
  let reader_b_entered = Atomic.make false in
  let writer_entered = Atomic.make false in
  let deadlock_detected = Atomic.make false in

  (* Reader A: Acquire lock and hold it *)
  let reader_a = Domain.spawn (fun () ->
    Printf.printf "Reader A: acquiring lock...\n%!";
    Fifo_rw_lock.read_lock rwlock;
    Atomic.set reader_a_entered true;
    Printf.printf "Reader A: GOT LOCK, holding for 0.1s\n%!";
    Unix.sleepf 0.1;  (* Hold long enough for Writer to start *)
    Printf.printf "Reader A: releasing lock\n%!";
    Fifo_rw_lock.read_unlock rwlock;
    Printf.printf "Reader A: released\n%!"
  ) in

  (* Wait for Reader A to acquire *)
  while not (Atomic.get reader_a_entered) do
    Unix.sleepf 0.001
  done;

  (* Writer: Try to acquire while Reader A is holding *)
  let writer = Domain.spawn (fun () ->
    Unix.sleepf 0.01;  (* Small delay to ensure Reader A has lock *)
    Printf.printf "Writer: attempting to acquire lock...\n%!";
    Atomic.set writer_waiting true;
    let start = Unix.gettimeofday () in
    Fifo_rw_lock.write_lock rwlock;
    let elapsed = Unix.gettimeofday () -. start in
    Atomic.set writer_entered true;
    Printf.printf "Writer: GOT LOCK after %.3fs\n%!" elapsed;
    Fifo_rw_lock.write_unlock rwlock;
    Printf.printf "Writer: released\n%!"
  ) in

  (* Wait for writer to start waiting *)
  while not (Atomic.get writer_waiting) do
    Unix.sleepf 0.001
  done;
  Unix.sleepf 0.02;  (* Give writer time to set writer=true *)

  (* Reader B: Try to acquire WHILE writer is waiting *)
  let reader_b = Domain.spawn (fun () ->
    Printf.printf "Reader B: attempting to acquire lock (while writer waits)...\n%!";
    Atomic.set reader_b_trying true;
    let start = Unix.gettimeofday () in
    Fifo_rw_lock.read_lock rwlock;
    let elapsed = Unix.gettimeofday () -. start in
    Atomic.set reader_b_entered true;
    Printf.printf "Reader B: GOT LOCK after %.3fs\n%!" elapsed;
    Fifo_rw_lock.read_unlock rwlock;
    Printf.printf "Reader B: released\n%!"
  ) in

  (* Deadlock detector: Check if system makes progress *)
  let detector = Domain.spawn (fun () ->
    Unix.sleepf 1.0;  (* Wait 1 second *)
    if not (Atomic.get writer_entered) || not (Atomic.get reader_b_entered) then begin
      Printf.printf "\n✗✗✗ DEADLOCK DETECTED ✗✗✗\n%!";
      Printf.printf "  Reader A entered: true\n%!";
      Printf.printf "  Writer waiting: %b\n%!" (Atomic.get writer_waiting);
      Printf.printf "  Writer entered: %b\n%!" (Atomic.get writer_entered);
      Printf.printf "  Reader B trying: %b\n%!" (Atomic.get reader_b_trying);
      Printf.printf "  Reader B entered: %b\n%!" (Atomic.get reader_b_entered);
      Atomic.set deadlock_detected true;
      exit 1  (* Force exit since we can't join deadlocked threads *)
    end
  ) in

  (* Join all threads *)
  let timeout = ref false in
  begin try
    Domain.join reader_a;
    Domain.join writer;
    Domain.join reader_b;
    Domain.join detector
  with _ ->
    timeout := true
  end;

  if !timeout || Atomic.get deadlock_detected then begin
    Printf.printf "\n✗ FAIL: System deadlocked or timed out!\n\n%!";
    exit 1
  end else begin
    Printf.printf "\n✓ PASS: No deadlock - all threads completed\n";
    Printf.printf "  Reader A → Writer → Reader B (correct ordering)\n\n%!"
  end

let () = test_fifo_deadlock_scenario ()
