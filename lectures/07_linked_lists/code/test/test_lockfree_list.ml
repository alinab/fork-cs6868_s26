(** Basic tests for LockFreeList *)

let test_sequential () =
  let list = Lockfree_list.create () in

  (* Test add *)
  assert (Lockfree_list.add list 5 = true);
  assert (Lockfree_list.add list 10 = true);
  assert (Lockfree_list.add list 3 = true);

  (* Test duplicate add *)
  assert (Lockfree_list.add list 5 = false);

  (* Test contains *)
  assert (Lockfree_list.contains list 5 = true);
  assert (Lockfree_list.contains list 10 = true);
  assert (Lockfree_list.contains list 3 = true);
  assert (Lockfree_list.contains list 7 = false);

  (* Test remove *)
  assert (Lockfree_list.remove list 5 = true);
  assert (Lockfree_list.contains list 5 = false);
  assert (Lockfree_list.remove list 5 = false);

  (* Remaining elements *)
  assert (Lockfree_list.contains list 10 = true);
  assert (Lockfree_list.contains list 3 = true);

  print_endline "Sequential test passed!"

let test_concurrent () =
  let list = Lockfree_list.create () in
  let n_domains = 4 in
  let ops_per_domain = 100 in

  let work id =
    for i = 0 to ops_per_domain - 1 do
      let value = id * ops_per_domain + i in
      ignore (Lockfree_list.add list value);
      if i mod 2 = 0 then
        ignore (Lockfree_list.remove list value);
    done
  in

  let domains = Array.init n_domains (fun id -> Domain.spawn (fun () -> work id)) in
  Array.iter Domain.join domains;

  (* Verify odd numbers are still there *)
  for id = 0 to n_domains - 1 do
    for i = 0 to ops_per_domain - 1 do
      let value = id * ops_per_domain + i in
      let expected = i mod 2 <> 0 in
      assert (Lockfree_list.contains list value = expected)
    done
  done;

  print_endline "Concurrent test passed!"

let test_strings () =
  let list = Lockfree_list.create () in

  assert (Lockfree_list.add list "hello" = true);
  assert (Lockfree_list.add list "world" = true);
  assert (Lockfree_list.add list "ocaml" = true);

  assert (Lockfree_list.contains list "hello" = true);
  assert (Lockfree_list.contains list "world" = true);
  assert (Lockfree_list.contains list "ocaml" = true);
  assert (Lockfree_list.contains list "rust" = false);

  assert (Lockfree_list.remove list "world" = true);
  assert (Lockfree_list.contains list "world" = false);

  print_endline "String test passed!"

let test_high_contention () =
  let list = Lockfree_list.create () in
  let n_domains = 8 in
  let n_ops = 1000 in

  (* All threads operate on same small set of keys - high contention *)
  let worker () =
    for _ = 1 to n_ops do
      let key = Random.int 10 in
      match Random.int 3 with
      | 0 -> ignore (Lockfree_list.add list key)
      | 1 -> ignore (Lockfree_list.remove list key)
      | _ -> ignore (Lockfree_list.contains list key)
    done
  in

  let domains = Array.init n_domains (fun _ -> Domain.spawn worker) in
  Array.iter Domain.join domains;

  print_endline "High contention test passed!"

let () =
  Random.self_init ();
  test_sequential ();
  test_concurrent ();
  test_strings ();
  test_high_contention ();
  print_endline "All lockfree_list tests passed!"
