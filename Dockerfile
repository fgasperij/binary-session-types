FROM ocaml/opam

ADD . /app

RUN sudo chmod +x /app/build.sh

RUN sudo /app/build.sh

ENTRYPOINT ["/app/carrito"]