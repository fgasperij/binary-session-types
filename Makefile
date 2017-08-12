FUSE_DIR = FuSe-0.7
OCAMLC = ocamlc -I $(FUSE_DIR)/src -w +A -rectypes -thread unix.cma threads.cma

all: carrito

%: %.ml $(FUSE_DIR)/src/FuSe.cma
	$(OCAMLC) -o $@ FuSe.cma $<