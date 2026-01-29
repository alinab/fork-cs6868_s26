(** QCheck-Lin Linearizability Test for OptimisticList

    This test verifies that the optimistic list is linearizable
    under concurrent access. The optimistic locking strategy
    should ensure linearizability while allowing lock-free traversals.

    == Expected Result ==

    This test should PASS. Optimistic locking with validation
    ensures that each operation appears atomic and all concurrent
    executions are equivalent to some sequential execution.
*)

module OL = Optimistic_list

(** Lin API specification for the optimistic list *)
module OLSig = struct
  type t = int OL.t

  (** Create an empty list *)
  let init () = OL.create ()

  (** No cleanup needed *)
  let cleanup _ = ()

  open Lin

  (** Use small integers (0-99) for test values *)
  let int_small = nat_small

  (** API description using Lin's combinator DSL *)
  let api =
    [ val_ "add" OL.add (t @-> int_small @-> returning bool);
      val_ "remove" OL.remove (t @-> int_small @-> returning bool);
      val_ "contains" OL.contains (t @-> int_small @-> returning bool); ]
end

(** Generate the linearizability test from the specification *)
module OL_domain = Lin_domain.Make(OLSig)

(** Run 500 test iterations for extensive testing *)
let () =
  QCheck_base_runner.run_tests_main [
    OL_domain.lin_test ~count:500 ~name:"OptimisticList linearizability";
  ]
