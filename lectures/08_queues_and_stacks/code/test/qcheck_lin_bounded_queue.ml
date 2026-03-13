(** QCheck-Lin Linearizability Test for BoundedQueue

    This test verifies that the bounded queue is linearizable
    under concurrent access. We use the non-blocking [try_enq]
    and [try_deq] operations since the blocking variants would
    cause deadlocks during linearizability checking.

    The queue uses separate locks for enqueue and dequeue, so
    linearizability is maintained by the atomic size counter
    coordinating between the two ends.

    == Expected Result ==

    This test should PASS. The lock-based design with atomic
    coordination ensures linearizability.
*)

module BQ = Bounded_queue

(** Lin API specification for the bounded queue.
    Uses a capacity of 8 to allow interesting interleavings
    while keeping the state space manageable. *)
module BQSig = struct
  type t = int BQ.t

  let init () = BQ.create 8

  let cleanup _ = ()

  open Lin

  let int_small = nat_small

  (** API: non-blocking operations only *)
  let api =
    [ val_ "try_enq" BQ.try_enq (t @-> int_small @-> returning bool);
      val_ "try_deq" BQ.try_deq (t @-> returning (option int)); ]
end

module BQ_domain = Lin_domain.Make(BQSig)

let () =
  QCheck_base_runner.run_tests_main [
    BQ_domain.lin_test ~count:500 ~name:"BoundedQueue linearizability";
  ]
