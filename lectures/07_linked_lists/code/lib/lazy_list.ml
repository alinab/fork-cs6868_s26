(** List using lazy synchronization.

    The key innovation: nodes have a "marked" field for logical deletion.
    Once marked, a node stays marked forever. This simplifies validation:
    we only need to check that pred and curr are unmarked and adjacent.

    The contains() method is wait-free - it doesn't use locks at all,
    just traverses the list checking keys and marked status.
*)

(** Internal node representation *)
type 'a node = {
  item : 'a option;         (* None for sentinel nodes *)
  key : int;                (* hash code for the item, or min_int/max_int for sentinels *)
  mutable next : 'a node;   (* next node in the list, tail points to itself *)
  mutable marked : bool;    (* true if logically deleted *)
  lock : Mutex.t;           (* lock for this individual node *)
}

(** The lazy list type *)
type 'a t = {
  head : 'a node;          (* sentinel node at the start *)
}

(** Create a new empty list with sentinel nodes *)
let create () =
  let rec head = { item = None; key = min_int; next = tail; marked = false; lock = Mutex.create () }
  and tail = { item = None; key = max_int; next = tail; marked = false; lock = Mutex.create () } in
  { head }

(** Validate that pred and curr are still adjacent and unmarked.

    Pre-condition:
      - pred.lock is held
      - curr.lock is held

    Returns true if both nodes are unmarked and pred.next = curr.
    Much simpler than optimistic list validation - no need to traverse from head!
*)
let validate pred curr =
  not pred.marked && not curr.marked && pred.next == curr

(** Locate position for key without locking *)
let locate head key =
  let rec loop pred curr =
    if curr.key < key then
      loop curr curr.next
    else
      (pred, curr)
  in
  loop head head.next

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
          let node = { item = Some item; key; next = curr; marked = false; lock = Mutex.create () } in
          pred.next <- node;
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
          curr.marked <- true;      (* logical deletion *)
          pred.next <- curr.next;   (* physical deletion *)
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

    This is the key advantage of lazy synchronization:
    contains() is wait-free! No locks needed.

    We can safely traverse without locking because:
    1. Marked nodes stay marked (monotonic property)
    2. We only report true if key matches AND not marked
    3. Even if a node is being concurrently removed, we'll see either
       the old state (unmarked, report true) or new state (marked, report false),
       both of which are valid linearization points.
*)
let contains list item =
  let key = Hashtbl.hash item in
  let rec loop curr =
    if curr.key < key then
      loop curr.next
    else
      curr.key = key && not curr.marked
  in
  loop list.head
