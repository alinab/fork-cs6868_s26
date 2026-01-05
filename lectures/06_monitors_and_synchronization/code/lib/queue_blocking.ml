(** Lock-based queue with condition variables (blocking version)

    This queue uses condition variables to wait when full/empty.
    Instead of raising exceptions or spin-waiting, threads block
    and are woken up when the condition changes.
*)

type 'a t = {
  items : 'a option array;
  capacity : int;
  mutable head : int;
  mutable tail : int;
  lock : Mutex.t;
  not_empty : Condition.t;  (* Signaled when queue becomes non-empty *)
  not_full : Condition.t;   (* Signaled when queue becomes non-full *)
}

let create capacity =
  {
    items = Array.make capacity None;
    capacity;
    head = 0;
    tail = 0;
    lock = Mutex.create ();
    not_empty = Condition.create ();
    not_full = Condition.create ();
  }

let enq q x =
  Mutex.lock q.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock q.lock) @@ fun () ->
    (* Wait while queue is full *)
    while q.tail - q.head = q.capacity do
      Condition.wait q.not_full q.lock
    done;

    (* Add element *)
    q.items.(q.tail mod q.capacity) <- Some x;
    q.tail <- q.tail + 1;

    (* Signal that queue is not empty *)
    Condition.signal q.not_empty

let deq q =
  Mutex.lock q.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock q.lock) @@ fun () ->
    (* Wait while queue is empty *)
    while q.tail = q.head do
      Condition.wait q.not_empty q.lock
    done;

    match q.items.(q.head mod q.capacity) with
    | None -> assert false  (* Should never happen *)
    | Some x ->
        q.items.(q.head mod q.capacity) <- None;
        q.head <- q.head + 1;

        (* Signal that queue is not full *)
        Condition.signal q.not_full;
        x
