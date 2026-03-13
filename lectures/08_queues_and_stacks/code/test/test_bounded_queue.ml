(** Test suite for BoundedQueue *)

let test_sequential () =
  Printf.printf "Testing sequential operations...\n%!";
  let q = Bounded_queue.create 5 in

  (* Test basic enqueue and dequeue *)
  Bounded_queue.enq q 1;
  Bounded_queue.enq q 2;
  Bounded_queue.enq q 3;

  (* FIFO order *)
  assert (Bounded_queue.deq q = 1);
  assert (Bounded_queue.deq q = 2);
  assert (Bounded_queue.deq q = 3);

  Printf.printf "Sequential tests passed!\n%!"

let test_try_operations () =
  Printf.printf "Testing try_enq/try_deq operations...\n%!";
  let q = Bounded_queue.create 2 in

  (* Empty queue: try_deq returns None *)
  assert (Bounded_queue.try_deq q = None);

  (* Fill the queue *)
  assert (Bounded_queue.try_enq q 10 = true);
  assert (Bounded_queue.try_enq q 20 = true);

  (* Full queue: try_enq returns false *)
  assert (Bounded_queue.try_enq q 30 = false);

  (* Dequeue in FIFO order *)
  assert (Bounded_queue.try_deq q = Some 10);
  assert (Bounded_queue.try_deq q = Some 20);

  (* Empty again *)
  assert (Bounded_queue.try_deq q = None);

  Printf.printf "Try operations tests passed!\n%!"

let test_capacity_one () =
  Printf.printf "Testing capacity-1 queue...\n%!";
  let q = Bounded_queue.create 1 in

  Bounded_queue.enq q 42;
  assert (Bounded_queue.try_enq q 99 = false);
  assert (Bounded_queue.deq q = 42);
  assert (Bounded_queue.try_deq q = None);

  (* Reuse after drain *)
  Bounded_queue.enq q 100;
  assert (Bounded_queue.deq q = 100);

  Printf.printf "Capacity-1 tests passed!\n%!"

let test_fill_and_drain () =
  Printf.printf "Testing fill and drain...\n%!";
  let cap = 100 in
  let q = Bounded_queue.create cap in

  (* Fill to capacity *)
  for i = 0 to cap - 1 do
    assert (Bounded_queue.try_enq q i = true)
  done;
  assert (Bounded_queue.try_enq q 999 = false);

  (* Drain and verify FIFO *)
  for i = 0 to cap - 1 do
    assert (Bounded_queue.deq q = i)
  done;
  assert (Bounded_queue.try_deq q = None);

  Printf.printf "Fill and drain tests passed!\n%!"

let test_concurrent () =
  Printf.printf "Testing concurrent operations...\n%!";
  let q = Bounded_queue.create 64 in
  let num_producers = 4 in
  let num_consumers = 4 in
  let items_per_producer = 1000 in
  let total_items = num_producers * items_per_producer in

  (* Track which items were dequeued *)
  let seen = Array.make total_items false in
  let seen_lock = Mutex.create () in

  (* Producer: enqueue items in its range *)
  let producer id =
    let start = id * items_per_producer in
    for i = start to start + items_per_producer - 1 do
      Bounded_queue.enq q i
    done
  in

  (* Consumer: dequeue items until sentinel *)
  let consumed = Atomic.make 0 in
  let consumer () =
    while Atomic.get consumed < total_items do
      match Bounded_queue.try_deq q with
      | Some v ->
          Mutex.lock seen_lock;
          seen.(v) <- true;
          Mutex.unlock seen_lock;
          Atomic.incr consumed
      | None ->
          Domain.cpu_relax ()
    done
  in

  let producers = List.init num_producers (fun id ->
    Domain.spawn (fun () -> producer id)
  ) in
  let consumers = List.init num_consumers (fun _ ->
    Domain.spawn (fun () -> consumer ())
  ) in

  List.iter Domain.join producers;
  List.iter Domain.join consumers;

  (* Verify all items were dequeued exactly once *)
  Array.iteri (fun i v ->
    if not v then
      Printf.printf "MISSING item %d\n%!" i;
    assert v
  ) seen;

  Printf.printf "Concurrent tests passed!\n%!"

let test_blocking_behavior () =
  Printf.printf "Testing blocking behavior...\n%!";
  let q = Bounded_queue.create 1 in

  (* Producer blocks when full, consumer unblocks it *)
  let producer_done = Atomic.make false in
  let p = Domain.spawn (fun () ->
    Bounded_queue.enq q 1;
    Bounded_queue.enq q 2;  (* blocks until consumer dequeues *)
    Atomic.set producer_done true
  ) in

  (* Give producer time to block *)
  Unix.sleepf 0.05;

  (* Producer should have enqueued 1 but be blocked on 2 *)
  assert (Bounded_queue.deq q = 1);

  (* Now producer can finish *)
  Domain.join p;
  assert (Atomic.get producer_done);
  assert (Bounded_queue.deq q = 2);

  Printf.printf "Blocking behavior tests passed!\n%!"

let test_string_elements () =
  Printf.printf "Testing with string elements...\n%!";
  let q = Bounded_queue.create 3 in

  Bounded_queue.enq q "hello";
  Bounded_queue.enq q "world";
  Bounded_queue.enq q "ocaml";

  assert (Bounded_queue.deq q = "hello");
  assert (Bounded_queue.deq q = "world");
  assert (Bounded_queue.deq q = "ocaml");

  Printf.printf "String element tests passed!\n%!"

let () =
  Printf.printf "=== BoundedQueue Tests ===\n%!";
  test_sequential ();
  test_try_operations ();
  test_capacity_one ();
  test_fill_and_drain ();
  test_concurrent ();
  test_blocking_behavior ();
  test_string_elements ();
  Printf.printf "=== All tests passed! ===\n%!"
