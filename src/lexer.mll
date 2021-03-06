(* 
This software is released under the beerware licence.
( Borrowed from FreeBSD code )

<shm@digitalsun.pl> wrote this file. As long as you retain this notice you
can do whatever you want with this stuff. If we meet some day, and you think
this stuff is worth it, you can buy me a beer in return. :)

							Mateusz Kocielski
*)

{
open Parser
}

rule token = parse
		[' ' '\t' '\n']			{token lexbuf}	(* Skip blanks *)
	|	'('				{ LPAREN } 	(* Left paren *)
	|	')'				{ RPAREN }	(* Right paren *)
	|	":-"				{ ARROW }	(* Arrow *)
	|	eof				{ EOF }		(* End of file *)
	|	"."				{ DOT }		(* Dot *)
	|	","				{ COMMA }	(* Comma *)
	|	['a'-'z']+ as lxm		{ SYMBOL(lxm) } (* Symbol eg. function name, atom name... *)
	|	['A'-'Z']+['0'-'9']* as lxm	{ VARIABLE(lxm) } (* Variable name *)

