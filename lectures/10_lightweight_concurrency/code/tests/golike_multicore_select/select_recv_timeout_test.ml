open Golike_multicore_select

(** Build a [Select.event] that fires after [delay] seconds.
    Uses the native [Io.timeout_evt] so the timer only starts when
    [Select.select] synchronises on it — not at event creation time. *)

(** Sender: sends integers 0..n-1 on [ch], one per second, then stops. *)
let sender ch n =
  for i = 0 to n - 1 do
    Io.sleep 1.0;
    Chan.send ch i;
  done;
  Printf.printf "[sender] done\n%!"

(** Receiver: keeps trying until it has received [n] messages, printing
    "msg <v>" on each successful receive and "timeout" on each 0.5 s
    timeout.  Both sender and receiver terminate after exactly [n]
    messages, so the scheduler can exit cleanly. *)
let receiver ch n =
  let received = ref 0 in
  while !received < n do
    (match
      Select.select
        [ Chan.recv_evt ch   |> Select.wrap (fun v  -> `Msg v)
        ; Io.timeout_evt 0.5   |> Select.wrap (fun () -> `Timeout)
        ]
    with
    | `Msg v  -> Printf.printf "[receiver] msg %d\n%!" v; incr received
    | `Timeout -> Printf.printf "[receiver] timeout\n%!");
  done;
  Printf.printf "[receiver] done\n%!"

let () =
  let n = 10 in
  Sched.run ~num_domains:4 (fun () ->
      let ch = Chan.make 0 in
      Sched.fork (fun () -> sender ch n);
      receiver ch n)
