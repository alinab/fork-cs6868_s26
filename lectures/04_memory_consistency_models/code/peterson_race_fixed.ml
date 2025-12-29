(* peterson_race_fixed.ml
 *
 * Demonstrates Peterson's lock using ATOMIC operations, eliminating data races
 * according to OCaml's memory model.
 *
 * Key differences from peterson_race.ml:
 * - Uses Atomic.make, Atomic.get, Atomic.set instead of refs/arrays
 * - Atomic operations establish proper happens-before edges
 * - No data races according to OCaml's memory model
 * - Clean TSAN output (no warnings)
 *
 * From the OCaml manual (https://ocaml.org/manual/5.4/memorymodel.html):
 * - Atomic module provides atomic memory locations
 * - Atomic operations are synchronized and establish happens-before edges
 * - Programs using only atomic operations for shared data are data-race-free
 *)

module Peterson = struct
  (* Atomic locations for flags - one per domain *)
  let flag = [| Atomic.make false; Atomic.make false |]
  
  (* Atomic location for the victim variable *)
  let victim = Atomic.make 0

  let lock () =
    let i = (Domain.self () :> int) - 1 in
    let j = 1 - i in
    (* Set our flag atomically - signals we want to enter critical section *)
    Atomic.set flag.(i) true;
    (* Set victim atomically - establishes happens-before with other domain *)
    Atomic.set victim i;
    (* Busy-wait using atomic reads - no data race since all accesses are atomic *)
    (* The atomic operations create proper synchronization between domains *)
    while Atomic.get flag.(j) && Atomic.get victim = i do
      ()
    done

  let unlock () =
    let i = (Domain.self () :> int) - 1 in
    (* Atomically clear our flag - releases the lock *)
    Atomic.set flag.(i) false
end

(* Counter is still a regular ref since it's protected by Peterson's lock *)
(* Only one domain accesses it at a time due to mutual exclusion *)
let counter = ref 0

let thread_work () =
  for _ = 1 to 10000 do
    Peterson.lock ();        (* Acquire lock using atomic operations *)
    incr counter;           (* Critical section - protected by the lock *)
    Peterson.unlock ()      (* Release lock using atomic operations *)
  done

let () =
  Printf.printf "Testing Peterson's lock with 10000 iterations per domain...\n%!";

  let d1 = Domain.spawn thread_work in
  let d2 = Domain.spawn thread_work in
  Domain.join d1;
  Domain.join d2;

  Printf.printf "Final counter value: %d (expected: 20000)\n" !counter
