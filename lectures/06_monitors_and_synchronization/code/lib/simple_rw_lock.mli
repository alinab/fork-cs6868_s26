(** Simple read-write lock (readers-preference, can starve writers) *)

type t

val create : unit -> t

val read_lock : t -> unit
val read_unlock : t -> unit

val write_lock : t -> unit
val write_unlock : t -> unit
