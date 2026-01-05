(** Test both read-write lock implementations *)

let test_simple_rwlock () =
  Printf.printf "=== Testing Simple RW Lock ===\n%!";
  let rwlock = Simple_rw_lock.create () in
  let shared_value = ref 0 in
  
  let reader rid () =
    for _ = 1 to 5 do
      Simple_rw_lock.read_lock rwlock;
      Printf.printf "Reader %d: read value = %d\n%!" rid !shared_value;
      Domain.cpu_relax ();  (* Simulate some read work *)
      Simple_rw_lock.read_unlock rwlock;
      Domain.cpu_relax ()
    done
  in
  
  let writer wid () =
    for i = 1 to 3 do
      Simple_rw_lock.write_lock rwlock;
      shared_value := wid * 100 + i;
      Printf.printf "Writer %d: wrote value = %d\n%!" wid !shared_value;
      Domain.cpu_relax ();  (* Simulate some write work *)
      Simple_rw_lock.write_unlock rwlock;
      Domain.cpu_relax ()
    done
  in
  
  let readers = Array.init 3 (fun i -> Domain.spawn (fun () -> reader (i + 1) ())) in
  let writers = Array.init 2 (fun i -> Domain.spawn (fun () -> writer (i + 1) ())) in
  
  Array.iter Domain.join readers;
  Array.iter Domain.join writers;
  
  Printf.printf "✓ Simple RW Lock test completed\n\n%!"

let test_fifo_rwlock () =
  Printf.printf "=== Testing FIFO RW Lock ===\n%!";
  let rwlock = Fifo_rw_lock.create () in
  let shared_value = ref 0 in
  
  let reader rid () =
    for _ = 1 to 5 do
      Fifo_rw_lock.read_lock rwlock;
      Printf.printf "Reader %d: read value = %d\n%!" rid !shared_value;
      Domain.cpu_relax ();
      Fifo_rw_lock.read_unlock rwlock;
      Domain.cpu_relax ()
    done
  in
  
  let writer wid () =
    for i = 1 to 3 do
      Fifo_rw_lock.write_lock rwlock;
      shared_value := wid * 100 + i;
      Printf.printf "Writer %d: wrote value = %d\n%!" wid !shared_value;
      Domain.cpu_relax ();
      Fifo_rw_lock.write_unlock rwlock;
      Domain.cpu_relax ()
    done
  in
  
  let readers = Array.init 3 (fun i -> Domain.spawn (fun () -> reader (i + 1) ())) in
  let writers = Array.init 2 (fun i -> Domain.spawn (fun () -> writer (i + 1) ())) in
  
  Array.iter Domain.join readers;
  Array.iter Domain.join writers;
  
  Printf.printf "✓ FIFO RW Lock test completed\n\n%!"

let () =
  test_simple_rwlock ();
  test_fifo_rwlock ()
