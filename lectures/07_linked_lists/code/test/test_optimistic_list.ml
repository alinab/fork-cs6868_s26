(** Basic tests for OptimisticList *)

let test_sequential () =
  let list = Optimistic_list.create () in

  (* Test add *)
  assert (Optimistic_list.add list 5 = true);
  assert (Optimistic_list.add list 10 = true);
  assert (Optimistic_list.add list 3 = true);

  (* Test duplicate add *)
  assert (Optimistic_list.add list 5 = false);

  (* Test contains *)
  assert (Optimistic_list.contains list 5 = true);
  assert (Optimistic_list.contains list 10 = true);
  assert (Optimistic_list.contains list 3 = true);
  assert (Optimistic_list.contains list 7 = false);

  (* Test remove *)
  assert (Optimistic_list.remove list 5 = true);
  assert (Optimistic_list.contains list 5 = false);
  assert (Optimistic_list.remove list 5 = false);

  (* Remaining elements *)
  assert (Optimistic_list.contains list 10 = true);
  assert (Optimistic_list.contains list 3 = true);

  print_endline "Sequential test passed!"

let test_concurrent () =
  let list = Optimistic_list.create () in
  let n_domains = 4 in
  let ops_per_domain = 100 in

  let work id =
    for i = 0 to ops_per_domain - 1 do
      let value = id * ops_per_domain + i in
      ignore (Optimistic_list.add list value);
      if i mod 2 = 0 then
        ignore (Optimistic_list.remove list value);
    done
  in

  let domains = Array.init n_domains (fun id -> Domain.spawn (fun () -> work id)) in
  Array.iter Domain.join domains;

  (* Verify odd numbers are still there *)
  for id = 0 to n_domains - 1 do
    for i = 0 to ops_per_domain - 1 do
      let value = id * ops_per_domain + i in
      let expected = i mod 2 <> 0 in
      assert (Optimistic_list.contains list value = expected)
    done
  done;

  print_endline "Concurrent test passed!"

let test_strings () =
  let list = Optimistic_list.create () in

  assert (Optimistic_list.add list "hello" = true);
  assert (Optimistic_list.add list "world" = true);
  assert (Optimistic_list.add list "ocaml" = true);

  assert (Optimistic_list.contains list "hello" = true);
  assert (Optimistic_list.contains list "world" = true);
  assert (Optimistic_list.contains list "ocaml" = true);
  assert (Optimistic_list.contains list "rust" = false);

  assert (Optimistic_list.remove list "world" = true);
  assert (Optimistic_list.contains list "world" = false);

  print_endline "String test passed!"

let () =
  test_sequential ();
  test_concurrent ();
  test_strings ();
  print_endline "All optimistic_list tests passed!"
