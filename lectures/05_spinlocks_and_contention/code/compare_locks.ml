(* compare_locks.ml
 *
 * Compare performance of different lock implementations
 * 
 * Usage: compare_locks [--threads N] [--iterations N]
 *)

let () =
  let threads, iterations = Spinlocks.Benchmark.parse_args () in

  (* Create ALock with capacity matching thread count for best performance *)
  let module TunedALock : Spinlocks.Lock.LOCK = struct
    type t = Spinlocks.ALock.ALock.t
    let name = "Array Lock"
    let create () = Spinlocks.ALock.ALock.create_with_capacity threads
    let lock = Spinlocks.ALock.ALock.lock
    let unlock = Spinlocks.ALock.ALock.unlock
  end in

  (* List of locks to compare *)
  let locks =
    [
      (module Spinlocks.TASLock.TASLock : Spinlocks.Lock.LOCK);
      (module Spinlocks.TTASLock.TTASLock : Spinlocks.Lock.LOCK);
      (module Spinlocks.BackoffLock.DefaultBackoffLock : Spinlocks.Lock.LOCK);
      (module TunedALock : Spinlocks.Lock.LOCK);
    ]
  in

  Spinlocks.Benchmark.compare_locks locks threads iterations
