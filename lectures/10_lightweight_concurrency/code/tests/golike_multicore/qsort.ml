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

(* Lomuto partition: pivot = arr[hi] *)
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
  let cutoff = ref 100_000 in
  let num_domains = ref (Domain.recommended_domain_count ()) in
  Arg.parse
    [ "-n", Arg.Set_int n, " Array size (default: 10_000_000)";
      "-cutoff", Arg.Set_int cutoff, " Sequential cutoff (default: 100_000)";
      "-domains", Arg.Set_int num_domains, " Number of domains" ]
    (fun _ -> ())
    "qsort [-n N] [-cutoff C] [-domains D]";
  let n = !n and cutoff = !cutoff and num_domains = !num_domains in
  Printf.printf "Array size:  %d\n" n;
  Printf.printf "Cutoff:      %d\n" cutoff;
  Printf.printf "Domains:     %d\n\n%!" num_domains;

  (* Generate a single random array, copy for each run *)
  let original = random_array n in

  (* Sequential *)
  let arr_seq = Array.copy original in
  let ((), t_seq) = time (fun () ->
    qsort_seq arr_seq 0 (n - 1)
  ) in
  assert (is_sorted arr_seq);
  Printf.printf "Sequential:  %.3f s\n%!" t_seq;

  (* Parallel *)
  let arr_par = Array.copy original in
  let ((), t_par) = time (fun () ->
    Sched.run ~num_domains (fun () ->
      qsort_par cutoff arr_par 0 (n - 1)
    )
  ) in
  assert (is_sorted arr_par);
  Printf.printf "Parallel:    %.3f s\n%!" t_par;
  Printf.printf "Speedup:     %.1fx\n%!" (t_seq /. t_par)
