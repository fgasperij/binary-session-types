(* *)
module Session = Session.Bare

let echo_service ep = 
  let x, ep = Session.receive ep in
  let ep = Session.send x ep in
  Session.close ep

let echo_client ep x =
  let ep = Session.send x ep in
  let res, ep = Session.receive ep in
  Session.close ep;
  res

let _ =
  let a, b = Session.create () in
  let _ = Thread.create echo_service a in
  print_endline (echo_client b "Hello, world!")