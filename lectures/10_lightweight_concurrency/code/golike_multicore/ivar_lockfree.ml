type 'a state =
  | Empty of Trigger.t list
  | Filled of 'a

(* Physical equality on the state is used by CAS — each [Empty _]
   allocation is a distinct identity, preventing ABA issues. *)
type 'a t = 'a state Atomic.t

let create () = Atomic.make (Empty [])

let rec fill t v =
  match Atomic.get t with
  | Filled _ -> failwith "Ivar_lockfree.fill: already filled"
  | Empty triggers as before ->
      if Atomic.compare_and_set t before (Filled v) then
        List.iter (fun tr -> ignore (Trigger.signal tr : bool)) triggers
      else
        fill t v

let rec read t =
  match Atomic.get t with
  | Filled v -> v
  | Empty triggers as before ->
      let tr = Trigger.create () in
      let after = Empty (tr :: triggers) in
      if Atomic.compare_and_set t before after then begin
        Trigger.await tr;
        (* After wakeup, the IVar must be filled. *)
        match Atomic.get t with
        | Filled v -> v
        | Empty _ -> assert false
      end else
        read t
