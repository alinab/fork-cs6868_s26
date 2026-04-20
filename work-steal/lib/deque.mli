type 'a result = Empty | Abort | Value of 'a

(** The type of the deque *)
type 'a t

(** Creates a deque with size = 2 ^ size *)
val create : int -> 'a t

(** Pushes an item to the bottom end of the deque *)
val push_bottom : 'a t -> 'a -> unit

(** Pops an item from the bottom end of the deque *)
val pop_bottom : 'a t -> 'a result

(** Steals an item from the top end of *** from another deque *** *)
val steal : 'a t -> 'a result

