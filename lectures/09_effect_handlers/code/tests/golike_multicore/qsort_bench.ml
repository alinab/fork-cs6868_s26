open Golike_multicore

(* ---- In-place sequential primitives ---- *)

let swap (arr : int array) i j =
  let tmp = arr.(i) in
  arr.(i) <- arr.(j);
  arr.(j) <- tmp

let insertion_sort (arr : int array) lo hi =
  for i = lo + 1 to hi do
    let key = arr.(i) in
    let j = ref (i - 1) in
    while !j >= lo && arr.(!j) > key do
      arr.(!j + 1) <- arr.(!j);
      decr j
    done;
    arr.(!j + 1) <- key
  done

let partition (arr : int array) lo hi =
  let pivot = arr.(hi) in
  let i = ref lo in
  for j = lo to hi - 1 do
    if arr.(j) <= pivot then begin
      swap arr !i j;
      incr i
    end
  done;
  swap arr !i hi;
  !i

let rec qsort_seq (arr : int array) lo hi =
  if hi - lo < 16 then insertion_sort arr lo hi
  else begin
    let p = partition arr lo hi in
    qsort_seq arr lo (p - 1);
    qsort_seq arr (p + 1) hi
  end

let rec qsort_par cutoff (arr : int array) lo hi =
  if hi - lo < cutoff then qsort_seq arr lo hi
  else begin
    let p = partition arr lo hi in
    let promise = Promise.async (fun () -> qsort_par cutoff arr lo (p - 1)) in
    qsort_par cutoff arr (p + 1) hi;
    Promise.await promise
  end

(* ---- Benchmark harness ---- *)

let time f =
  let t0 = Unix.gettimeofday () in
  let v = f () in
  let dt = Unix.gettimeofday () -. t0 in
  (v, dt)

let random_array n =
  Random.self_init ();
  Array.init n (fun _ -> Random.bits ())

let is_sorted arr =
  let n = Array.length arr in
  let rec go i = i >= n - 1 || (arr.(i) <= arr.(i+1) && go (i+1)) in
  go 0

let () =
  let n = ref 10_000_000 in
  let iters = ref 3 in
  let mode = ref "cutoff" in
  Arg.parse
    [ "-n", Arg.Set_int n, " Array size (default: 10_000_000)";
      "-iters", Arg.Set_int iters, " Iterations per data point (default: 3)";
      "-mode", Arg.Set_string mode, " Benchmark mode: cutoff | domains (default: cutoff)" ]
    (fun _ -> ())
    "qsort_bench [-n N] [-iters I] [-mode cutoff|domains]";
  let n = !n and iters = !iters and mode = !mode in
  let max_domains = Domain.recommended_domain_count () in

  let original = random_array n in

  (* Sequential baseline — best of iters *)
  let t_seq =
    let best = ref infinity in
    for _ = 1 to iters do
      let arr = Array.copy original in
      let ((), dt) = time (fun () -> qsort_seq arr 0 (n - 1)) in
      assert (is_sorted arr);
      best := Float.min !best dt
    done;
    !best
  in
  Printf.printf "qsort(%d elements)\n" n;
  Printf.printf "Sequential: %.3f s\n" t_seq;
  Printf.printf "Max domains: %d\n\n" max_domains;

  match mode with
  | "cutoff" ->
    Printf.printf "cutoff,time_s,speedup,num_tasks\n%!";
    let cutoffs = [1000; 5000; 10000; 50000; 100000; 500000; 1000000; 5000000] in
    List.iter (fun cutoff ->
      let best = ref infinity in
      for _ = 1 to iters do
        let arr = Array.copy original in
        let ((), dt) = time (fun () ->
          Sched.run ~num_domains:max_domains (fun () ->
            qsort_par cutoff arr 0 (n - 1)
          )
        ) in
        assert (is_sorted arr);
        best := Float.min !best dt
      done;
      (* Estimate tasks: n/cutoff is a rough upper bound *)
      let num_tasks = max 1 (n / cutoff) in
      Printf.printf "%d,%.4f,%.2f,%d\n%!" cutoff !best (t_seq /. !best) num_tasks
    ) cutoffs

  | "domains" ->
    Printf.printf "domains,time_s,speedup\n%!";
    let best_cutoff = 50000 in
    Printf.printf "# cutoff=%d\n%!" best_cutoff;
    let domain_counts =
      let rec go d acc =
        if d > max_domains then List.rev acc
        else go (d + 1) (d :: acc)
      in go 1 []
    in
    List.iter (fun num_domains ->
      let best = ref infinity in
      for _ = 1 to iters do
        let arr = Array.copy original in
        let ((), dt) = time (fun () ->
          Sched.run ~num_domains (fun () ->
            qsort_par best_cutoff arr 0 (n - 1)
          )
        ) in
        assert (is_sorted arr);
        best := Float.min !best dt
      done;
      Printf.printf "%d,%.4f,%.2f\n%!" num_domains !best (t_seq /. !best)
    ) domain_counts

  | _ ->
    Printf.eprintf "Unknown mode: %s (use cutoff or domains)\n" mode;
    exit 1
