(** Non-blocking lock-based queue interface *)

exception Full
exception Empty

type 'a t

val create : int -> 'a t
val enq : 'a t -> 'a -> unit
val deq : 'a t -> 'a
