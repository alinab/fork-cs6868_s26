(* A type that takes care of managing contexts i.e. what gets passed when
   forking and joining tasks across domains. Here the type is abstract;
   the actual definition in the scheduler takes care of defining what
   gets passed to each task by the scheduler *)

type stats = {
  steal_count : int;
  task_count  : int;
  steal_ratio : float;
}

type ctx

type task = Task of (ctx -> unit)

val fork   : ctx -> (ctx -> 'a) -> 'a Future.t

val join   : ctx -> 'a Future.t -> 'a

val run    : num_workers:int -> initial_tasks:task list -> stats
