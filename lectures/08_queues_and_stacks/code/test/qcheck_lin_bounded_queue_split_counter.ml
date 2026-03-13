(** QCheck-Lin Linearizability Test for Bounded_queue_split_counter *)

module BQ = Bounded_queue_split_counter

module BQSig = struct
  type t = int BQ.t

  let init () = BQ.create 8

  let cleanup _ = ()

  open Lin

  let int_small = nat_small

  let api =
    [ val_ "try_enq" BQ.try_enq (t @-> int_small @-> returning bool);
      val_ "try_deq" BQ.try_deq (t @-> returning (option int)); ]
end

module BQ_domain = Lin_domain.Make(BQSig)

let () =
  QCheck_base_runner.run_tests_main [
    BQ_domain.lin_test ~count:500 ~name:"Bounded_queue_split_counter linearizability";
  ]
