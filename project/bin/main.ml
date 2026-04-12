let threshold = 4

let rec par_sum ctx arr lo hi =
  if hi - lo <= threshold then begin
    let s = ref 0 in
    for i = lo to hi - 1 do s := !s + arr.(i) done;
    !s
  end else begin
    let mid = lo + (hi - lo) / 2 in
    let left_fut = Scheduler.fork ctx (fun ctx -> par_sum ctx arr lo mid) in
    let right_fut   = Scheduler.fork ctx (fun ctx -> par_sum ctx arr mid hi) in
        (* par_sum ctx arr mid hi in *)
    let left     = Scheduler.join ctx left_fut in
    let right    = Scheduler.join ctx right_fut in
    left + right
  end

let () =
  let n        = 1_000_000 in
  let arr      = Array.init n (fun i -> i + 1) in
  let expected = n * (n + 1) / 2 in
  let result_fut = Future.create () in
  let root = Scheduler.Task (fun ctx ->
    let result = par_sum ctx arr 0 n in
    Future.fill result_fut result
  ) in
  Scheduler.run ~num_workers:16 ~initial_tasks:[root];

  match Future.get result_fut with
  | Some result ->
      Printf.printf "Expected: %d\n" expected;
      Printf.printf "Got:      %d\n" result;
      assert (result = expected);
      Printf.printf "Correct!\n"
  | None ->
      failwith "result future was never filled"
