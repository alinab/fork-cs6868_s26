(* a Future is a handle to a computation which will eventually
   return a value. When a scheduled task is completed, the Future
   will be filled with the value returned *)
type 'a t = 'a option Atomic.t

(* A future is initialized to None *)
let create () = Atomic.make None

let get ft = Atomic.get ft

(* To ensure that a future is only filled in once i.e. one
   task runs to completion and fills this future with a value,
   a Atomic CAS is used *)
let fill ft v = if not (Atomic.compare_and_set ft None (Some v)) then
                    failwith "Future.fill: future is already filled\n"

let is_done ft = Atomic.get ft <> None
