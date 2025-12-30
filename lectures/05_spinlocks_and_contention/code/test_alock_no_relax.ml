(* test_alock_no_relax.ml - Test ALock without cpu_relax *)

let () =
  let threads = 16 in
  let iterations = 10000 in

  Printf.printf "=== ALock WITHOUT cpu_relax ===\n\n%!";
  Printf.printf "Threads: %d, Iterations: %d\n\n%!" threads iterations;

  let lock = Spinlocks.ALockNoCpuRelax.create_with_capacity threads in
  let counter = ref 0 in

  let thread_work id =
    for i = 1 to iterations do
      Spinlocks.ALockNoCpuRelax.lock lock;
      counter := !counter + 1;
      Spinlocks.ALockNoCpuRelax.unlock lock;
      
      (* Print progress every 1000 iterations *)
      if i mod 1000 = 0 then
        Printf.printf "Thread %d: completed %d iterations\n%!" id i
    done;
    Printf.printf "Thread %d: FINISHED\n%!" id
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
