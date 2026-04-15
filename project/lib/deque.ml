type 'a result =
    | Empty
    | Abort
    | Value of 'a

type 'a t = {
    bottom : int Atomic.t;
    top    : int Atomic.t;
    active_array : 'a Circular_array.t Atomic.t;
}

let create log_initial_size = {
    bottom  = Atomic.make 0;
    top     = Atomic.make 0;
    active_array = Atomic.make (Circular_array.create log_initial_size);
}

let cas_top deque_arr old_top new_top =
    Atomic.compare_and_set deque_arr.top old_top new_top

let push_bottom deq task =
   let b = Atomic.get deq.bottom in
   let t = Atomic.get deq.top in
   let a = Atomic.get deq.active_array in
   let a =
    if b - t >= Circular_array.size a - 1 then begin
      let new_a = Circular_array.grow a ~bottom:b ~top:t in
      Atomic.set deq.active_array new_a;
      new_a
    end else
      a
   in
   Circular_array.put_item a b task;
   Atomic.set deq.bottom (b + 1)


let steal deq =
    let t = Atomic.get deq.top in
    let b = Atomic.get deq.bottom in
    let a = Atomic.get deq.active_array in
    let size = b - t in
    if size <= 0 then Empty
    else
      let stolen_task = Circular_array.get_item a t in
      if not (cas_top deq t (t + 1))
      then Abort
      else Value stolen_task

(* Constant used for shrinking the array *)
let k = 3

let perhaps_shrink deq ~bottom ~top =
    let a = Atomic.get deq.active_array in
    let num_elements = bottom - top in
    let curr_size = Circular_array.size a in
    if (curr_size > 1 && num_elements < (curr_size / k)) then
       Circular_array.shrink a ~bottom:bottom ~top:top
    else
        a

let pop_bottom deq =
    let b = Atomic.get deq.bottom - 1 in
    Atomic.set deq.bottom b;
    let t = Atomic.get deq.top in
    let size = b - t in
    if (size < 0) then begin
        Atomic.set deq.bottom t; (* empty deque, top = bottom *)
        Empty                    (* nothing to return *)
    end
    else
      (* read active array here to ensure that any changes in
         array size are accurately reflected *)
      let a = Atomic.get deq.active_array in
      let task = Circular_array.get_item a b in
      if (size > 0) then begin
          let a' = perhaps_shrink deq ~bottom:b ~top:t
          in Atomic.set deq.active_array a';
          Value task
      end
      (* size = 1 i.e. popping the last remaining element races with thieves
         trying to steal the last element *)
      else begin
          let result = if cas_top deq t (t + 1)
                       then Value task
                       else Empty (* some thief stole the last element *)
          in
          Atomic.set deq.bottom (t + 1);
          result
      end
