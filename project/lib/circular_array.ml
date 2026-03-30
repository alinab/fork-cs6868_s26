type 'a t = {
    log_size : int;
    segment: 'a option array;
}

let create log_size = {
    log_size = log_size;
    segment = Array.init (1 lsl log_size) (fun _ -> None)
}

let size _array = 1 lsl (_array.log_size)

(* TODO: Add note on the failwith *)
let get_item _array idx =
    let size = size _array in
    let mod_idx = idx mod size in
    match _array.segment.(mod_idx) with
    | Some v -> v
    | None -> failwith "Circular_array.get: uninitialized slot"

let put_item _array idx item =
    let size = size _array in
    let mod_idx = idx mod size in _array.segment.(mod_idx) <- Some item

let grow _array ~bottom ~top =
    let new_array = create (_array.log_size + 1) in
    for i = top to bottom - 1 do
        put_item new_array i (get_item _array i)
    done;
    new_array
