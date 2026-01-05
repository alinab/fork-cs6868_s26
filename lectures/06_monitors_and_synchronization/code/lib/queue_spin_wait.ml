(** Lock-based queue with spin-waiting

    This queue uses busy-waiting instead of raising exceptions.
    When the queue is full/empty, it unlocks the mutex, yields with
    Domain.cpu_relax(), then retries. This allows other operations
    to interleave.
*)

type 'a t = {
  items : 'a option array;
  capacity : int;
  mutable head : int;
  mutable tail : int;
  lock : Mutex.t;
}

let create capacity =
  {
    items = Array.make capacity None;
    capacity;
    head = 0;
    tail = 0;
    lock = Mutex.create ();
  }

let enq q x =
  Mutex.lock q.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock q.lock) @@ fun () ->
    (* Spin-wait while queue is full *)
    while q.tail - q.head = q.capacity do
      Mutex.unlock q.lock;
      Domain.cpu_relax ();
      Mutex.lock q.lock
    done;

    (* Add element *)
    q.items.(q.tail mod q.capacity) <- Some x;
    q.tail <- q.tail + 1

let deq q =
  Mutex.lock q.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock q.lock) @@ fun () ->
    (* Spin-wait while queue is empty *)
    while q.tail = q.head do
      Mutex.unlock q.lock;
      Domain.cpu_relax ();
      Mutex.lock q.lock
    done;

    match q.items.(q.head mod q.capacity) with
    | None -> assert false  (* Should never happen *)
    | Some x ->
        q.items.(q.head mod q.capacity) <- None;
        q.head <- q.head + 1;
        x
