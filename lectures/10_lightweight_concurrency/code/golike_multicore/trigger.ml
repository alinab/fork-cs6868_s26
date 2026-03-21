type state =
  | Initialized
  | Waiting of (unit -> unit)
  | Signaled

type t = state Atomic.t

type _ Effect.t += Await : t -> unit Effect.t

let create () = Atomic.make Initialized

let rec signal t =
  match Atomic.get t with
  | Signaled -> false
  | Initialized ->
      if Atomic.compare_and_set t Initialized Signaled then true
      else signal t
  | Waiting cb as before ->
      if Atomic.compare_and_set t before Signaled then (cb (); true)
      else signal t

let rec on_signal t cb =
  match Atomic.get t with
  | Signaled -> false
  | Waiting _ -> failwith "Trigger.on_signal: already waiting"
  | Initialized ->
      if Atomic.compare_and_set t Initialized (Waiting cb) then true
      else on_signal t cb

let await t = Effect.perform (Await t)
