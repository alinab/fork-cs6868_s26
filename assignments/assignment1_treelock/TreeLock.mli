(** TreeLock - Tree-based mutual exclusion lock for n threads

    This module implements a scalable lock for n-thread mutual exclusion
    using a binary tree of Peterson locks. Each thread acquires locks
    along a path from its assigned leaf to the root.
*)

(** The type of a tree lock *)
type t

(** [create num_threads] creates a tree lock for the specified number of threads.
    @param num_threads The number of threads that will use this lock (must be > 0)
    @return A new tree lock configured for num_threads
    @raise Invalid_argument if num_threads <= 0
*)
val create : int -> t

(** [lock tree thread_id] acquires the tree lock for the calling thread.
    @param tree The tree lock
    @param thread_id The thread's ID (must be in range 0 to num_threads-1)
    @raise Invalid_argument if thread_id is out of range

    The thread will acquire all Peterson locks on the path from its
    assigned leaf to the root. This function blocks until all locks
    are acquired.
*)
val lock : t -> int -> unit

(** [unlock tree thread_id] releases the tree lock.
    @param tree The tree lock
    @param thread_id The thread's ID (must be in range 0 to num_threads-1)
    @raise Invalid_argument if thread_id is out of range

    The thread must have previously acquired the lock. Locks are released
    in the reverse order they were acquired (root to leaf).
*)
val unlock : t -> int -> unit

(** [get_depth tree] returns the depth of the tree.
    This is useful for testing and verification.
*)
val get_depth : t -> int

(** [get_num_nodes tree] returns the total number of Peterson nodes in the tree.
    This is useful for testing and verification.
*)
val get_num_nodes : t -> int

(** [print_tree_info tree] prints information about the tree structure
    to standard output. Useful for debugging.
*)
val print_tree_info : t -> unit
