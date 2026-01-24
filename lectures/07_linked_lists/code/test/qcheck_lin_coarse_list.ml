(** QCheck-Lin Linearizability Test for CoarseList

    This test verifies that the coarse-grained list is linearizable
    under concurrent access. The coarse-grained locking strategy
    (single lock for all operations) should ensure linearizability.

    == Expected Result ==

    This test should PASS. The mutex protects all list operations,
    ensuring that each operation appears atomic and all concurrent
    executions are equivalent to some sequential execution.
*)

module CL = Coarse_list

(** Lin API specification for the coarse list *)
module CLSig = struct
  type t = int CL.t

  (** Create an empty list *)
  let init () = CL.create ()

  (** No cleanup needed *)
  let cleanup _ = ()

  open Lin

  (** Use small integers (0-99) for test values *)
  let int_small = nat_small

  (** API description using Lin's combinator DSL *)
  let api =
    [ val_ "add" CL.add (t @-> int_small @-> returning bool);
      val_ "remove" CL.remove (t @-> int_small @-> returning bool);
      val_ "contains" CL.contains (t @-> int_small @-> returning bool); ]
end

(** Generate the linearizability test from the specification *)
module CL_domain = Lin_domain.Make(CLSig)

(** Run 100 test iterations *)
let () =
  QCheck_base_runner.run_tests_main [
    CL_domain.lin_test ~count:100 ~name:"CoarseList linearizability";
  ]
