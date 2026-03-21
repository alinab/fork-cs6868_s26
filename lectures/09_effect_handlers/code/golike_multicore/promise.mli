(** Async/await built on {!Ivar_lockfree}.

    {[
      Sched.run ~num_domains:4 (fun () ->
        let p = Promise.async (fun () -> expensive_computation ()) in
        (* ... do other work ... *)
        let result = Promise.await p in
        Printf.printf "got %d\n" result)
    ]} *)

type 'a t = 'a Ivar_lockfree.t

val async : (unit -> 'a) -> 'a t
(** [async f] forks [f] as a concurrent fiber and returns a promise
    for its result. The fiber may run on any domain in the pool. *)

val await : 'a t -> 'a
(** [await p] blocks the current fiber until the promise is fulfilled
    and returns the value. Does not block the underlying domain. *)
