(* 
This software is released under the beerware licence.
( Borrowed from FreeBSD code )

<shm@digitalsun.pl> wrote this file. As long as you retain this notice you
can do whatever you want with this stuff. If we meet some day, and you think
this stuff is worth it, you can buy me a beer in return. :)

							Mateusz Kocielski
*)

open Prologmachine ;;

let version = "0.1"
let prompt  = "?- "
;;

(* Say hello *)
print_string ("Lince (~prolog interpreter) version "^version^"\n")
;;

(* Build database *)

let database = ref ([])
;;

print_string("Building database...\n")
;;

for i = 1 to (Array.length Sys.argv)-1 do
	let fh = open_in Sys.argv.(i) in
	let lexbuf = Lexing.from_channel fh in
	print_string("Parsing "^ (Sys.argv.(i)) ^ "\n") ;
	try
		database := (!database) @ Parser.program Lexer.token lexbuf;
	with
		Parsing.Parse_error -> ( print_string("Parsing "^ (Sys.argv.(i)) ^ " failed...") )
	;
	close_in fh
done
;;

database := buildDatabase (!database)
;;

if (!database) = [] then
(
	print_string("Warning! Database is empty!\nContinue? (yes/no) ");
	if read_line() = "yes" then
		()
	else
	(
		exit 0
	)
)
else
	print_string("Done!\n")
;;

(* Show database *)

print_string "\nDatabase:\n";
print_string ( show_clauses (!database) );
print_string "\n"
;;

let env = ref ([]:(environment))

(* Main loop *)

let lexbuf = Lexing.from_channel stdin
;;

let target = ref ([])
;;

env := []
;;

let loop_exit = ref false in
    while not !loop_exit do
        print_string(prompt);
        flush stdout;
        try
            (* read query *)
            env := [];
            target := Parser.commandline LexerCommandLine.tokenCommandLine lexbuf;
            env := runPrologMachine (!env) (!target) (!database);
            print_string (show_environment (!env));
            ()
        with
            Parsing.Parse_error -> ( print_string ( "Errr... What?!\n" ) ; Lexing.flush_input lexbuf )
            | Failure -> print_string("no\n")
            | _ -> print_string("\nBye!\n"); loop_exit := true
        ;
        ()
    done

