(* benchmark_alock_custom.ml - Test ALock with custom capacity matching thread count *)

let () =
  let threads = ref 8 in
  let iterations = ref 10000 in

  let usage = "Usage: benchmark_alock_custom [--threads N] [--iterations N]" in
  let specs =
    [
      ("--threads", Arg.Set_int threads, "Number of threads (default: 8)");
      ( "--iterations",
        Arg.Set_int iterations,
        "Iterations per thread (default: 10000)" );
    ]
  in

  Arg.parse specs (fun _ -> ()) usage;

  (* Create ALock with capacity matching thread count *)
  let module CustomALock : Spinlocks.Lock.LOCK = struct
    type t = Spinlocks.ALock.ALock.t
    let name = Printf.sprintf "Array Lock (cap=%d)" !threads
    let create () = Spinlocks.ALock.ALock.create_with_capacity !threads
    let lock = Spinlocks.ALock.ALock.lock
    let unlock = Spinlocks.ALock.ALock.unlock
  end in

  Spinlocks.Benchmark.run_single (module CustomALock) !threads !iterations
