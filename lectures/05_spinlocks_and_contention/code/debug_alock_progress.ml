(* debug_alock_progress.ml - Debug ALock to see if it makes progress *)

let () =
  let threads = ref 16 in
  let iterations = ref 10000 in

  let usage = "Usage: debug_alock_progress [--threads N] [--iterations N]" in
  let specs =
    [
      ("--threads", Arg.Set_int threads, "Number of threads (default: 16)");
      ( "--iterations",
        Arg.Set_int iterations,
        "Iterations per thread (default: 10000)" );
    ]
  in

  Arg.parse specs (fun _ -> ()) usage;

  Printf.printf "=== ALock Progress Debug ===\n\n%!";
  Printf.printf "Testing with %d threads × %d iterations\n" !threads !iterations;
  Printf.printf "Will print progress every 1000 iterations per thread\n\n%!";

  let lock = Spinlocks.ALock.ALock.create_with_capacity !threads in
  let counter = ref 0 in
  let progress_interval = 1000 in

  let thread_work id =
    for i = 1 to !iterations do
      Spinlocks.ALock.ALock.lock lock;
      counter := !counter + 1;
      Spinlocks.ALock.ALock.unlock lock;
      
      (* Print progress every N iterations *)
      if i mod progress_interval = 0 then
        Printf.printf "Thread %d: completed %d iterations (counter=%d)\n%!" 
          id i !counter
    done;
    Printf.printf "Thread %d: FINISHED all %d iterations\n%!" id !iterations
  in

  let start_time = Unix.gettimeofday () in

  let domains =
    List.init !threads (fun i -> Domain.spawn (fun () -> thread_work i))
  in

  List.iter Domain.join domains;

  let end_time = Unix.gettimeofday () in
  let elapsed = end_time -. start_time in

  Printf.printf "\nAll threads completed!\n";
  Printf.printf "Expected count: %d\n%!" (!threads * !iterations);
  Printf.printf "Actual count:   %d\n%!" !counter;
  Printf.printf "Time elapsed:   %.3f seconds\n%!" elapsed;

  if !counter = !threads * !iterations then
    Printf.printf "✓ Success!\n%!"
  else
    Printf.printf "✗ Failed: Lost %d increments\n%!"
      ((!threads * !iterations) - !counter)
