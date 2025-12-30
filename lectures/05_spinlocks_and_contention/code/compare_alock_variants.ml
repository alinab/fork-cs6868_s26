(* compare_alock_variants.ml
 * 
 * Compare ALock with and without make_contended to measure false sharing impact
 *)

let () =
  let threads = ref 8 in
  let iterations = ref 10000 in

  let usage = "Usage: compare_alock_variants [--threads N] [--iterations N]" in
  let specs =
    [
      ("--threads", Arg.Set_int threads, "Number of threads (default: 8)");
      ( "--iterations",
        Arg.Set_int iterations,
        "Iterations per thread (default: 10000)" );
    ]
  in

  Arg.parse specs (fun _ -> ()) usage;

  Printf.printf "=== ALock Variants Comparison ===\n\n%!";
  Printf.printf "Configuration: %d threads × %d iterations\n" !threads
    !iterations;
  Printf.printf
    "Comparing ALock with and without make_contended (false sharing \
     prevention)\n\n\
     %!";

  (* Create both variants with capacity matching thread count *)
  let module ALockWithContended : Spinlocks.Lock.LOCK = struct
    type t = Spinlocks.ALock.ALock.t

    let name = Printf.sprintf "ALock WITH padding (cap=%d)" !threads
    let create () = Spinlocks.ALock.ALock.create_with_capacity !threads
    let lock = Spinlocks.ALock.ALock.lock
    let unlock = Spinlocks.ALock.ALock.unlock
  end in

  let module ALockNoContended : Spinlocks.Lock.LOCK = struct
    type t = Spinlocks.ALock.ALockNoContention.t

    let name = Printf.sprintf "ALock NO padding (cap=%d)" !threads

    let create () =
      Spinlocks.ALock.ALockNoContention.create_with_capacity !threads

    let lock = Spinlocks.ALock.ALockNoContention.lock
    let unlock = Spinlocks.ALock.ALockNoContention.unlock
  end in

  let locks =
    [
      (module ALockWithContended : Spinlocks.Lock.LOCK);
      (module ALockNoContended : Spinlocks.Lock.LOCK);
    ]
  in

  Spinlocks.Benchmark.compare_locks locks !threads !iterations;

  Printf.printf "\nNote: If WITH padding is significantly faster, false sharing \
                 was the issue.\n";
  Printf.printf "If performance is similar, other factors dominate (e.g., DLS \
                 overhead, modulo).\n%!"
