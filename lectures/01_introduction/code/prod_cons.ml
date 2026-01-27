(* Producer-Consumer with Alice and Bob using Can Protocol *)

(* Different types of fish *)
type fish = Salmon | Trout | Bass | Catfish | Tuna

let fish_to_string = function
  | Salmon -> "Salmon"
  | Trout -> "Trout"
  | Bass -> "Bass"
  | Catfish -> "Catfish"
  | Tuna -> "Tuna"

let random_fish () =
  match Random.int 5 with
  | 0 -> Salmon
  | 1 -> Trout
  | 2 -> Bass
  | 3 -> Catfish
  | _ -> Tuna

(* Can state for synchronization *)
type can_state = Up | Down

type can = { mutable state : can_state }

let create_can () = { state = Up }

let is_up can = can.state = Up

let is_down can = can.state = Down

let reset can = can.state <- Up

let knock_over can = can.state <- Down

(* Shared pond with current fish *)
type pond = { mutable food : fish option }

let create_pond () = { food = None }

let stock_pond pond fish = pond.food <- Some fish

let get_food pond = pond.food

(* Alice (Consumer) - releases pets to eat fish *)
let alice can pond =
  while true do
    while is_up can do
      ()
    done;
    (match get_food pond with
    | Some fish ->
        Printf.printf "Alice: Releasing pets to eat %s\n%!" (fish_to_string fish);
        Unix.sleepf 0.1;
        Printf.printf "Alice: Recapturing pets\n%!"
    | None -> failwith "impossible");
    reset can
  done

(* Bob (Producer) - stocks the pond with fish *)
let bob can pond =
  while true do
    while is_down can do
      ()
    done;
    let fish = random_fish () in
    Printf.printf "Bob: Stocking pond with %s\n%!" (fish_to_string fish);
    stock_pond pond fish;
    knock_over can
  done

(* Main program *)
let () =
  Random.self_init ();
  let can = create_can () in
  let pond = create_pond () in
  Printf.printf "Starting Producer-Consumer with Can Protocol...\n%!";
  Printf.printf "Bob produces fish, Alice's pets consume them.\n\n%!";
  (* Spawn Alice's domain (consumer) *)
  let alice_domain = Domain.spawn (fun () -> alice can pond) in
  (* Spawn Bob's domain (producer) *)
  let bob_domain = Domain.spawn (fun () -> bob can pond) in
  (* Let them run for a bit *)
  Unix.sleep 5;
  (* Note: In a real program, we'd need a way to stop them gracefully *)
  Domain.join alice_domain;
  Domain.join bob_domain
