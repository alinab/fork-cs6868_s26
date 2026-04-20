open STM

type state = int list

type cmd =
  | Push  of int
  | Pop
  | Steal

type res =
  | RPush
  | RPop   of int Deque.result
  | RSteal of int Deque.result

module DequeSTM = struct
  type nonrec cmd = cmd
  type sut        = int Deque.t
  type nonrec state = state

  let show_cmd = function
    | Push x -> Printf.sprintf "Push %d" x
    | Pop    -> "Pop"
    | Steal  -> "Steal"

  let init_state     = []
  let init_sut ()    = Deque.create 10
  let cleanup _      = ()

  let next_state cmd state =
      match cmd with
      | Push x -> state @ [x]
      | Pop    -> if state = [] then []
                  else List.take (List.length state - 1) state
      | Steal  -> if state = [] then []
                  else List.tl state

  let precond _cmd _state  = true

  (* convert Deque.result to option — Abort and Empty both become None *)
  let deque_to_option = function
    | Deque.Value v -> Some v
    | Deque.Empty   -> None
    | Deque.Abort   -> None

  let run cmd sut = match cmd with
    | Push x -> Deque.push_bottom sut x; Res (unit, ())
    | Pop    -> let v = deque_to_option (Deque.pop_bottom sut) in
                Res (option int, v)
  | Steal  -> let v = deque_to_option (Deque.steal sut) in
                Res (option int, v)

  (* let postcond cmd state res =
  match cmd, res with
  | Push _, Res ((Unit, _), ()) -> res = Res (unit, ())
  | Pop,  Res ((Option Int, _), r) ->
    (match r, state with
      | None,   []  -> true
      | None,   _   -> true    (* Abort *)
      | Some v, _   -> state <> [] && (v : int) = List.nth state (List.length state - 1))

  | Steal, Res ((Option Int, _), r) ->
     (match r, state with
      | None,   _   -> true
      | Some v, _   -> state <> [] && (v: int) = List.hd state)
  | _, _  -> false
  *)
  let postcond cmd state res =
  match cmd with
  | Push _ -> true    (* push always succeeds — no value to check *)
  | Pop ->
      let last = match state with
        | [] -> None
        | _  -> Some (List.nth state (List.length state - 1))
      in
      (match res with
      | Res ((Option Int, _), None)   -> true
      | Res ((Option Int, _), Some v) ->
          (match last with
          | None   -> false
          | Some e -> (v :int) = e)
      | _ -> false)
  | Steal ->
      let first = match state with
        | [] -> None
        | _  -> Some (List.hd state)
      in
      (match res with
      | Res ((Option Int, _), None)   -> true
      | Res ((Option Int, _), Some v) ->
          (match first with
          | None   -> false
          | Some e -> (v :int) = e)
      | _ -> false)

  let arb_cmd _state =
    QCheck.make
      ~print:(function
        | Push x -> Printf.sprintf "Push %d" x
        | Pop    -> "Pop"
        | Steal  -> "Steal")
      (QCheck.Gen.oneof [
        QCheck.Gen.map (fun x -> Push x) QCheck.Gen.int;
        QCheck.Gen.return Pop;
        QCheck.Gen.return Steal;
      ])
end

module DequeSeqTest = STM_sequential.Make (DequeSTM)
module DequeParTest = STM_domain.Make (DequeSTM)

let arb_owner _state =
  QCheck.make
    ~print:(function
      | Push x -> Printf.sprintf "Push %d" x
      | Pop    -> "Pop"
      | Steal  -> "Steal")
    (QCheck.Gen.oneof [
      QCheck.Gen.map (fun x -> Push x) QCheck.Gen.int;
      QCheck.Gen.return Pop;
    ])

let arb_thief _state =
  QCheck.make
    ~print:(function
      | Push x -> Printf.sprintf "Push %d" x
      | Pop    -> "Pop"
      | Steal  -> "Steal")
    (QCheck.Gen.return Steal)

let () =
  QCheck_base_runner.run_tests_main [
    DequeSeqTest.agree_test
      ~count:1000
      ~name:"deque sequential agreement";
    QCheck.Test.make
      ~count:500
      ~name:"deque parallel agreement"
      (DequeParTest.arb_triple 10 10 arb_owner arb_owner arb_thief)
      DequeParTest.agree_prop_par;
    QCheck.Test.make
      ~count:500
      ~name:"deque stress test"
      (DequeParTest.arb_triple 10 10 arb_owner arb_owner arb_thief)
      DequeParTest.stress_prop_par;
  ]

