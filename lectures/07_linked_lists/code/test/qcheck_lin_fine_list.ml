(** QCheck-Lin Linearizability Test for FineList

    This test verifies that the fine-grained list is linearizable
    under concurrent access. The hand-over-hand locking strategy
    should ensure linearizability while allowing more parallelism
    than coarse-grained locking.

    == Expected Result ==

    This test should PASS. Hand-over-hand locking ensures that each
    operation appears atomic and all concurrent executions are
    equivalent to some sequential execution.
*)

module FL = Fine_list

(** Lin API specification for the fine list *)
module FLSig = struct
  type t = int FL.t

  (** Create an empty list *)
  let init () = FL.create ()

  (** No cleanup needed *)
  let cleanup _ = ()

  open Lin

  (** Use small integers (0-99) for test values *)
  let int_small = nat_small

  (** API description using Lin's combinator DSL *)
  let api =
    [ val_ "add" FL.add (t @-> int_small @-> returning bool);
      val_ "remove" FL.remove (t @-> int_small @-> returning bool);
      val_ "contains" FL.contains (t @-> int_small @-> returning bool); ]
end

(** Generate the linearizability test from the specification *)
module FL_domain = Lin_domain.Make(FLSig)

(** Run 100 test iterations *)
let () =
  QCheck_base_runner.run_tests_main [
    FL_domain.lin_test ~count:100 ~name:"FineList linearizability";
  ]
