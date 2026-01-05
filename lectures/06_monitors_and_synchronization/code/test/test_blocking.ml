(** Test the blocking queue with concurrent operations *)

let test_concurrent () =
  Printf.printf "=== Testing Concurrent Blocking Queue ===\n%!";
  Printf.printf "Note: This queue blocks (waits) when full/empty\n\n%!";

  let q = Queue_blocking.create 3 in
  let producers = 2 in
  let consumers = 2 in
  let items_per_domain = 10 in

  let producer pid () =
    for i = 1 to items_per_domain do
      let v = (pid * 100) + i in
      Queue_blocking.enq q v;
      Printf.printf "Producer %d: enq(%d)\n%!" pid v
    done
  in

  let consumer cid () =
    for _ = 1 to items_per_domain do
      let v = Queue_blocking.deq q in
      Printf.printf "Consumer %d: deq() → %d\n%!" cid v
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

  Printf.printf "\n✓ All operations completed successfully\n%!";
  Printf.printf "  (No exceptions - threads waited using condition variables)\n%!"

let () = test_concurrent ()
