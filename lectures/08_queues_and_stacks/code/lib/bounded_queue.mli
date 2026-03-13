(** Bounded blocking queue.

    Based on the BoundedQueue from "The Art of Multiprocessor Programming"
    by Herlihy and Shavit (Chapter 10).

    Uses separate enqueue and dequeue locks with condition variables,
    and an atomic size counter tracking empty slots. This allows
    concurrent enqueue and dequeue operations. *)

type 'a t
(** The type of a bounded queue containing elements of type ['a] *)

val create : int -> 'a t
(** [create capacity] creates a new empty bounded queue that can hold
    at most [capacity] elements. *)

val enq : 'a t -> 'a -> unit
(** [enq q x] appends [x] to the end of the queue.
    Blocks if the queue is full until space becomes available. *)

val deq : 'a t -> 'a
(** [deq q] removes and returns the first element of the queue.
    Blocks if the queue is empty until an element becomes available. *)

val try_enq : 'a t -> 'a -> bool
(** [try_enq q x] attempts to append [x] to the end of the queue.
    Returns [true] if successful, [false] if the queue is full.
    Does not block. *)

val try_deq : 'a t -> 'a option
(** [try_deq q] attempts to remove and return the first element.
    Returns [Some x] if successful, [None] if the queue is empty.
    Does not block. *)
