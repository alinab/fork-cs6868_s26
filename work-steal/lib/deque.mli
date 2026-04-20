type 'a result = Empty | Abort | Value of 'a
type 'a t
val create : int -> 'a t
val push_bottom : 'a t -> 'a -> unit
val steal : 'a t -> 'a result
val pop_bottom : 'a t -> 'a result
