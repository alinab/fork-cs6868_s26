(* test_ttas.ml
 *
 * Simple test for TTAS Lock
 *)

let test_ttas_lock () =
  Printf.printf "=== TTAS Lock Test ===\n%!";
  Printf.printf "Testing basic lock/unlock functionality\n\n%!";

  let lock = Spinlocks.TTASLock.TTASLock.create () in
  let counter = ref 0 in
  let iterations = 10000 in

  let thread_work id =
    for _ = 1 to iterations do
      Spinlocks.TTASLock.TTASLock.lock lock;
      (* Critical section *)
      let old_value = !counter in
      counter := old_value + 1;
      Spinlocks.TTASLock.TTASLock.unlock lock
    done;
    Printf.printf "Thread %d completed %d iterations\n%!" id iterations
  in

  let num_threads = 4 in
  Printf.printf "Spawning %d threads, each doing %d increments\n%!" num_threads
    iterations;

  let start_time = Unix.gettimeofday () in

  let domains =
    List.init num_threads (fun i -> Domain.spawn (fun () -> thread_work i))
  in

  List.iter Domain.join domains;

  let end_time = Unix.gettimeofday () in
  let elapsed = end_time -. start_time in

  Printf.printf "\nExpected count: %d\n%!" (num_threads * iterations);
  Printf.printf "Actual count:   %d\n%!" !counter;
  Printf.printf "Time elapsed:   %.3f seconds\n%!" elapsed;

  if !counter = num_threads * iterations then
    Printf.printf "✓ Success: TTAS Lock works correctly!\n%!"
  else
    Printf.printf "✗ Failed: Lost %d increments\n%!"
      ((num_threads * iterations) - !counter)

let () = test_ttas_lock ()
