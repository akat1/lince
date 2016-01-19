/* 
This software is released under the beerware licence.
( Borrowed from FreeBSD code )

<shm@digitalsun.pl> wrote this file. As long as you retain this notice you
can do whatever you want with this stuff. If we meet some day, and you think
this stuff is worth it, you can buy me a beer in return. :)

							Mateusz Kocielski
 */

%{
open Prologmachine
%}

%token <string> SYMBOL
%token <string> VARIABLE
%token LPAREN RPAREN
%token COMMA DOT
%token ARROW
%token EOF
%token EOL
%left COMMA

%type <Prologmachine.clause list> 	program
%type <Prologmachine.structure list>	commandline

%start program
%start commandline

%%
program:
	clause program				{ $1 :: $2 }
	| target program 			{ $1 :: $2 }
	| EOF					{ [] }

target:
	ARROW structures DOT			{ Target $2 }

clause:
	structure DOT			{ Clause ($1,[]) }
	| structure ARROW structures DOT 	{ Clause ($1,$3) }

structure:
	SYMBOL					{ Atom $1 }
	| SYMBOL LPAREN structures RPAREN 	{ Struct ($1,$3) }
	| VARIABLE 				{ Variable $1 }

structures:
	structure				{ [$1] }
	| structure COMMA structures 		{ $1 :: $3 }

commandline:
	structures DOT EOL			{ $1 }

