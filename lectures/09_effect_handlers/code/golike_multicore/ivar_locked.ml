type 'a state =
  | Empty of Trigger.t list
  | Filled of 'a

type 'a t = {
  mutex : Mutex.t;
  state : 'a state Atomic.t;
}

let create () = {
  mutex = Mutex.create ();
  state = Atomic.make (Empty []);
}

let fill t v =
  Mutex.lock t.mutex;
  match Atomic.get t.state with
  | Filled _ ->
      Mutex.unlock t.mutex;
      failwith "Ivar_locked.fill: already filled"
  | Empty triggers ->
      Atomic.set t.state (Filled v);
      Mutex.unlock t.mutex;
      (* Signal triggers outside the lock — each signal may enqueue
         a continuation, which acquires the scheduler's queue lock. *)
      List.iter (fun tr -> ignore (Trigger.signal tr : bool)) triggers

let read t =
  (* Fast path: no lock needed — once Filled, the state never changes. *)
  match Atomic.get t.state with
  | Filled v -> v
  | Empty _ ->
      (* Slow path: take the lock to add our trigger. *)
      Mutex.lock t.mutex;
      (* Double-check under lock (could have been filled in the meantime). *)
      match Atomic.get t.state with
      | Filled v ->
          Mutex.unlock t.mutex;
          v
      | Empty triggers ->
          let tr = Trigger.create () in
          Atomic.set t.state (Empty (tr :: triggers));
          (* Release lock BEFORE blocking — holding a lock across an
             effect-based suspend would deadlock. *)
          Mutex.unlock t.mutex;
          Trigger.await tr;
          (* After wakeup, the IVar must be filled. *)
          match Atomic.get t.state with
          | Filled v -> v
          | Empty _ -> assert false
