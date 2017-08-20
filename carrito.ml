module Session = Session.Bare

module StringMap = Map.Make(String)

(* (productCode, price) *)
let catalog = StringMap.empty
let catalog = StringMap.add "p1" 1 catalog
let catalog = StringMap.add "p2" 2 catalog
let catalog = StringMap.add "p3" 3 catalog

(* (productCode, availableStock) *)
let inventory = StringMap.empty
let inventory = StringMap.add "p1" 1 inventory
let inventory = StringMap.add "p2" 1 inventory
let inventory = StringMap.add "p3" 1 inventory

(* (productCode, addedUnits) *)
let cart = StringMap.empty


let cart_client ep =
  let ep = Session.select (fun x -> `TryAdd x) ep in
  let ep = Session.send "p1" ep in
  let ep = Session.send 1 ep in
  let result, ep = Session.receive ep in
  let ep = Session.select (fun x -> `End x) ep in
  Session.close ep;
  result

(* let try_add_products inventory cart code quantity = Ok ()  *)

let rec cart_service (ep, catalog, inventory) =
  match Session.branch ep with
  | `TryAdd ep -> let code, ep = Session.receive ep in
                  let quantity, ep = Session.receive ep in
                  let result = "OK" in
                  (* let result = try_add_products inventory cart code quantity in *)
                  let ep = Session.send result ep in
                  cart_service (ep, catalog, inventory)
  | `End ep -> Session.close ep
  (* | `content ep ->
  | `total ep ->
  | `remove ep ->
  | `leave ep ->
  | `checkout ep ->   *)

let _ =
  let a, b = Session.create () in
  let _ = Thread.create cart_service (a, catalog, inventory) in  
  print_endline (cart_client b)
