(** Atomic markable reference implementation *)

type 'a marked_ref = {
  reference : 'a;
  marked : bool;
}

type 'a t = 'a marked_ref Atomic.t

let create reference marked =
  Atomic.make { reference; marked }

let get amr =
  let mr = Atomic.get amr in
  (mr.reference, mr.marked)

let get_reference amr =
  let mr = Atomic.get amr in
  mr.reference

let get_mark amr =
  let mr = Atomic.get amr in
  mr.marked

let compare_and_set amr ~expected_ref ~new_ref ~expected_mark ~new_mark =
  let current = Atomic.get amr in
  (* Check if current state matches expected using physical equality for references *)
  if current.reference == expected_ref && current.marked = expected_mark then
    let new_value = { reference = new_ref; marked = new_mark } in
    Atomic.compare_and_set amr current new_value
  else
    false
