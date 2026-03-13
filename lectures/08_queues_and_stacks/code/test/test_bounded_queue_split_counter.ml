(** Test suite for Bounded_queue_split_counter *)

let test_sequential () =
  Printf.printf "Testing sequential operations...\n%!";
  let q = Bounded_queue_split_counter.create 5 in

  Bounded_queue_split_counter.enq q 1;
  Bounded_queue_split_counter.enq q 2;
  Bounded_queue_split_counter.enq q 3;

  assert (Bounded_queue_split_counter.deq q = 1);
  assert (Bounded_queue_split_counter.deq q = 2);
  assert (Bounded_queue_split_counter.deq q = 3);

  Printf.printf "Sequential tests passed!\n%!"

let test_try_operations () =
  Printf.printf "Testing try_enq/try_deq operations...\n%!";
  let q = Bounded_queue_split_counter.create 2 in

  assert (Bounded_queue_split_counter.try_deq q = None);

  assert (Bounded_queue_split_counter.try_enq q 10 = true);
  assert (Bounded_queue_split_counter.try_enq q 20 = true);

  assert (Bounded_queue_split_counter.try_enq q 30 = false);

  assert (Bounded_queue_split_counter.try_deq q = Some 10);
  assert (Bounded_queue_split_counter.try_deq q = Some 20);

  assert (Bounded_queue_split_counter.try_deq q = None);

  Printf.printf "Try operations tests passed!\n%!"

let test_capacity_one () =
  Printf.printf "Testing capacity-1 queue...\n%!";
  let q = Bounded_queue_split_counter.create 1 in

  Bounded_queue_split_counter.enq q 42;
  assert (Bounded_queue_split_counter.try_enq q 99 = false);
  assert (Bounded_queue_split_counter.deq q = 42);
  assert (Bounded_queue_split_counter.try_deq q = None);

  Bounded_queue_split_counter.enq q 100;
  assert (Bounded_queue_split_counter.deq q = 100);

  Printf.printf "Capacity-1 tests passed!\n%!"

let test_fill_and_drain () =
  Printf.printf "Testing fill and drain...\n%!";
  let cap = 100 in
  let q = Bounded_queue_split_counter.create cap in

  for i = 0 to cap - 1 do
    assert (Bounded_queue_split_counter.try_enq q i = true)
  done;
  assert (Bounded_queue_split_counter.try_enq q 999 = false);

  for i = 0 to cap - 1 do
    assert (Bounded_queue_split_counter.deq q = i)
  done;
  assert (Bounded_queue_split_counter.try_deq q = None);

  Printf.printf "Fill and drain tests passed!\n%!"

let test_reconciliation_cycle () =
  Printf.printf "Testing reconciliation cycles...\n%!";
  let cap = 3 in
  let q = Bounded_queue_split_counter.create cap in

  (* Fill to capacity, forcing enq_side_size = capacity *)
  for i = 1 to cap do
    Bounded_queue_split_counter.enq q i
  done;

  (* Dequeue all — deq_side_size goes negative *)
  for i = 1 to cap do
    assert (Bounded_queue_split_counter.deq q = i)
  done;

  (* Enqueue again — triggers reconciliation when enq_side_size hits cap *)
  for i = 10 to 10 + cap - 1 do
    Bounded_queue_split_counter.enq q i
  done;
  (* And again, another cycle *)
  for i = 10 to 10 + cap - 1 do
    assert (Bounded_queue_split_counter.deq q = i)
  done;
  for i = 20 to 20 + cap - 1 do
    Bounded_queue_split_counter.enq q i
  done;
  for i = 20 to 20 + cap - 1 do
    assert (Bounded_queue_split_counter.deq q = i)
  done;

  Printf.printf "Reconciliation cycle tests passed!\n%!"

let test_concurrent () =
  Printf.printf "Testing concurrent operations...\n%!";
  let q = Bounded_queue_split_counter.create 64 in
  let num_producers = 4 in
  let num_consumers = 4 in
  let items_per_producer = 1000 in
  let total_items = num_producers * items_per_producer in

  let seen = Array.make total_items false in
  let seen_lock = Mutex.create () in

  let producer id =
    let start = id * items_per_producer in
    for i = start to start + items_per_producer - 1 do
      Bounded_queue_split_counter.enq q i
    done
  in

  let consumed = Atomic.make 0 in
  let consumer () =
    while Atomic.get consumed < total_items do
      match Bounded_queue_split_counter.try_deq q with
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

  Array.iteri (fun i v ->
    if not v then
      Printf.printf "MISSING item %d\n%!" i;
    assert v
  ) seen;

  Printf.printf "Concurrent tests passed!\n%!"

let test_blocking_behavior () =
  Printf.printf "Testing blocking behavior...\n%!";
  let q = Bounded_queue_split_counter.create 1 in

  let producer_done = Atomic.make false in
  let p = Domain.spawn (fun () ->
    Bounded_queue_split_counter.enq q 1;
    Bounded_queue_split_counter.enq q 2;
    Atomic.set producer_done true
  ) in

  Unix.sleepf 0.05;

  assert (Bounded_queue_split_counter.deq q = 1);

  Domain.join p;
  assert (Atomic.get producer_done);
  assert (Bounded_queue_split_counter.deq q = 2);

  Printf.printf "Blocking behavior tests passed!\n%!"

let test_concurrent_small_capacity () =
  Printf.printf "Testing concurrent with small capacity (forces reconciliation)...\n%!";
  let q = Bounded_queue_split_counter.create 2 in
  let items = 500 in

  let p = Domain.spawn (fun () ->
    for i = 0 to items - 1 do
      Bounded_queue_split_counter.enq q i
    done
  ) in

  let results = Array.make items 0 in
  for i = 0 to items - 1 do
    results.(i) <- Bounded_queue_split_counter.deq q
  done;

  Domain.join p;

  for i = 0 to items - 1 do
    assert (results.(i) = i)
  done;

  Printf.printf "Concurrent small capacity tests passed!\n%!"

let () =
  Printf.printf "=== Bounded_queue_split_counter Tests ===\n%!";
  test_sequential ();
  test_try_operations ();
  test_capacity_one ();
  test_fill_and_drain ();
  test_reconciliation_cycle ();
  test_concurrent ();
  test_blocking_behavior ();
  test_concurrent_small_capacity ();
  Printf.printf "=== All tests passed! ===\n%!"
