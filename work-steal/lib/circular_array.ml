type 'a t = {
    log_size : int;
    (* Exponent of array size — stored as log rather than size directly
       to enable O(1) grow/shrink via increment/decrement and fast
       cyclic indexing via 1 lsl log_size *)
    segment: 'a option Atomic.t array;
    (* Atomic slots required — owner and thieves may concurrently access
       different indices, and Atomic.set/get provides the necessary
       memory ordering guarantees *)
}

let create log_size = {
    log_size = log_size;
    segment = Array.init (1 lsl log_size) (fun _ -> Atomic.make None)
}

let size _array = 1 lsl (_array.log_size)

let get_item _array idx =
    let size = size _array in
    let mod_idx = idx mod size in
    match Atomic.get _array.segment.(mod_idx) with
    | Some v -> v
    | None -> failwith "Circular_array.get: uninitialized slot"
     (* None should never occur in correct usage — top and bottom
       invariants guarantee only previously written slots are read *)

let put_item _array idx item =
    let size = size _array in
    let mod_idx = idx mod size in
    Atomic.set _array.segment.(mod_idx) (Some item)

let grow _array ~bottom ~top =
    let new_array = create (_array.log_size + 1) in
    for i = top to bottom - 1 do
        put_item new_array i (get_item _array i)
    done;
    new_array

let shrink _array ~bottom ~top =
    let shrunk_array = create (_array.log_size - 1) in
    for i = top to bottom - 1 do
        put_item shrunk_array i (get_item _array i)
    done;
    shrunk_array
