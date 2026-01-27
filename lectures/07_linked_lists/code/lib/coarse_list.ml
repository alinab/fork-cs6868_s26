(** List using coarse-grained synchronization.

    A single lock protects the entire list. All operations
    (add, remove, contains) acquire this lock before traversing
    or modifying the list.
*)

(** Internal node representation *)
type 'a node = {
  item : 'a option;         (* None for sentinel nodes *)
  key : int;                (* hash code for the item, or min_int/max_int for sentinels *)
  mutable next : 'a node;   (* next node in the list, tail points to itself *)
}

(** The coarse-grained list type *)
type 'a t = {
  head : 'a node;          (* sentinel node at the start *)
  lock : Mutex.t;          (* single lock for entire list *)
}

(** Create a new empty list with sentinel nodes *)
let create () =
  let rec head = { item = None; key = min_int; next = tail }
  and tail = { item = None; key = max_int; next = tail } in
  { head; lock = Mutex.create () }

(** Helper to execute a function while holding the lock *)
let with_lock list f =
  Mutex.lock list.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock list.lock) f

(** Add an element to the list *)
let add list item =
  let key = Hashtbl.hash item in
  with_lock list @@ fun () ->
    let rec traverse pred curr =
      if curr.key < key then
        traverse curr curr.next
      else if curr.key = key then
        false  (* element already present *)
      else begin
        (* insert new node between pred and curr *)
        let node = { item = Some item; key; next = curr } in
        pred.next <- node;
        true
      end
    in
    traverse list.head list.head.next

(** Remove an element from the list *)
let remove list item =
  let key = Hashtbl.hash item in
  with_lock list @@ fun () ->
    let rec traverse pred curr =
      if curr.key < key then
        traverse curr curr.next
      else if curr.key = key then begin
        (* element found, remove it *)
        pred.next <- curr.next;
        true
      end else
        false  (* element not present *)
    in
    traverse list.head list.head.next

(** Test whether an element is present *)
let contains list item =
  let key = Hashtbl.hash item in
  with_lock list @@ fun () ->
    let rec traverse curr =
      if curr.key < key then
        traverse curr.next
      else
        curr.key = key
    in
    traverse list.head.next
