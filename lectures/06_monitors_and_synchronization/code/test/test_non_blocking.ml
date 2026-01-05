(** Test the non-blocking queue with concurrent operations *)

let test_concurrent () =
  Printf.printf "=== Testing Concurrent Non-Blocking Queue ===\n%!";
  Printf.printf "Note: This queue raises exceptions instead of waiting\n\n%!";

  let q = Queue_non_blocking.create 3 in
  let producers = 2 in
  let consumers = 2 in
  let items_per_domain = 10 in

  let full_errors = Atomic.make 0 in
  let empty_errors = Atomic.make 0 in

  let producer pid () =
    for i = 1 to items_per_domain do
      let v = (pid * 100) + i in
      let rec retry () =
        try
          Queue_non_blocking.enq q v;
          Printf.printf "Producer %d: enq(%d)\n%!" pid v
        with Queue_non_blocking.Full ->
          Atomic.incr full_errors;
          Printf.printf "Producer %d: FULL exception on enq(%d), retrying...\n%!" pid v;
          Domain.cpu_relax ();
          retry ()
      in
      retry ()
    done
  in

  let consumer cid () =
    for _ = 1 to items_per_domain do
      let rec retry () =
        try
          let v = Queue_non_blocking.deq q in
          Printf.printf "Consumer %d: deq() → %d\n%!" cid v;
          v
        with Queue_non_blocking.Empty ->
          Atomic.incr empty_errors;
          Printf.printf "Consumer %d: EMPTY exception, retrying...\n%!" cid;
          Domain.cpu_relax ();
          retry ()
      in
      let _ = retry () in ()
    done
  in

  let producer_domains =
    Array.init producers (fun pid -> Domain.spawn (fun () -> producer (pid + 1) ()))
  in
  let consumer_domains =
    Array.init consumers (fun cid -> Domain.spawn (fun () -> consumer (cid + 1) ()))
  in

  Array.iter Domain.join producer_domains;
  Array.iter Domain.join consumer_domains;

  Printf.printf "\n✓ All operations completed\n%!";
  Printf.printf "  Full exceptions: %d\n%!" (Atomic.get full_errors);
  Printf.printf "  Empty exceptions: %d\n%!" (Atomic.get empty_errors);
  Printf.printf "  (Exceptions show the queue doesn't wait - it fails immediately)\n%!"

let () = test_concurrent ()
