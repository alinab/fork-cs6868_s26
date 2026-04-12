type 'a t

val create  : unit -> 'a t
val fill    : 'a t -> 'a -> unit
val get     : 'a t -> 'a option
val is_done : 'a t -> bool
