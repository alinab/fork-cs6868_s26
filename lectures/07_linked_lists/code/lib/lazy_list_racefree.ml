(** Race-free lazy list using atomic operations.

    This version eliminates data races by using atomic operations
    for the next and marked fields, while keeping the lazy synchronization
    protocol and wait-free contains() method.
*)

(** Internal node representation with atomic fields *)
type 'a node = {
  item : 'a option;                    (* None for sentinel nodes *)
  key : int;                           (* hash code for the item *)
  mutable next : 'a node [@atomic];    (* atomic next pointer *)
  mutable marked : bool [@atomic];     (* atomic marked flag *)
  lock : Mutex.t;                      (* lock for this individual node *)
}

(** The lazy list type *)
type 'a t = {
  head : 'a node;
}

(** Create a new empty list with sentinel nodes *)
let create () =
  let rec tail = {
    item = None;
    key = max_int;
    next = tail;                   (* points to itself *)
    marked = false;
    lock = Mutex.create ()
  } and head = {
    item = None;
    key = min_int;
    next = tail;
    marked = false;
    lock = Mutex.create ()
  } in
  { head }

(** Validate that pred and curr are still adjacent and unmarked.

    Pre-condition:
      - pred.lock is held
      - curr.lock is held

    Returns true if both nodes are unmarked and pred.next = curr.
*)
let validate pred curr =
  let pred_marked = Atomic.Loc.get [%atomic.loc pred.marked] in
  let curr_marked = Atomic.Loc.get [%atomic.loc curr.marked] in
  let pred_next = Atomic.Loc.get [%atomic.loc pred.next] in
  not pred_marked && not curr_marked && (pred_next == curr)

(** Locate position for key without locking *)
let locate head key =
  let rec loop pred =
    let curr = Atomic.Loc.get [%atomic.loc pred.next] in
    if curr.key < key then
      loop curr
    else
      (pred, curr)
  in
  loop head

(** Add an element to the list *)
let add list item =
  let key = Hashtbl.hash item in
  let rec attempt () =
    let (pred, curr) = locate list.head key in
    Mutex.lock pred.lock;
    Mutex.lock curr.lock;
    if validate pred curr then begin
      let result =
        if curr.key = key then
          false  (* element already present *)
        else begin
          (* insert new node between pred and curr *)
          let node = {
            item = Some item;
            key;
            next = curr;
            marked = false;
            lock = Mutex.create ()
          } in
          Atomic.Loc.set [%atomic.loc pred.next] node;
          true
        end
      in
      Mutex.unlock curr.lock;
      Mutex.unlock pred.lock;
      result
    end else begin
      Mutex.unlock curr.lock;
      Mutex.unlock pred.lock;
      attempt ()  (* validation failed, retry *)
    end
  in
  attempt ()

(** Remove an element from the list *)
let remove list item =
  let key = Hashtbl.hash item in
  let rec attempt () =
    let (pred, curr) = locate list.head key in
    Mutex.lock pred.lock;
    Mutex.lock curr.lock;
    if validate pred curr then begin
      let result =
        if curr.key = key then begin
          (* element found, mark it then physically remove *)
          Atomic.Loc.set [%atomic.loc curr.marked] true;          (* logical deletion *)
          let curr_next = Atomic.Loc.get [%atomic.loc curr.next] in
          Atomic.Loc.set [%atomic.loc pred.next] curr_next;  (* physical deletion *)
          true
        end else
          false  (* element not present *)
      in
      Mutex.unlock curr.lock;
      Mutex.unlock pred.lock;
      result
    end else begin
      Mutex.unlock curr.lock;
      Mutex.unlock pred.lock;
      attempt ()  (* validation failed, retry *)
    end
  in
  attempt ()

(** Test whether an element is present.

    Wait-free contains with atomic reads - no data races!
*)
let contains list item =
  let key = Hashtbl.hash item in
  let rec loop curr =
    if curr.key < key then
      loop (Atomic.Loc.get [%atomic.loc curr.next])
    else
      let is_marked = Atomic.Loc.get [%atomic.loc curr.marked] in
      curr.key = key && not is_marked
  in
  loop list.head
