(* Producer-Consumer with Alice and Bob using Can Protocol *)
let pr = Printf.printf

(* Different types of fish *)
type fish = Salmon | Trout | Bass | Catfish | Tuna [@@deriving show]

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

(* Initial state for the can is Up. In our single producer-
   single consumer scenario, the can has to knocked down
   after food into the pond *)
let create_can () = { state = Up }

let is_up can = can.state = Up

let is_down can = can.state = Down

let reset can = can.state <- Up

let knock_over can = can.state <- Down

(* Shared pond with current fish *)
type pond = { mutable food : fish option }

(* At the start, the pond has no fish; this setup is correct
   when the can being initally up *)
let create_pond () = { food = None }

let stock_pond pond fish = pond.food <- Some fish

let get_food pond = pond.food

let unless cond item f =
    let rec loop () =
        if (cond item)
        then let _ = f () in
             loop ()
        else loop ()
    in
    loop ()

(* Alice (Consumer) - releases pets to eat fish *)
let alice can pond =
    unless is_down can (fun _ ->
      (match get_food pond with
      | Some fish ->
          pr "Alice: Releasing pets to eat %s\n%!" (show_fish fish);
          Unix.sleepf 0.1;
          pr "Alice: Recapturing pets\n%!"
      | None -> failwith "impossible");
      reset can
    )

(* Bob (Producer) - stocks the pond with fish *)
let bob can pond =
    unless is_up can (fun _ ->
      let fish = random_fish () in
      pr "Bob: Stocking pond with %s\n%!" (show_fish fish);
      stock_pond pond fish;
      knock_over can
    )

(* Main program *)
let () =
  Random.self_init ();
  let can = create_can () in
  let pond = create_pond () in
  pr "Starting Producer-Consumer with Can Protocol...\n%!";
  pr "Bob produces fish, Alice's pets consume them.\n\n%!";
  (* Spawn Alice's domain (consumer) *)
  let alice_domain = Domain.spawn (fun () -> alice can pond) in
  (* Spawn Bob's domain (producer) *)
  let bob_domain = Domain.spawn (fun () -> bob can pond) in
  (* Let them run for a bit *)
  Unix.sleep 5;
  (* Note: In a real program, we'd need a way to stop them gracefully *)
  Domain.join alice_domain;
  Domain.join bob_domain
