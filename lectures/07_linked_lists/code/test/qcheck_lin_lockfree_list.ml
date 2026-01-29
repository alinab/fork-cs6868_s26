(** QCheck-Lin Linearizability Test for LockFreeList

    This test verifies that the lock-free list is linearizable
    under concurrent access. Michael's lock-free algorithm should
    ensure linearizability using atomic compare-and-set operations.

    == Expected Result ==

    This test should PASS. The lock-free algorithm with atomic
    operations ensures that each operation appears atomic and all
    concurrent executions are equivalent to some sequential execution.
*)

module LF = Lockfree_list

(** Lin API specification for the lock-free list *)
module LFSig = struct
  type t = int LF.t

  (** Create an empty list *)
  let init () = LF.create ()

  (** No cleanup needed *)
  let cleanup _ = ()

  open Lin

  (** Use small integers (0-99) for test values *)
  let int_small = nat_small

  (** API description using Lin's combinator DSL *)
  let api =
    [ val_ "add" LF.add (t @-> int_small @-> returning bool);
      val_ "remove" LF.remove (t @-> int_small @-> returning bool);
      val_ "contains" LF.contains (t @-> int_small @-> returning bool); ]
end

(** Generate the linearizability test from the specification *)
module LF_domain = Lin_domain.Make(LFSig)

(** Run 500 test iterations for extensive testing *)
let () =
  QCheck_base_runner.run_tests_main [
    LF_domain.lin_test ~count:500 ~name:"LockFreeList linearizability";
  ]
