(** Atomic Snapshot Object Interface

    An atomic snapshot object provides:
    - Multiple registers that can be updated independently
    - Atomic scan operation that returns a consistent view of all registers

    The snapshot is linearizable: every scan should return a state that
    actually existed at some point during the scan's execution.
*)

(** Type of atomic snapshot object with registers holding values of type 'a *)
type 'a t

(** [create n init_value] creates a snapshot object with [n] registers,
    each initialized to [init_value].
    @param n number of registers (must be > 0)
    @param init_value initial value for all registers
    @raise Invalid_argument if n <= 0
*)
val create : int -> 'a -> 'a t

(** [update snapshot idx value] atomically updates register [idx] to [value].
    @param snapshot the snapshot object
    @param idx register index (0 to n-1)
    @param value new value to write
    @raise Invalid_argument if idx is out of bounds
*)
val update : 'a t -> int -> 'a -> unit

(** [scan snapshot] returns an atomic snapshot of all registers.
    The returned array represents a consistent state that existed at some
    point during the scan operation (linearizability).
    @param snapshot the snapshot object
    @return array containing values of all registers
*)
val scan : 'a t -> 'a array

(** [size snapshot] returns the number of registers.
    @param snapshot the snapshot object
    @return number of registers
*)
val size : 'a t -> int
