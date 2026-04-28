(** A future is a thread-safe single-assignment box that starts empty
    and is filled exactly once when a forked task completes.
    The underlying representation is ['a option Atomic.t] — [None]
    means the result is not yet available, [Some v] means it is. *)
type 'a t

(** [create ()] allocates a new empty future. *)
val create  : unit -> 'a t

(** [fill f v] stores [v] in the future [f].
    Should be called exactly once — a second call will silently
    overwrite the first value. *)
val fill    : 'a t -> 'a -> unit

(** [get f] returns the current contents of the future as an option.
    Returns [None] if the future has not yet been filled,
    or [Some v] if it has. Non-blocking — does not wait for completion. *)
val get     : 'a t -> 'a option

(** [is_done f] returns [true] if the future has been filled,
    [false] otherwise. Used by [join] in the scheduler to poll
    for completion without blocking the domain. *)
val is_done : 'a t -> bool
