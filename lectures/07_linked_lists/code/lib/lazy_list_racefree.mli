(** Race-free lazy list interface *)

type 'a t
(** The type of race-free lazy lists *)

val create : unit -> 'a t
(** Create a new empty list *)

val add : 'a t -> 'a -> bool
(** [add list item] adds [item] to the list. Returns [true] if the item was added,
    [false] if it was already present. *)

val remove : 'a t -> 'a -> bool
(** [remove list item] removes [item] from the list. Returns [true] if the item
    was removed, [false] if it was not present. *)

val contains : 'a t -> 'a -> bool
(** [contains list item] tests whether [item] is in the list.
    This operation is wait-free and race-free using atomic operations. *)
