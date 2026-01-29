(** QCheck-Lin Linearizability Test for LazyList

    This test verifies that the lazy list is linearizable
    under concurrent access. The lazy synchronization strategy
    with lock-free contains should ensure linearizability.

    == Expected Result ==

    This test should PASS. Lazy synchronization with marked fields
    ensures that each operation appears atomic and all concurrent
    executions are equivalent to some sequential execution.

    The key advantage: contains() is wait-free (no locking).
*)

module LL = Lazy_list

(** Lin API specification for the lazy list *)
module LLSig = struct
  type t = int LL.t

  (** Create an empty list *)
  let init () = LL.create ()

  (** No cleanup needed *)
  let cleanup _ = ()

  open Lin

  (** Use small integers (0-99) for test values *)
  let int_small = nat_small

  (** API description using Lin's combinator DSL *)
  let api =
    [ val_ "add" LL.add (t @-> int_small @-> returning bool);
      val_ "remove" LL.remove (t @-> int_small @-> returning bool);
      val_ "contains" LL.contains (t @-> int_small @-> returning bool); ]
end

(** Generate the linearizability test from the specification *)
module LL_domain = Lin_domain.Make(LLSig)

(** Run 500 test iterations for extensive testing *)
let () =
  QCheck_base_runner.run_tests_main [
    LL_domain.lin_test ~count:500 ~name:"LazyList linearizability";
  ]
