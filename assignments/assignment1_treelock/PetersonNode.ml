(* PetersonNode.ml
 *
 * OCaml implementation of Peterson lock node for use in TreeLock
 * Each node provides mutual exclusion for exactly two threads
 *
 * This implementation is provided to students as a reference for using atomics.
 *)

type t = {
  (* Two boolean flags - one for each competing thread *)
  flag : bool Atomic.t array;
  (* Victim variable - indicates which thread should yield *)
  victim : int Atomic.t;
}

let create () =
  {
    flag = [| Atomic.make false; Atomic.make false |];
    victim = Atomic.make 0;
  }

let lock node thread_id =
  (* thread_id should be 0 or 1 for Peterson lock *)
  let i = thread_id in
  let j = 1 - i in

  (* Announce intention to enter *)
  Atomic.set node.flag.(i) true;

  (* Yield to the other thread *)
  Atomic.set node.victim i;

  (* Wait while the other thread wants to enter AND we're the victim *)
  while Atomic.get node.flag.(j) && Atomic.get node.victim = i do
    Domain.cpu_relax ()
  done

let unlock node thread_id =
  let i = thread_id in
  (* Clear our flag - no longer interested in critical section *)
  Atomic.set node.flag.(i) false

