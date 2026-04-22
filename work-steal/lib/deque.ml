(* The following types signify:
   - Value wraps an item popped or stolen from the deque
   - Abort signifies an unsucessful attempt at stealing from the deque
   - Empty signifies that the deque is empty
*)
type 'a result =
    | Empty
    | Abort
    | Value of 'a

(* The deque is represented by:
    - an index (bottom) to which the next item is pushed to.
    - an index (top) from which an item is stolen after which it
    is incremented.
    - a circular array of where the entire array is stored within
      an atomic reference named as the active_array.
      --- ADD NOTE on the Atomic
*)
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

(* Stealing an item from the deque is managed by a CAS (Compare and Set
   operation. Given that the top index is never decremented,
   if the top index has changed, it can only be by having another process
   steal an item from the deque before the current domain can do so.
   If top has not changed, the item at top can be stolen by the current
   domain attempting a steal operation.
*)
let cas_top deque_arr old_top new_top =
    Atomic.compare_and_set deque_arr.top old_top new_top

(* Pushes an item into the deque. The important check is that
   if the size of the deque is greater than the size of the underlying
   circular array, then the array is grown and the newly expanded array
   set to be the underlying one.
   --- ADD NOTE on the (size - 1).
   The bottom index is incremented to point to the next slot to which
   an item can be pushed to.
*)
let push_bottom deq task =
   let b = Atomic.get deq.bottom in
   let t = Atomic.get deq.top in
   let a = Atomic.get deq.active_array in
   let a =
    if b - t >= Circular_array.size a - 1
    then begin
      let new_a = Circular_array.grow a ~bottom:b ~top:t in
      Atomic.set deq.active_array new_a;
      new_a
    end else
      a
   in
   Circular_array.put_item a b task;
   Atomic.set deq.bottom (b + 1)

(* Steals the item at the top index of the deque. If the CAS at top
   fails, another process already stole the item otherwise the stolen
   value is returned.
*)
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

(* Shrinks the underlying circular array if the number of elements
   is less than array size / K where K >= 3. The underlying circular
   array is always shrunk to half its size which is why the the value
   of K >= 3 is valid: (array_size / 3) < (array_size < 2). Also,
   after shrinking, the deque or the underlying circular array should
   have slots to push elements otherwise the need to grow the array will
   almost immediately arise.
*)
let perhaps_shrink deq ~bottom ~top =
    let a = Atomic.get deq.active_array in
    let num_elements = bottom - top in
    let curr_size = Circular_array.size a in
    if (curr_size > 1 && num_elements < (curr_size / k)) then
       Circular_array.shrink a ~bottom:bottom ~top:top
    else
        a

(* Pops an item from the bottom of the deque. With the bottom
   index always incremented by 1 after a push, pop must first
   decrement the index by 1 to obtain an element to pop. This is
   set to be the new index for bottom.

   With bottom already decremented, if top is greater than bottom,
   it means that the deque is empty with either elements stolen from
   top or popped from bottom. For this, the size of the deque is checked
   to be < 0 and bottom = top to signal an empty deque

   After an element is popped, the underlying circular array is
   heuristically shrunk using a factor and the perhaps_shrink method.
   If this were not done, then the deque memory usage would depend on the
   maximum of the size to which the circular array grows.

   Only if size = 1, a CAS is required. With another process racing with
   the deque to steal the last remaining element, if the CAS fails, then the
   item is returned wrapped in a Value; otherwise an Empty signifies that
   another process stole the element. The bottom index is set to
   *)
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
         trying to steal the same element *)
      else begin
          let result =
              if cas_top deq t (t + 1) (* increment top on a successful steal *)
              then Value task
              else Empty         (* some thief stole the last element *)
          in
          (* bottom = top i.e. deque is now empty *)
          Atomic.set deq.bottom (t + 1);
          result
      end
