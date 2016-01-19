all:
	ocamlyacc parser.mly
	ocamllex lexer.mll
	ocamllex lexerCommandLine.mll
	ocamlc -c prologmachine.ml
	ocamlc -c parser.mli
	ocamlc -c lexer.ml
	ocamlc -c lexerCommandLine.ml
	ocamlc -c parser.ml
	ocamlc -c main.ml
	ocamlc -o lince prologmachine.cmo lexer.cmo lexerCommandLine.cmo parser.cmo main.cmo

clean:
	rm *.cmo *.cmi lince lexer.ml parser.ml lexerCommandLine.ml parser.mli
