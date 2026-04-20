type ctx
type task = Task of (ctx -> unit)

val fork : ctx -> (ctx -> 'a) -> 'a Future.t
val join : ctx -> 'a Future.t -> 'a
val run  : num_workers:int -> initial_tasks:task list -> unit
