type 'a t = 'a Ivar_lockfree.t

let async f =
  let p = Ivar_lockfree.create () in
  Sched.fork (fun () -> Ivar_lockfree.fill p (f ()));
  p

let await p = Ivar_lockfree.read p
