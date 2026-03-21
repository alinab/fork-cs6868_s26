(** A single-assignment variable (lock-based, multicore-safe).

    Uses a [Mutex] to protect the trigger list. The state field is
    stored in an [Atomic.t] so that the read after wakeup needs no lock
    (once filled, the state is immutable).

    Compare with {!Ivar_lockfree} for a CAS-based alternative. *)

type 'a t

val create : unit -> 'a t
(** Create a new empty IVar. *)

val fill : 'a t -> 'a -> unit
(** [fill ivar v] fills the IVar with [v] and wakes all waiting readers.
    @raise Failure if the IVar is already filled. *)

val read : 'a t -> 'a
(** [read ivar] returns the value if filled, or blocks until it is. *)
