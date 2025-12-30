(* test_ttas_unsafe.ml - Test TTAS unsafe variant *)

let test_lock threads iterations =
  Printf.printf "=== TTAS Lock (unsafe) Test ===\n%!";
  Printf.printf "Testing with %d threads × %d iterations\n\n%!" threads iterations;

  let lock = Spinlocks.TTASLockUnsafe.create () in
  let counter = ref 0 in

  let thread_work id =
    for _ = 1 to iterations do
      Spinlocks.TTASLockUnsafe.lock lock;
      counter := !counter + 1;
      Spinlocks.TTASLockUnsafe.unlock lock
    done;
    Printf.printf "Thread %d completed\n%!" id
  in

  let start_time = Unix.gettimeofday () in

  let domains =
    List.init threads (fun i -> Domain.spawn (fun () -> thread_work i))
  in

  List.iter Domain.join domains;

  let end_time = Unix.gettimeofday () in
  let elapsed = end_time -. start_time in

  Printf.printf "\nExpected count: %d\n%!" (threads * iterations);
  Printf.printf "Actual count:   %d\n%!" !counter;
  Printf.printf "Time elapsed:   %.3f seconds\n%!" elapsed;
  Printf.printf "Throughput:     %.0f ops/sec\n%!" 
    (float_of_int (threads * iterations) /. elapsed);

  if !counter = threads * iterations then
    Printf.printf "✓ Success!\n%!"
  else
    Printf.printf "✗ Failed (data race detected)\n%!"

let () =
  let threads = ref 8 in
  let iterations = ref 10000 in

  let speclist = [
    ("--threads", Arg.Set_int threads, "Number of threads");
    ("--iterations", Arg.Set_int iterations, "Number of iterations per thread");
  ] in

  Arg.parse speclist (fun _ -> ()) "Usage: test_ttas_unsafe [options]";
  test_lock !threads !iterations
