(* TTASLockUnsafe.ml - TTAS using plain ref with Obj.magic *)

type t = {
  state : bool ref;
}

let name = "TTAS Lock (unsafe ref)"

let create () = {
  state = ref false;
}

(* Use plain ref read to avoid coherence traffic *)
let lock t =
  while
    (* Inner loop: plain ref read *)
    (while !(t.state) do Domain.cpu_relax () done;
     (* Exchange needs atomic - convert ref to atomic *)
     Atomic.exchange (Obj.magic t.state : bool Atomic.t) true)
  do () done

let unlock t =
  (* Plain write *)
  t.state := false
