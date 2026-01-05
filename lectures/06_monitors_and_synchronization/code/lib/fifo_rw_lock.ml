(** FIFO read-write lock

    Multiple readers can hold the lock simultaneously.
    Writers have exclusive access.

    This version enforces FIFO ordering to prevent starvation.
    Uses cumulative counters to track read lock acquisitions and releases.
*)

type t = {
  mutable read_acquires : int;  (* Total read locks acquired *)
  mutable read_releases : int;  (* Total read locks released *)
  mutable writer : bool;        (* Is a writer active? *)
  lock : Mutex.t;
  condition : Condition.t;
}

let create () = {
  read_acquires = 0;
  read_releases = 0;
  writer = false;
  lock = Mutex.create ();
  condition = Condition.create ();
}

let read_lock rwlock =
  Mutex.lock rwlock.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock rwlock.lock) @@ fun () ->
    (* Wait while a writer is active BEFORE incrementing counter *)
    while rwlock.writer do
      Condition.wait rwlock.condition rwlock.lock
    done;
    (* Only now increment acquisition counter *)
    rwlock.read_acquires <- rwlock.read_acquires + 1

let read_unlock rwlock =
  Mutex.lock rwlock.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock rwlock.lock) @@ fun () ->
    (* Increment release counter *)
    rwlock.read_releases <- rwlock.read_releases + 1;
    (* If all acquired reads have been released, wake up waiting writers *)
    if rwlock.read_acquires = rwlock.read_releases then
      Condition.broadcast rwlock.condition

let write_lock rwlock =
  Mutex.lock rwlock.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock rwlock.lock) @@ fun () ->
    (* Phase 1: Wait for no active writer *)
    while rwlock.writer do
      Condition.wait rwlock.condition rwlock.lock
    done;
    (* Claim writer status to block new readers *)
    rwlock.writer <- true;
    (* Phase 2: Wait for existing readers to drain *)
    while rwlock.read_acquires <> rwlock.read_releases do
      Condition.wait rwlock.condition rwlock.lock
    done

let write_unlock rwlock =
  Mutex.lock rwlock.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock rwlock.lock) @@ fun () ->
    (* Clear writer flag *)
    rwlock.writer <- false;
    (* Wake up all waiting threads *)
    Condition.broadcast rwlock.condition
