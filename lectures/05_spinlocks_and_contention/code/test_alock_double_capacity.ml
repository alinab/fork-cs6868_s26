(* test_alock_double_capacity.ml - Test ALock with capacity = 2 * threads *)

let () =
  let threads = 16 in
  let iterations = 10000 in
  let capacity = threads * 2 in

  Printf.printf "=== ALock with Double Capacity ===\n\n%!";
  Printf.printf "Threads: %d, Capacity: %d, Iterations: %d\n\n%!" threads capacity iterations;

  let lock = Spinlocks.ALock.ALock.create_with_capacity capacity in
  let counter = ref 0 in

  let thread_work id =
    for _ = 1 to iterations do
      Spinlocks.ALock.ALock.lock lock;
      counter := !counter + 1;
      Spinlocks.ALock.ALock.unlock lock
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
    Printf.printf "✗ Failed\n%!"
