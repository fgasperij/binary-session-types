Informe
=======

Preguntas
---------

1.  No, el cliente no compila si intentamos hacer eso. El problema es que los endpoints dejan de ser duales porque `Checkout` sigue enviando una respuesta que el cliente no recibe.

```
Error: This expression has type
         (Session._0,
          [< `Checkout of (string * (Session._0, 'a) Session.st) Session.ot
           | `Content of
               (int StringMap.t * (Session._0, 'a) Session.st) Session.ot
           | `Leave of Session.et
           | `Total of (int * (Session._0, 'a) Session.st) Session.ot
           | `TryAdd of
               (StringMap.key *
                (int *
                 (Session._0, string * (Session._0, 'a) Session.st)
                 Session.st, Session._0)
                Session.st)
               Session.it
           | `TryRemove of
               (StringMap.key *
                (int *
                 (Session._0, string * (Session._0, 'a) Session.st)
                 Session.st, Session._0)
                Session.st)
               Session.it ]
          as 'a)
         Session.st
       but an expression was expected of type
         ([> `Checkout of (Session._0, Session._0) Session.st ] as 'b)
         Session.ot = (Session._0, 'b) Session.st
       Type
         (string * (Session._0, 'a) Session.st) Session.ot =
           (Session._0, string * (Session._0, 'a) Session.st) Session.st
       is not compatible with type (Session._0, Session._0) Session.st
       Types for tag `Checkout are incompatible
```

2. La función `cart_client_add_products_after_pay` muestra un ejemplo en el cual se intenta pagar y luego se intenta agregar un producto. Nada impide
ese flujo ya que luego de intentar pagar se vuelve recursivamente al endpoint original.

3. La función `leave_store_empty_cart` muestra un ejemplo en el que la única acción que realiza el cliente es abandonar la compra.

4. La función `remove_non_present` muestra un ejemplo. Se puede intentar quitar productos que no están en el carrito pero esto
no tendrá efecto alguno sobre el contenido del carrito. La única diferencia con el caso en el cual el producto está presente con
una cantidad mayor o igual a la que se intenta quitar es que en el exitoso la respuesta es "OK" y en el otro es 
"You are trying to remove units that aren't there!" en el caso de que no hay tantas unidades en el carrito y "That product is not present in your cart"
si el carrito no contiene ninguna unidad de ese  producto.