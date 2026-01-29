(** Atomic markable reference - similar to Java's AtomicMarkableReference *)

type 'a t
(** An atomic reference that maintains a mark bit along with the reference *)

val create : 'a -> bool -> 'a t
(** [create ref mark] creates a new atomic markable reference *)

val get : 'a t -> 'a * bool
(** [get amr] atomically gets both the reference and mark *)

val get_reference : 'a t -> 'a
(** [get_reference amr] gets the reference value *)

val get_mark : 'a t -> bool
(** [get_mark amr] gets the mark value *)

val compare_and_set : 'a t -> expected_ref:'a -> new_ref:'a -> expected_mark:bool -> new_mark:bool -> bool
(** [compare_and_set amr ~expected_ref ~new_ref ~expected_mark ~new_mark]
    atomically sets the value of both the reference and mark to the given
    update values if the current reference is == to the expected reference
    and the current mark is equal to the expected mark.
    Returns true if successful. *)
