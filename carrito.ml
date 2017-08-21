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
let cart : int StringMap.t ref = ref StringMap.empty


let cart_client ep =
  let ep = Session.select (fun x -> `TryAdd x) ep in
  let ep = Session.send "p1" ep in
  let ep = Session.send 1 ep in
  let result1, ep = Session.receive ep in
  let _ = print_endline result1 in

  let ep = Session.select (fun x -> `TryAdd x) ep in
  let ep = Session.send "p4" ep in
  let ep = Session.send 1 ep in
  let result2, ep = Session.receive ep in
  
  let ep = Session.select (fun x -> `End x) ep in
  Session.close ep;
  result2

let add_to_cart code quantity =
  cart := StringMap.add code quantity !cart;
  "OK"

let find_or_default dic key default =
  if StringMap.mem key dic
  then
    StringMap.find key dic
  else
    default

 let try_add_products inventory code quantity =
  if StringMap.mem code inventory
  then
    let cart_units = find_or_default !cart code 0 in
    let stock_units = StringMap.find code inventory in
      if  cart_units + quantity > stock_units
      then
        "Not enough stock"
      else
        add_to_cart code (cart_units + quantity)
  else
    "Unknown product"

let rec cart_service ep =
  match Session.branch ep with
  | `TryAdd ep -> let code, ep = Session.receive ep in
                  let quantity, ep = Session.receive ep in
                  let result = try_add_products inventory code quantity in 
                  let ep = Session.send result ep in
                  cart_service ep
  | `End ep -> Session.close ep
  (* | `content ep ->
  | `total ep ->
  | `remove ep ->
  | `leave ep ->
  | `checkout ep ->   *)

let _ =
  let a, b = Session.create () in
  let _ = Thread.create cart_service a in
  print_endline (cart_client b)
