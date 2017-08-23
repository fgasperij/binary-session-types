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


let print_map map =
  StringMap.iter (fun k v -> print_endline (String.concat "" ["("; k; ", "; string_of_int v; ")"])) map

let rec try_to_pay_until_ok ep n =
  match n with
  | 0 -> (print_endline "Gave up!"; ep)
  | n -> 
    let _ = print_endline "Trying to pay" in
    let ep = Session.select (fun x -> `Checkout x) ep in
    let result, ep = Session.receive ep in
      if (String.compare result "OK") == 0
      then
        (print_endline "Payed successfully :)"; ep)
      else
        try_to_pay_until_ok ep (n - 1)

(* TEST *)
let cart_client ep =
  let ep = Session.select (fun x -> `TryAdd x) ep in
  let ep = Session.send "p2" ep in
  let ep = Session.send 1 ep in
  let result, ep = Session.receive ep in
  let _ = print_endline result in

  let ep = Session.select (fun x -> `Content x) ep in
  let result, ep = Session.receive ep in
  let _ = print_map result in

  let ep = Session.select (fun x -> `Total x) ep in
  let result, ep = Session.receive ep in
  let _ = print_endline (string_of_int result) in


  let ep = Session.select (fun x -> `TryAdd x) ep in
  let ep = Session.send "p1" ep in
  let ep = Session.send 1 ep in
  let result, ep = Session.receive ep in
  let _ = print_endline result in

  let ep = Session.select (fun x -> `Content x) ep in
  let result, ep = Session.receive ep in
  let _ = print_map result in

  let ep = Session.select (fun x -> `Total x) ep in
  let result, ep = Session.receive ep in
  let _ = print_endline (string_of_int result) in

  let ep = Session.select (fun x -> `TryRemove x) ep in
  let ep = Session.send "p1" ep in
  let ep = Session.send 1 ep in
  let result, ep = Session.receive ep in
  let _ = print_endline result in

  let ep = Session.select (fun x -> `Content x) ep in
  let result, ep = Session.receive ep in
  let _ = print_map result in

  let ep = Session.select (fun x -> `Total x) ep in
  let result, ep = Session.receive ep in
  let _ = print_endline (string_of_int result) in
  
  let ep = try_to_pay_until_ok ep 40 in

  let ep = Session.select (fun x -> `Leave x) ep in
  Session.close ep;
  "Finished"

(* cerrar la sesión luego de enviar los datos de pago sin esperar la respuesta del carrito. *)
(* let cart_client_close_session_suddenly ep =
  let ep = Session.select (fun x -> `Checkout x) ep in
  Session.close ep;
  "Finished" *)

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

let sum_cart catalog =
  StringMap.fold (fun code quantity total -> 
                    let price = StringMap.find code catalog in
                    total + (price * quantity)
                  ) !cart 0

let remove_from_cart code quantity cart_units =
  cart := StringMap.add code (cart_units - quantity) !cart;
  "OK"
                
let try_remove_products code quantity =
  if StringMap.mem code !cart
  then
    let cart_units = StringMap.find code !cart in
    if cart_units >= quantity
    then
      remove_from_cart code quantity cart_units
    else
      "You are trying to remove units that aren't there!"
  else
    "That product is not present in your cart"


let rec cart_service ep =
  match Session.branch ep with
  | `TryAdd ep -> let code, ep = Session.receive ep in
                  let quantity, ep = Session.receive ep in
                  let result = try_add_products inventory code quantity in 
                  let ep = Session.send result ep in
                  cart_service ep
  | `Content ep -> let ep = Session.send !cart ep in
                  cart_service ep
  | `Total ep -> let total = sum_cart catalog in
                 let ep = Session.send total ep in
                 cart_service ep
  | `TryRemove ep -> let code, ep = Session.receive ep in
                     let quantity, ep = Session.receive ep in
                     let result = try_remove_products code quantity in 
                     let ep = Session.send result ep in
                     cart_service ep
  | `Checkout ep -> let random_number = Random.int(100) in
                    let successful_payed = random_number > 90 in
                    let response = if successful_payed then "OK" else "FAIL" in
                    let ep = Session.send response ep in
                    cart_service ep
  | `Leave ep -> cart := StringMap.empty; Session.close ep


let _ =
  let a, b = Session.create () in
  let _ = Thread.create cart_service a in
  print_endline (cart_client_close_session_suddenly b)