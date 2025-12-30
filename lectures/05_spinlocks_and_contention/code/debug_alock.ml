(* debug_alock.ml - Simple debug test for ALock *)

let test_simple () =
  Printf.printf "=== Simple ALock Debug Test ===\n%!";
  
  (* Create lock with small capacity to see what happens *)
  let lock = Spinlocks.ALock.ALock.create_with_capacity 4 in
  let counter = ref 0 in
  
  Printf.printf "Test 1: Single thread, multiple acquisitions\n%!";
  for i = 1 to 5 do
    Printf.printf "  Iteration %d: locking...\n%!" i;
    Spinlocks.ALock.ALock.lock lock;
    Printf.printf "  Iteration %d: got lock, counter=%d\n%!" i !counter;
    counter := !counter + 1;
    Printf.printf "  Iteration %d: unlocking...\n%!" i;
    Spinlocks.ALock.ALock.unlock lock;
    Printf.printf "  Iteration %d: unlocked\n%!" i;
  done;
  
  Printf.printf "\nFinal counter: %d (expected 5)\n%!" !counter;
  
  if !counter = 5 then
    Printf.printf "✓ Single thread test passed\n%!"
  else
    Printf.printf "✗ Single thread test failed\n%!"

let () = test_simple ()
