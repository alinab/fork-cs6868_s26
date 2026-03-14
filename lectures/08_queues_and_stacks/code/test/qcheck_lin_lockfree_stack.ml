(** QCheck-Lin Linearizability Test for LockFreeStack

    This test verifies that the lock-free stack is linearizable
    under concurrent access. The Treiber stack algorithm should
    be linearizable by design.

    == Expected Result ==

    This test should PASS. The CAS-based design ensures
    linearizability without locks.
*)

module LFS = Lockfree_stack

(** Lin API specification for the lock-free stack. *)
module LFSSig = struct
  type t = int LFS.t

  let init () = LFS.create ()

  let cleanup _ = ()

  open Lin

  let int_small = nat_small

  (** API: push always succeeds (returns unit), try_pop may return None,
      pop raises Empty on empty stack *)
  let api =
    [ val_ "push"    LFS.push    (t @-> int_small @-> returning unit);
      val_ "try_pop" LFS.try_pop (t @-> returning (option int));
      val_ "pop"     LFS.pop     (t @-> returning_or_exc int); ]
end

module LFS_domain = Lin_domain.Make(LFSSig)

let () =
  QCheck_base_runner.run_tests_main [
    LFS_domain.lin_test ~count:500 ~name:"LockFreeStack linearizability";
  ]
