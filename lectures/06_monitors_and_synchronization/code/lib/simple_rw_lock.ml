(** Simple read-write lock

    Multiple readers can hold the lock simultaneously.
    Writers have exclusive access.

    WARNING: This is readers-preference and can starve writers!
    If readers keep arriving, a waiting writer may never acquire the lock.
*)

type t = {
  mutable readers : int;      (* Current number of active readers *)
  mutable writer : bool;      (* Is a writer active? *)
  lock : Mutex.t;
  condition : Condition.t;
}

let create () = {
  readers = 0;
  writer = false;
  lock = Mutex.create ();
  condition = Condition.create ();
}

let read_lock rwlock =
  Mutex.lock rwlock.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock rwlock.lock) @@ fun () ->
    (* Wait while a writer is active *)
    while rwlock.writer do
      Condition.wait rwlock.condition rwlock.lock
    done;
    (* Increment reader count *)
    rwlock.readers <- rwlock.readers + 1

let read_unlock rwlock =
  Mutex.lock rwlock.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock rwlock.lock) @@ fun () ->
    (* Decrement reader count *)
    rwlock.readers <- rwlock.readers - 1;
    (* If no more readers, wake up all waiting threads *)
    if rwlock.readers = 0 then
      Condition.broadcast rwlock.condition

let write_lock rwlock =
  Mutex.lock rwlock.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock rwlock.lock) @@ fun () ->
    (* Wait while readers are active OR another writer is active *)
    while rwlock.readers > 0 || rwlock.writer do
      Condition.wait rwlock.condition rwlock.lock
    done;
    (* Mark writer as active *)
    rwlock.writer <- true

let write_unlock rwlock =
  Mutex.lock rwlock.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock rwlock.lock) @@ fun () ->
    (* Clear writer flag *)
    rwlock.writer <- false;
    (* Wake up all waiting threads (readers and writers) *)
    Condition.broadcast rwlock.condition
