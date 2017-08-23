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

2.