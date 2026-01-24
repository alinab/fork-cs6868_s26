(** List using coarse-grained synchronization.

    A single lock protects the entire list. All operations
    (add, remove, contains) acquire this lock before traversing
    or modifying the list.
*)

(** Internal node representation *)
type 'a node = {
  item : 'a option;              (* None for sentinel nodes *)
  key : int;                     (* hash code for the item, or min_int/max_int for sentinels *)
  mutable next : 'a node option; (* next node in the list, None = null *)
}

(** The coarse-grained list type *)
type 'a t = {
  head : 'a node;          (* sentinel node at the start *)
  tail : 'a node;          (* sentinel node at the end *)
  lock : Mutex.t;          (* single lock for entire list *)
}

(** Create a new empty list with sentinel nodes *)
let create () =
  let rec head = { item = None; key = min_int; next = Some tail }
  and tail = { item = None; key = max_int; next = None } in
  { head; tail; lock = Mutex.create () }

(** Add an element to the list *)
let add list item =
  let key = Hashtbl.hash item in
  Mutex.lock list.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock list.lock) @@ fun () ->
    let rec traverse pred curr =
      if curr.key < key then
        match curr.next with
        | None -> assert false  (* Should not happen with sentinels *)
        | Some next -> traverse curr next
      else if curr.key = key then
        false  (* element already present *)
      else begin
        (* insert new node between pred and curr *)
        let node = { item = Some item; key; next = Some curr } in
        pred.next <- Some node;
        true
      end
    in
    match list.head.next with
    | None -> assert false  (* Should not happen *)
    | Some first -> traverse list.head first

(** Remove an element from the list *)
let remove list item =
  let key = Hashtbl.hash item in
  Mutex.lock list.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock list.lock) @@ fun () ->
    let rec traverse pred curr =
      if curr.key < key then
        match curr.next with
        | None -> assert false  (* Should not happen with sentinels *)
        | Some next -> traverse curr next
      else if curr.key = key then begin
        (* element found, remove it *)
        pred.next <- curr.next;
        true
      end else
        false  (* element not present *)
    in
    match list.head.next with
    | None -> assert false  (* Should not happen *)
    | Some first -> traverse list.head first

(** Test whether an element is present *)
let contains list item =
  let key = Hashtbl.hash item in
  Mutex.lock list.lock;
  Fun.protect ~finally:(fun () -> Mutex.unlock list.lock) @@ fun () ->
    let rec traverse curr =
      if curr.key < key then
        match curr.next with
        | None -> assert false  (* Should not happen with sentinels *)
        | Some next -> traverse next
      else
        curr.key = key
    in
    match list.head.next with
    | None -> assert false  (* Should not happen *)
    | Some first -> traverse first
