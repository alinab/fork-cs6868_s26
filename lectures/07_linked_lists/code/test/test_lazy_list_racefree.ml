(** Tests for race-free LazyList *)

let test_sequential () =
  let list = Lazy_list_racefree.create () in

  (* Test add *)
  assert (Lazy_list_racefree.add list 5 = true);
  assert (Lazy_list_racefree.add list 10 = true);
  assert (Lazy_list_racefree.add list 3 = true);

  (* Test duplicate add *)
  assert (Lazy_list_racefree.add list 5 = false);

  (* Test contains *)
  assert (Lazy_list_racefree.contains list 5 = true);
  assert (Lazy_list_racefree.contains list 10 = true);
  assert (Lazy_list_racefree.contains list 3 = true);
  assert (Lazy_list_racefree.contains list 7 = false);

  (* Test remove *)
  assert (Lazy_list_racefree.remove list 5 = true);
  assert (Lazy_list_racefree.contains list 5 = false);
  assert (Lazy_list_racefree.remove list 5 = false);

  (* Remaining elements *)
  assert (Lazy_list_racefree.contains list 10 = true);
  assert (Lazy_list_racefree.contains list 3 = true);

  print_endline "Sequential test passed!"

let test_concurrent () =
  let list = Lazy_list_racefree.create () in
  let n_domains = 8 in
  let ops_per_domain = 100 in

  let work id =
    for i = 0 to ops_per_domain - 1 do
      let value = id * ops_per_domain + i in
      ignore (Lazy_list_racefree.add list value);
      if i mod 2 = 0 then
        ignore (Lazy_list_racefree.remove list value);
    done
  in

  let domains = Array.init n_domains (fun id -> Domain.spawn (fun () -> work id)) in
  Array.iter Domain.join domains;

  (* Verify odd numbers are still there *)
  for id = 0 to n_domains - 1 do
    for i = 0 to ops_per_domain - 1 do
      let value = id * ops_per_domain + i in
      let expected = i mod 2 <> 0 in
      assert (Lazy_list_racefree.contains list value = expected)
    done
  done;

  print_endline "Concurrent test passed!"

let test_strings () =
  let list = Lazy_list_racefree.create () in

  assert (Lazy_list_racefree.add list "hello" = true);
  assert (Lazy_list_racefree.add list "world" = true);
  assert (Lazy_list_racefree.add list "ocaml" = true);

  assert (Lazy_list_racefree.contains list "hello" = true);
  assert (Lazy_list_racefree.contains list "world" = true);
  assert (Lazy_list_racefree.contains list "ocaml" = true);
  assert (Lazy_list_racefree.contains list "rust" = false);

  assert (Lazy_list_racefree.remove list "world" = true);
  assert (Lazy_list_racefree.contains list "world" = false);

  print_endline "String test passed!"

let test_high_contention () =
  let list = Lazy_list_racefree.create () in
  let n_domains = 16 in
  let range = 100 in  (* small range = high contention *)

  (* Add initial elements *)
  for i = 0 to range - 1 do
    ignore (Lazy_list_racefree.add list i)
  done;

  (* Concurrent add/remove/contains on same range *)
  let work _id =
    for _iter = 0 to 1000 do
      let value = Random.int range in
      match Random.int 3 with
      | 0 -> ignore (Lazy_list_racefree.add list value)
      | 1 -> ignore (Lazy_list_racefree.remove list value)
      | _ -> ignore (Lazy_list_racefree.contains list value)
    done
  in

  let domains = Array.init n_domains (fun id -> Domain.spawn (fun () -> work id)) in
  Array.iter Domain.join domains;

  print_endline "High contention test passed!"

let () =
  test_sequential ();
  test_concurrent ();
  test_strings ();
  test_high_contention ();
  print_endline "All lazy_list_racefree tests passed!"
