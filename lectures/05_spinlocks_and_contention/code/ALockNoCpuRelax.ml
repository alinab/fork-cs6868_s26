(* ALockNoCpuRelax.ml - ALock variant without Domain.cpu_relax for testing *)

type t = {
  flags : bool Atomic.t array;
  tail : int Atomic.t;
  capacity : int;
  my_slot : int Domain.DLS.key;
}

let name = "Array Lock (no cpu_relax)"

let create_with_capacity capacity =
  if capacity <= 0 then
    invalid_arg "ALock capacity must be positive";
  
  let flags =
    Array.init capacity (fun i -> Atomic.make_contended (i = 0))
  in
  
  {
    flags;
    tail = Atomic.make 0;
    capacity;
    my_slot = Domain.DLS.new_key (fun () -> -1);
  }

let create () = create_with_capacity 16

let lock t =
  let slot = (Atomic.fetch_and_add t.tail 1) mod t.capacity in
  Domain.DLS.set t.my_slot slot;
  
  (* Spin WITHOUT cpu_relax - just busy wait *)
  while not (Atomic.get t.flags.(slot)) do
    ()
  done

let unlock t =
  let slot = Domain.DLS.get t.my_slot in
  if slot = -1 then
    failwith "unlock called without corresponding lock";
  Atomic.set t.flags.(slot) false;
  let next_slot = (slot + 1) mod t.capacity in
  Atomic.set t.flags.(next_slot) true
