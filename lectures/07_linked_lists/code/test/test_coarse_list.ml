(** Test suite for CoarseList *)

let test_sequential () =
  Printf.printf "Testing sequential operations...\n%!";
  let list = Coarse_list.create () in

  (* Test adding elements *)
  assert (Coarse_list.add list 10 = true);
  assert (Coarse_list.add list 20 = true);
  assert (Coarse_list.add list 30 = true);
  assert (Coarse_list.add list 20 = false); (* duplicate *)

  (* Test contains *)
  assert (Coarse_list.contains list 10 = true);
  assert (Coarse_list.contains list 20 = true);
  assert (Coarse_list.contains list 30 = true);
  assert (Coarse_list.contains list 40 = false);

  (* Test remove *)
  assert (Coarse_list.remove list 20 = true);
  assert (Coarse_list.contains list 20 = false);
  assert (Coarse_list.remove list 20 = false); (* already removed *)

  (* Verify other elements still present *)
  assert (Coarse_list.contains list 10 = true);
  assert (Coarse_list.contains list 30 = true);

  Printf.printf "Sequential tests passed!\n%!"

let test_concurrent () =
  Printf.printf "Testing concurrent operations...\n%!";
  let list = Coarse_list.create () in
  let num_domains = 4 in
  let ops_per_domain = 1000 in

  (* Each domain adds and removes its own range of numbers *)
  let worker id =
    let start = id * ops_per_domain in
    let finish = start + ops_per_domain in

    (* Add all numbers in range *)
    for i = start to finish - 1 do
      ignore (Coarse_list.add list i)
    done;

    (* Remove half of them *)
    for i = start to start + (ops_per_domain / 2) - 1 do
      ignore (Coarse_list.remove list i)
    done;

    (* Check the other half are present *)
    for i = start + (ops_per_domain / 2) to finish - 1 do
      assert (Coarse_list.contains list i)
    done
  in

  let domains = List.init num_domains (fun id ->
    Domain.spawn (fun () -> worker id)
  ) in

  List.iter Domain.join domains;

  Printf.printf "Concurrent tests passed!\n%!"

let test_string_elements () =
  Printf.printf "Testing with string elements...\n%!";
  let list = Coarse_list.create () in

  assert (Coarse_list.add list "hello" = true);
  assert (Coarse_list.add list "world" = true);
  assert (Coarse_list.add list "ocaml" = true);
  assert (Coarse_list.add list "hello" = false);

  assert (Coarse_list.contains list "hello" = true);
  assert (Coarse_list.contains list "world" = true);
  assert (Coarse_list.contains list "rust" = false);

  assert (Coarse_list.remove list "world" = true);
  assert (Coarse_list.contains list "world" = false);

  Printf.printf "String element tests passed!\n%!"

let () =
  Printf.printf "=== CoarseList Tests ===\n%!";
  test_sequential ();
  test_concurrent ();
  test_string_elements ();
  Printf.printf "=== All tests passed! ===\n%!"
