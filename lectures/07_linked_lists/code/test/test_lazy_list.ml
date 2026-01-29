(** Basic tests for LazyList *)

let test_sequential () =
  let list = Lazy_list.create () in

  (* Test add *)
  assert (Lazy_list.add list 5 = true);
  assert (Lazy_list.add list 10 = true);
  assert (Lazy_list.add list 3 = true);

  (* Test duplicate add *)
  assert (Lazy_list.add list 5 = false);

  (* Test contains *)
  assert (Lazy_list.contains list 5 = true);
  assert (Lazy_list.contains list 10 = true);
  assert (Lazy_list.contains list 3 = true);
  assert (Lazy_list.contains list 7 = false);

  (* Test remove *)
  assert (Lazy_list.remove list 5 = true);
  assert (Lazy_list.contains list 5 = false);
  assert (Lazy_list.remove list 5 = false);

  (* Remaining elements *)
  assert (Lazy_list.contains list 10 = true);
  assert (Lazy_list.contains list 3 = true);

  print_endline "Sequential test passed!"

let test_concurrent () =
  let list = Lazy_list.create () in
  let n_domains = 4 in
  let ops_per_domain = 100 in

  let work id =
    for i = 0 to ops_per_domain - 1 do
      let value = id * ops_per_domain + i in
      ignore (Lazy_list.add list value);
      if i mod 2 = 0 then
        ignore (Lazy_list.remove list value);
    done
  in

  let domains = Array.init n_domains (fun id -> Domain.spawn (fun () -> work id)) in
  Array.iter Domain.join domains;

  (* Verify odd numbers are still there *)
  for id = 0 to n_domains - 1 do
    for i = 0 to ops_per_domain - 1 do
      let value = id * ops_per_domain + i in
      let expected = i mod 2 <> 0 in
      assert (Lazy_list.contains list value = expected)
    done
  done;

  print_endline "Concurrent test passed!"

let test_strings () =
  let list = Lazy_list.create () in

  assert (Lazy_list.add list "hello" = true);
  assert (Lazy_list.add list "world" = true);
  assert (Lazy_list.add list "ocaml" = true);

  assert (Lazy_list.contains list "hello" = true);
  assert (Lazy_list.contains list "world" = true);
  assert (Lazy_list.contains list "ocaml" = true);
  assert (Lazy_list.contains list "rust" = false);

  assert (Lazy_list.remove list "world" = true);
  assert (Lazy_list.contains list "world" = false);

  print_endline "String test passed!"

let test_wait_free_contains () =
  let list = Lazy_list.create () in

  (* Add some elements *)
  for i = 0 to 99 do
    ignore (Lazy_list.add list i)
  done;

  (* Concurrent contains operations should be wait-free *)
  let n_readers = 8 in
  let reads_per_reader = 1000 in

  let reader () =
    for _ = 1 to reads_per_reader do
      let value = Random.int 100 in
      ignore (Lazy_list.contains list value)
    done
  in

  let readers = Array.init n_readers (fun _ -> Domain.spawn reader) in
  Array.iter Domain.join readers;

  print_endline "Wait-free contains test passed!"

let () =
  test_sequential ();
  test_concurrent ();
  test_strings ();
  test_wait_free_contains ();
  print_endline "All lazy_list tests passed!"
