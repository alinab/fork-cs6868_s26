type 'a t = {
  capacity : int;
  buf : 'a Queue.t;
  receivers : ('a option ref * Trigger.t) Queue.t;
  senders : ('a * Trigger.t) Queue.t;
  mutex : Mutex.t;
}

let make capacity =
  if capacity < 0 then invalid_arg "Chan.make: negative capacity";
  {
    capacity;
    buf = Queue.create ();
    receivers = Queue.create ();
    senders = Queue.create ();
    mutex = Mutex.create ();
  }

let send ch v =
  Mutex.lock ch.mutex;
  if not (Queue.is_empty ch.receivers) then begin
    (* Receiver waiting — direct transfer *)
    let (slot, trigger) = Queue.pop ch.receivers in
    slot := Some v;
    Mutex.unlock ch.mutex;
    ignore (Trigger.signal trigger : bool)
  end else if Queue.length ch.buf < ch.capacity then begin
    (* Buffer has room *)
    Queue.push v ch.buf;
    Mutex.unlock ch.mutex
  end else begin
    (* Must block: buffer full or unbuffered with no receiver *)
    let trigger = Trigger.create () in
    Queue.push (v, trigger) ch.senders;
    Mutex.unlock ch.mutex;
    Trigger.await trigger
  end

let recv ch =
  Mutex.lock ch.mutex;
  if not (Queue.is_empty ch.buf) then begin
    (* Buffer has data *)
    let v = Queue.pop ch.buf in
    (* If a sender is blocked, move its value into the buffer and wake it *)
    if not (Queue.is_empty ch.senders) then begin
      let (sv, strigger) = Queue.pop ch.senders in
      Queue.push sv ch.buf;
      Mutex.unlock ch.mutex;
      ignore (Trigger.signal strigger : bool)
    end else
      Mutex.unlock ch.mutex;
    v
  end else if not (Queue.is_empty ch.senders) then begin
    (* Unbuffered: direct transfer from a blocked sender *)
    let (sv, strigger) = Queue.pop ch.senders in
    Mutex.unlock ch.mutex;
    ignore (Trigger.signal strigger : bool);
    sv
  end else begin
    (* Nothing available — must block *)
    let slot = ref None in
    let trigger = Trigger.create () in
    Queue.push (slot, trigger) ch.receivers;
    Mutex.unlock ch.mutex;
    Trigger.await trigger;
    match !slot with
    | Some v -> v
    | None -> assert false
  end
