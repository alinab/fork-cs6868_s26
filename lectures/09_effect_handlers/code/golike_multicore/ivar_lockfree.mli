(** A single-assignment variable (lock-free, multicore-safe).

    All state transitions use [Atomic.compare_and_set] with retry loops.
    No mutexes involved.

    Compare with {!Ivar_locked} for a mutex-based alternative. *)

type 'a t

val create : unit -> 'a t
(** Create a new empty IVar. *)

val fill : 'a t -> 'a -> unit
(** [fill ivar v] fills the IVar with [v] and wakes all waiting readers.
    @raise Failure if the IVar is already filled. *)

val read : 'a t -> 'a
(** [read ivar] returns the value if filled, or blocks until it is. *)
