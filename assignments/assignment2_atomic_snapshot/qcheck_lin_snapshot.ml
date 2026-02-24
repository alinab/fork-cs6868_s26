(** QCheck-Lin Linearizability Test for Atomic Snapshot

    This test verifies that the atomic snapshot implementation is linearizable
    under concurrent access.

    == Your Task ==

    Implement the QCheck-Lin specification for the atomic snapshot.
    Follow the examples from Lecture 3:
    - qcheck_lin_bounded.ml
    - qcheck_lin_lockfree.ml

    You need to:
    1. Define the Lin API specification module (SnapshotSig)
    2. Specify init() and cleanup() functions
    3. Define the api list using Lin's DSL (val_ combinator)
    4. Generate and run the linearizability test

    == Lin DSL Type Descriptors ==

    The Snapshot.scan function returns 'int array'. Use:
      returning (array int)

    The others are standard and follow the API from the lectures.

    == Expected Result ==

    This test should PASS. The double-collect algorithm ensures linearizability:
    every scan returns a consistent snapshot that corresponds to some actual
    state that existed during the scan operation.
*)

failwith "Implement QCheck-Lin test following Lecture 3 examples"
