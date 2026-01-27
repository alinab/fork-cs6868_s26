(** Test suite for Sequential List *)

let test_sequential () =
  Printf.printf "Testing sequential list operations...\n%!";
  let list = Seq_list.create () in

  (* Test adding elements *)
  assert (Seq_list.add list 10 = true);
  assert (Seq_list.add list 20 = true);
  assert (Seq_list.add list 30 = true);
  assert (Seq_list.add list 20 = false); (* duplicate *)

  (* Test contains *)
  assert (Seq_list.contains list 10 = true);
  assert (Seq_list.contains list 20 = true);
  assert (Seq_list.contains list 30 = true);
  assert (Seq_list.contains list 40 = false);

  (* Test remove *)
  assert (Seq_list.remove list 20 = true);
  assert (Seq_list.contains list 20 = false);
  assert (Seq_list.remove list 20 = false); (* already removed *)

  (* Verify other elements still present *)
  assert (Seq_list.contains list 10 = true);
  assert (Seq_list.contains list 30 = true);

  Printf.printf "Sequential list tests passed!\n%!"

let test_string_elements () =
  Printf.printf "Testing with string elements...\n%!";
  let list = Seq_list.create () in

  assert (Seq_list.add list "hello" = true);
  assert (Seq_list.add list "world" = true);
  assert (Seq_list.add list "ocaml" = true);
  assert (Seq_list.add list "hello" = false);

  assert (Seq_list.contains list "hello" = true);
  assert (Seq_list.contains list "world" = true);
  assert (Seq_list.contains list "rust" = false);

  assert (Seq_list.remove list "world" = true);
  assert (Seq_list.contains list "world" = false);

  Printf.printf "String element tests passed!\n%!"

let () =
  Printf.printf "=== Sequential List Tests ===\n%!";
  test_sequential ();
  test_string_elements ();
  Printf.printf "=== All tests passed! ===\n%!"
