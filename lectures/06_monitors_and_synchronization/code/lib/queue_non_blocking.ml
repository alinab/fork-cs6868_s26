(** Lock-based queue from lecture 3 - non-blocking version

    This queue uses a mutex for synchronization but does NOT wait.
    It raises exceptions when operations cannot proceed:
    - Full: when trying to enq to a full queue
    - Empty: when trying to deq from an empty queue
*)

exception Full
exception Empty

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
    (* Check if queue is full *)
    if q.tail - q.head = q.capacity then
      raise Full;

    (* Add element *)
    q.items.(q.tail mod q.capacity) <- Some x;
    q.tail <- q.tail + 1

let deq q =
  Mutex.lock q.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock q.lock) @@ fun () ->
    if q.tail = q.head then
      raise Empty;

    match q.items.(q.head mod q.capacity) with
    | None ->
        assert false  (* Should never happen *)
    | Some x ->
        q.items.(q.head mod q.capacity) <- None;  (* Clear the slot *)
        q.head <- q.head + 1;
        x
