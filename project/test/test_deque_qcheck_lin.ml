[@@@alert "-internal"]
open Lin

type cmd =
  | Push  of int
  | Pop
  | Steal

type res =
  | RPush
  | RPop   of int Deque.result
  | RSteal of int Deque.result

let deque_result_equal x y = match x, y with
  | Deque.Empty,   Deque.Empty   -> true
  | Deque.Abort,   Deque.Empty   -> true
  | Deque.Empty,   Deque.Abort   -> true
  | Deque.Abort,   Deque.Abort   -> true
  | Deque.Value a, Deque.Value b -> a = b
  | _,             _             -> false

module DequeSpec = struct
  type t          = int Deque.t
  type nonrec cmd = cmd
  type nonrec res = res

  let show_cmd = function
    | Push x -> Printf.sprintf "Push %d" x
    | Pop    -> "Pop"
    | Steal  -> "Steal"

  let show_res = function
    | RPush    -> "RPush"
    | RPop r   -> (match r with
      | Deque.Empty   -> "RPop Empty"
      | Deque.Abort   -> "RPop Abort"
      | Deque.Value v -> Printf.sprintf "RPop (Value %d)" v)
    | RSteal r -> (match r with
      | Deque.Empty   -> "RSteal Empty"
      | Deque.Abort   -> "RSteal Abort"
      | Deque.Value v -> Printf.sprintf "RSteal (Value %d)" v)

  let equal_res a b = match a, b with
    | RPush,    RPush    -> true
    | RPop x,   RPop y   -> deque_result_equal x y
    | RSteal x, RSteal y -> deque_result_equal x y
    | _,        _        -> false

  let gen_cmd =
    QCheck.Gen.oneof [
      QCheck.Gen.map (fun x -> Push x) QCheck.Gen.int;
      QCheck.Gen.return Pop;
      QCheck.Gen.return Steal;
    ]

  let shrink_cmd = QCheck.Shrink.nil
  let init ()    = Deque.create 10
  let cleanup _  = ()

  let run cmd deq = match cmd with
    | Push x -> Deque.push_bottom deq x; RPush
    | Pop    -> RPop   (Deque.pop_bottom deq)
    | Steal  -> RSteal (Deque.steal deq)
end

module M = Lin_domain.Make_internal (DequeSpec)

let gen_owner =
  QCheck.Gen.oneof [
    QCheck.Gen.map (fun x -> Push x) QCheck.Gen.int;
    QCheck.Gen.return Pop;
  ]

let gen_thief = QCheck.Gen.return Steal

let arb_owner_thief =
  QCheck.make
    ~print:(fun (seq, left, right) ->
      Printf.sprintf "seq=[%s] left=[%s] right=[%s]"
        (String.concat "; " (List.map DequeSpec.show_cmd seq))
        (String.concat "; " (List.map DequeSpec.show_cmd left))
        (String.concat "; " (List.map DequeSpec.show_cmd right)))
    (QCheck.Gen.triple
      (QCheck.Gen.list_size (QCheck.Gen.int_bound 10) gen_owner)
      (QCheck.Gen.list_size (QCheck.Gen.int_bound 10) gen_owner)
      (QCheck.Gen.list_size (QCheck.Gen.int_bound 10) gen_thief))

let () =
  QCheck_base_runner.run_tests_main [
    QCheck.Test.make
      ~count:400
      ~name:"deque owner/thief linearizability"
      arb_owner_thief
      M.lin_prop;
    QCheck.Test.make
      ~count:400
      ~name:"deque stress test"
      arb_owner_thief
      M.stress_prop;
  ]
