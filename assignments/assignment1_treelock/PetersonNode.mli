(** PetersonNode - Peterson's two-thread mutual exclusion lock

    This module implements Peterson's algorithm for mutual exclusion
    between exactly two threads. Each Peterson node can be used as a
    building block in larger lock structures.
*)

(** The type of a Peterson lock node *)
type t

(** [create ()] creates a new Peterson lock node.
    The lock is initially unlocked. *)
val create : unit -> t

(** [lock node thread_id] acquires the Peterson lock for the calling thread.
    @param node The Peterson lock node
    @param thread_id Must be 0 or 1 (representing which of the two threads)

    This function blocks until the lock is acquired.
*)
val lock : t -> int -> unit

(** [unlock node thread_id] releases the Peterson lock.
    @param node The Peterson lock node
    @param thread_id Must be 0 or 1 (same as used in lock)

    The thread must have previously acquired the lock.
*)
val unlock : t -> int -> unit
