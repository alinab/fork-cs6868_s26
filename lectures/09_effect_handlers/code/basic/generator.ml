open Effect
open Effect.Deep

(* ──────────────────────────────────────────────────────────────────────
 * Control Inversion: Tree Iterator → Tree Generator
 *
 * An *internal iterator* (push-based) traverses the tree and pushes each
 * element to a callback — the producer is in control.
 *
 * A *generator* (pull-based) lets the consumer ask for the next element
 * on demand — the consumer is in control.
 *
 * With effect handlers we can mechanically convert one into the other:
 * the iterator performs a Yield effect at each element, and the handler
 * suspends the traversal, returning the value and a thunk to resume.
 * ────────────────────────────────────────────────────────────────────── *)

(* ---------- Tree type ---------- *)

type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree

(*       1
 *      / \
 *     2   3
 *    / \   \
 *   4   5   6
 *)
let example_tree =
  Node (
    Node (Node (Leaf, 4, Leaf), 2, Node (Leaf, 5, Leaf)),
    1,
    Node (Leaf, 3, Node (Leaf, 6, Leaf)))

(* ---------- Internal iterators (push-based) ---------- *)

let rec iter t f = match t with
  | Leaf -> ()
  | Node (l, x, r) ->
    iter l f;
    f x;
    iter r f

(* Iterate over fringe (leaf) elements only *)
let rec iter_leaves t f = match t with
  | Leaf -> ()
  | Node (Leaf, x, Leaf) -> f x
  | Node (l, _, r) ->
    iter_leaves l f;
    iter_leaves r f

(* ---------- Generator via effect handlers ---------- *)

(* [to_gen t] converts the internal iterator into a pull-based generator.
 * Returns a [next] function: each call returns [Some v] for the next element,
 * or [None] when the traversal is done.
 *
 * The trick: a local effect [Next] is performed at each element.  The handler
 * captures the continuation, stashes it in [step], and returns the value.
 * On the next call, we resume the continuation — which runs until the next
 * [Next] (updating [step] again) or finishes (returning [None]). *)
let to_gen (type a) (iter : (a -> unit) -> unit) =
  let module M = struct type _ Effect.t += Next : a -> unit Effect.t end in
  let open M in
  let rec step = ref (fun () ->
    try
      iter (fun x -> perform (Next x));
      None
    with effect (Next v), k ->
      step := (fun () -> continue k ());
      Some v)
  in
  fun () -> !step ()

(* ---------- Consumer: pull values one at a time ---------- *)

let print_all next =
  let rec go () =
    match next () with
    | None -> ()
    | Some v ->
      Printf.printf "  got %d\n" v;
      go ()
  in
  go ()

(* ---------- Same-fringe problem ---------- *)

(* Two binary trees have the same fringe if they have exactly the same
 * leaves reading from left to right.  A leaf is a node whose children
 * are both [Leaf] (empty).
 *
 * Using generators: walk both trees lazily, compare leaf-by-leaf,
 * stop at the first mismatch. *)

let same_fringe t1 t2 =
  let next1 = to_gen (iter_leaves t1) in
  let next2 = to_gen (iter_leaves t2) in
  let rec go () =
    match next1 (), next2 () with
    | None, None -> true
    | Some v1, Some v2 -> v1 = v2 && go ()
    | _ -> false
  in
  go ()

(* ====================================================================== *)

(* Test 1: Push-based internal iteration *)
let () =
  Printf.printf "=== Internal iterator (push-based) ===\n";
  iter example_tree (fun x -> Printf.printf "  visited %d\n" x)
(* Output:
  === Internal iterator (push-based) ===
    visited 4
    visited 2
    visited 5
    visited 1
    visited 3
    visited 6
*)

(* Test 2: Pull-based generator via control inversion *)
let () =
  Printf.printf "\n=== Generator (pull-based) ===\n";
  let next = to_gen (iter example_tree) in
  print_all next
(* Output:
  === Generator (pull-based) ===
    got 4
    got 2
    got 5
    got 1
    got 3
    got 6
*)

(* Test 3: Same-fringe problem
 *
 * Fringe = the sequence of leaf values (nodes whose children are both
 * Leaf), read left-to-right.  Two trees have the same fringe iff their
 * leaf sequences are identical, regardless of tree shape.
 *
 * Example — two differently shaped trees with the *same* fringe {3,7,20}:
 *
 *    tree_a:               tree_b:
 *         10                    8
 *        /  \                  / \
 *       5    15               6   12
 *      / \     \             /   /  \
 *     3   7    20           3   7    20
 *
 * tree_a fringe: 3, 7, 20
 * tree_b fringe: 3, 7, 20   — same!
 *)
let () =
  Printf.printf "\n=== Same-fringe test ===\n";
  (*         10
   *        /  \
   *       5    15
   *      / \     \
   *     3   7    20
   *    Fringe: 3, 7, 20
   *)
  let tree_a =
    Node (
      Node (Node (Leaf, 3, Leaf), 5, Node (Leaf, 7, Leaf)),
      10,
      Node (Leaf, 15, Node (Leaf, 20, Leaf)))
  in
  (*     8
   *    / \
   *   6   12
   *  /   /  \
   * 3   7    20
   * Fringe: 3, 7, 20  — same as tree_a!
   *)
  let tree_b =
    Node (
      Node (Node (Leaf, 3, Leaf), 6, Leaf),
      8,
      Node (Node (Leaf, 7, Leaf), 12, Node (Leaf, 20, Leaf)))
  in
  (*         10
   *        /  \
   *       5    15
   *      / \     \
   *     3   7    99
   *    Fringe: 3, 7, 99  — differs at last leaf
   *)
  let tree_c =
    Node (
      Node (Node (Leaf, 3, Leaf), 5, Node (Leaf, 7, Leaf)),
      10,
      Node (Leaf, 15, Node (Leaf, 99, Leaf)))
  in
  Printf.printf "  tree_a = tree_b? %b\n" (same_fringe tree_a tree_b);
  Printf.printf "  tree_a = tree_c? %b\n" (same_fringe tree_a tree_c);
  Printf.printf "  tree_b = tree_c? %b\n" (same_fringe tree_b tree_c)
(* Output:
  === Same-fringe test ===
    tree_a = tree_b? true
    tree_a = tree_c? false
*)

(* Test 4: Python-style generator from an imperative function
 *
 * [numbers n yield] pushes 0, then pairs (i, -i) for i = 1..n.
 * Wrapping with [to_gen] turns it into a pull-based generator. *)
let () =
  Printf.printf "\n=== Python-style generator ===\n";
  let numbers n yield =
    yield 0;
    for i = 1 to n do
      yield i; yield (-i)
    done
  in
  let next = to_gen (numbers 10) in
  let rec go () =
    match next () with
    | None -> ()
    | Some v ->
        Printf.printf "  %d\n" v;
        go ()
  in
  go ()
(* Output:
  === Python-style generator ===
    0
    1
    -1
    2
    -2
    ...
    10
    -10
*)
