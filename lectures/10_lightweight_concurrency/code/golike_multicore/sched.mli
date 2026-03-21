(** A multicore cooperative scheduler with a domain pool.

    Runs fibers across multiple OS-level domains. Each domain runs its own
    effect handler loop. Work distribution happens at fork boundaries:
    forked tasks go on a shared queue; the parent continues on the current
    domain.

    The shared queue is protected by a [Mutex] + [Condition] —
    the classic producer-consumer monitor. *)

val fork : (unit -> unit) -> unit
(** [fork f] spawns [f] as a new fiber on the shared work queue. *)

val yield : unit -> unit
(** [yield ()] suspends the current fiber and places it on the work queue. *)

val run : ?num_domains:int -> (unit -> unit) -> unit
(** [run ~num_domains main] runs [main] and all forked fibers across
    [num_domains] domains (default: [Domain.recommended_domain_count ()]).
    The calling domain participates as a worker. Returns when all
    fibers have completed. *)
