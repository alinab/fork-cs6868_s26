open Golike_multicore

(* Test 1: Unbuffered channel — ping pong *)
let () =
  Printf.printf "=== Test 1: Ping Pong (unbuffered) ===\n";
  Sched.run ~num_domains:4 (fun () ->
    let ch = Chan.make 0 in
    Sched.fork (fun () ->
      Chan.send ch "ping";
      let reply = Chan.recv ch in
      Printf.printf "  Fiber 1 got: %s\n" reply
    );
    let msg = Chan.recv ch in
    Printf.printf "  Main got: %s\n" msg;
    Chan.send ch "pong"
  );
  Printf.printf "  PASSED\n"

(* Test 2: Buffered channel — producer/consumer *)
let () =
  Printf.printf "\n=== Test 2: Producer/Consumer (buffered, cap=3) ===\n";
  Sched.run ~num_domains:4 (fun () ->
    let ch = Chan.make 3 in
    let sum = Atomic.make 0 in
    Sched.fork (fun () ->
      for i = 1 to 10 do
        Chan.send ch i
      done
    );
    for _ = 1 to 10 do
      let v = Chan.recv ch in
      ignore (Atomic.fetch_and_add sum v : int)
    done;
    assert (Atomic.get sum = 55)
  );
  Printf.printf "  PASSED\n"

(* Test 3: Multiple producers, multiple consumers *)
let () =
  Printf.printf "\n=== Test 3: Multi-producer, multi-consumer ===\n";
  Sched.run ~num_domains:4 (fun () ->
    let ch = Chan.make 5 in
    let total = Atomic.make 0 in
    let n_producers = 4 in
    let items_per_producer = 100 in
    (* Each producer sends items_per_producer values of 1 *)
    for _ = 1 to n_producers do
      Sched.fork (fun () ->
        for _ = 1 to items_per_producer do
          Chan.send ch 1
        done
      )
    done;
    (* Single consumer collects all *)
    for _ = 1 to n_producers * items_per_producer do
      let v = Chan.recv ch in
      ignore (Atomic.fetch_and_add total v : int)
    done;
    assert (Atomic.get total = n_producers * items_per_producer)
  );
  Printf.printf "  PASSED\n"

(* Test 4: Concurrent prime sieve
 *
 * Unlike the unicore version (which uses infinite loops and exits when
 * the run queue is empty), the multicore scheduler tracks active fibers
 * and waits for all to complete. The generator sends [Some n] for each
 * candidate and [None] as a quit message. Each filter stage forwards
 * [None] downstream before exiting, so the shutdown propagates through
 * the entire pipeline. *)
let () =
  Printf.printf "\n=== Test 4: Concurrent Prime Sieve ===\n";
  let expected =
    [| 2; 3; 5; 7; 11; 13; 17; 19; 23; 29;
       31; 37; 41; 43; 47; 53; 59; 61; 67; 71 |]
  in
  let n_primes = 20 in
  let limit = 80 in (* 71 is the 20th prime; generate a bit beyond *)
  let result = Array.make n_primes 0 in
  Sched.run ~num_domains:4 (fun () ->
    let generate ch =
      for i = 2 to limit do
        Chan.send ch (Some i)
      done;
      Chan.send ch None
    in
    let filter in_ch out_ch prime =
      let running = ref true in
      while !running do
        match Chan.recv in_ch with
        | None ->
            Chan.send out_ch None;
            running := false
        | Some n ->
            if n mod prime <> 0 then
              Chan.send out_ch (Some n)
      done
    in
    let src = Chan.make 0 in
    Sched.fork (fun () -> generate src);
    let cur = ref src in
    for i = 0 to n_primes - 1 do
      let prime = match Chan.recv !cur with
        | Some p -> p
        | None -> assert false
      in
      result.(i) <- prime;
      Printf.printf "  %d\n" prime;
      let next = Chan.make 0 in
      let prev = !cur in
      Sched.fork (fun () -> filter prev next prime);
      cur := next
    done;
    (* Drain the last channel so the pipeline can shut down *)
    let rec drain () = match Chan.recv !cur with
      | None -> ()
      | Some _ -> drain ()
    in
    drain ()
  );
  assert (result = expected);
  Printf.printf "  PASSED\n"
