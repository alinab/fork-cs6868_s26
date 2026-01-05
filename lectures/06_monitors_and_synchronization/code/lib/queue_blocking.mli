(** Blocking lock-based queue interface *)

type 'a t

val create : int -> 'a t
val enq : 'a t -> 'a -> unit
val deq : 'a t -> 'a
