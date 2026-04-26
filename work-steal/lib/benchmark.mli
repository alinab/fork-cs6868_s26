val time     : (unit -> 'a) -> 'a * float
val mean     : float array -> float
val std_dev  : float array -> float

val print_header : unit -> unit
val print_row    : string -> string -> int -> int -> string
                -> float -> float -> float -> float -> unit

val run_sections :
  runs:int ->
  seq_time:float ->
  worker_counts:int list ->
  thresholds:int list ->
  policies:Scheduler.steal_policy list ->
  run_ws:(num_workers:int -> steal_policy:Scheduler.steal_policy
          -> threshold:int -> Scheduler.stats * float) ->
  run_naive:(num_workers:int -> float) ->
  unit

