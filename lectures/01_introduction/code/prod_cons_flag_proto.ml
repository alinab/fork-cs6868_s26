(* Producer-Consumer with Alice and Bob using the Flag Protocol *)

(* The flag protocol - applied to a two-person (thread) scenario *)
(* - Alice and Bob have a flag each
   - When either wants to access the pond to:
        - release pets to eat food (Alice)
        - put in food for pets to eat (Bob)
     they put up their own flag
   - Either person cannot access the pond when the other's flag is up
   - Both put their flag down when they are done with their tasks
   - Both put up their flag independently of the other's flag status
   - The previous two conditions imply that both need to keep checking
     the other's flag to do down before they can access the pond
*)

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

(* Shared pond with current fish *)
type pond = { mutable food : fish option }
type flag = Up | Down [@@deriving show]
type user = { mutable flag : flag; name: string }

(* At the start, the pond has no fish *)
let create_pond () = { food = None }
let stock_pond pond fish = pond.food <- Some fish
let get_food pond = pond.food

let only_when cond item f =
    let rec loop () =
        if (cond item)
        then f ()
        else loop ()
    in
    loop ()

(* Alice (Consumer) - releases pets to eat fish *)
let run_alice alice bob pond =
    Unix.sleep (Random.int_in_range ~min:1 ~max:10);
    pr "%s: puts their flag up\n%!" alice.name;
    only_when (fun x -> x.flag = Down) bob (fun _ ->
        pr "%s:'s flag is down\n%!" bob.name;
        (match get_food pond with
        | Some fish ->
            pr "%s: Releasing pets to eat %s\n%!" alice.name (show_fish fish);
            Unix.sleep 1;
            pr "%s: Recapturing pets\n%!" alice.name;
        | None -> pr "Bob hasn't put in anything! >< \n%!");
       alice.flag <- Down;
       pr "%s: puts their flag down\n%!" alice.name;
    )

(* Bob (Producer) - stocks the pond with fish *)
let run_bob bob alice pond =
    Unix.sleep (Random.int_in_range ~min:1 ~max:10);
    pr "%s: puts their flag up\n%!" bob.name;
    only_when (fun x -> x.flag = Down) alice (fun _ ->
        pr "%s:'s flag is down\n%!" alice.name;
        let fish = random_fish () in
        pr "%s: Stocking pond with %s\n%!" bob.name (show_fish fish);
        stock_pond pond fish;
        bob.flag <- Down;
        pr "%s: puts their flag down\n%!" bob.name;
    )

(* Break contention by randomly selecting who puts their own flag
   down first so that the other can start *)
let set_turn alice bob =
  match Random.int 1 with
    | 0 -> bob.flag <- Up;
           pr "%s:'s the first to try; raises his flag to put food \
               in the pond \n%!" bob.name
    | _  -> alice.flag <- Up;
           pr "%s: 's the first to try; raises her flag to put the \
               pets out to eat\n%!" alice.name

(* Main program *)
let () =
  Random.self_init ();
  let pond = create_pond () in
  let alice =  { flag = Down; name = "Alice"} in
  let bob = { flag = Down; name = "Bob"} in
  pr "Starting Producer-Consumer with the Flag Protocol...\n%!";
  pr "Bob produces fish only when Alice's flag is down\n";
  pr "Alice's pets consumes fish only when Bob's flag is down.\n%!";
  pr "Here we go ...\n%!";
  let _ = set_turn alice bob in
  (* Spawn Alice's domain (consumer) *)
  let alice_domain = Domain.spawn
    (fun () ->
           let rec loop () =
               run_alice alice bob pond;
               loop ()
           in
           loop ()
         ) in
  (* Spawn Bob's domain (producer) *)
  let bob_domain = Domain.spawn
    (fun () ->
           let rec loop () =
               run_bob bob alice pond;
               loop ()
           in
           loop ()
         ) in
  (* Let them run for a bit *)
  Unix.sleep 5;
  (* Note: In a real program, we'd need a way to stop them gracefully *)
  Domain.join alice_domain;
  Domain.join bob_domain
