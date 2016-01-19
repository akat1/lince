(* 
This software is released under the beerware licence.
( Borrowed from FreeBSD code )

<shm@digitalsun.pl> wrote this file. As long as you retain this notice you
can do whatever you want with this stuff. If we meet some day, and you think
this stuff is worth it, you can buy me a beer in return. :)

							Mateusz Kocielski
*)

(* structure *)
type structure = Struct of (string * (structure list)) | Variable of string | Atom of string
;;

(* clause *)
type clause = Clause of ( structure * (structure list) ) | Target of (structure list)
;;

(* Prolog machine envrionment *)
type environment = (string * structure) list

(* FAILURE *)
exception Failure

(* updateEnvironment *)
let rec updateEnvironment (key, var) e =
	match e with
	| (k,v)::x -> 
		if k = key && var != v then
			raise Failure
		else
			(k,v) :: updateEnvironment (key, var) x
	| [] -> [(key, var)]
;;

(* freshVariable - generating fresh variables *)
let freshVariable =
	let i = ref 0 in
	(function () -> i := !i + 1 ; "_X"^(string_of_int !i))
;;

exception NotUnificable
;;


(* update structures *)

let rec updateStructs s (x, y) =
	match s with
	(Struct (z,zs)) :: tail -> (Struct (z,updateStructs zs (x,y))) :: (updateStructs tail (x,y))
	| z :: zs ->
		if z = x then
			y :: (updateStructs zs (x, y))
		else
			z :: (updateStructs zs (x, y))
	| [] -> []
;;

(* update structures on stack *)

let updateStructStack s (x,y) =
	let (a,b) = List.split s
	in
	List.combine (updateStructs a (x,y)) (updateStructs b (x,y))
;;

(* UNIFICATION *)

let rec unification s tailT env =
	match s with

	(Struct (lh,lt), Struct(rh, rt)) :: ss -> 
		if ( lh = rh ) && ((List.length lt) = (List.length rt)) then
			unification ((List.combine lt rt)@ss) tailT env
		else
			raise NotUnificable

	| (Atom x, Atom y)::ss ->
		if ( x = y ) then
			unification ss tailT env
		else
			raise NotUnificable

	| (Atom x, Variable y)::ss ->
			unification (updateStructStack ss (Variable y, Atom x)) (updateStructs tailT (Variable y, Atom x)) (updateEnvironment (y, Atom x) env)

	| (Variable x, Atom y)::ss ->
			unification (updateStructStack ss (Variable x, Atom y)) (updateStructs tailT (Variable x, Atom y)) (updateEnvironment (x, Atom y) env)

	| (Variable x, Variable y)::ss ->
		if ( x = y ) then
			unification ss tailT env
		else
			unification (updateStructStack ss (Variable y, Variable x)) (updateStructs tailT (Variable y, Variable x)) env

	| [] -> (env, tailT)

	| _ -> raise NotUnificable
;;

let rec renameVariables cl =
	let rec addToVar x e =
		match e with
		z::zs -> if z = x then
				e
			 else
			 	z :: (addToVar x zs)
		| [] -> x::[]
	and listVar s e =
		match s with
		(Struct (h,t))::ss -> listVar (t@ss) e
		| (Variable x)::xs -> listVar xs (addToVar x e)
		| _::xs -> listVar xs e
		| [] -> e
	in
	match cl with
	(Clause (s,t)) ->
		let
			c = List.fold_left (fun x y -> updateStructs x (Variable y, Variable (freshVariable ())))  (s::t) (listVar (s::t) [])
		in
			(List.hd c, List.tl c)
	| _ -> raise Failure
;;
				

(* DATABASE *)

(* buildDatabase - zbuduj baze danych na podstawie klauzul *)
let rec buildDatabase clauses =
	match clauses with
	[] -> []
	| (Clause x) :: tail -> (Clause x) :: (buildDatabase tail)
	| _ :: tail -> (buildDatabase tail)
;;

(* Debug functions *)

let rec show_structure =
	function
	Struct (x, y) -> x ^ "(" ^ (show_structures y) ^ ")"
	| Variable x -> x
	| Atom x -> x
and show_structures =
	function
	[] -> ""
	| x::xs -> show_structure x ^ "," ^ (show_structures xs)
;;

let show_clause =
	function
	Clause (x,y) -> show_structure x ^ " :- " ^ (show_structures y)
	| Target x -> ":- " ^ (show_structures x)
;;

let rec show_clauses =
	function
	[] -> ""
	| x :: tail -> show_clause x ^ "\n" ^ (show_clauses tail)
;;

let rec show_environment =
	function
	(key, y):: x -> 
		(
		if ( key.[0] != '_' ) then 
			key ^ " -> " ^ (show_structure y) ^ "\n" 
		else
			""
		)
		^ (show_environment x)
	| [] -> ""
;;

(* TRUE ~PROLOG MACHINE :-)))) *)

let rec runPrologMachine env stack db =
	let rec tryOne cs x xs env =
		match cs with
		c::cls ->
			let (renHead, renTail) = renameVariables c in
			(
			try
				let (newEnv, newTarget) = unification [(x,renHead)] (renTail@xs) env
				in
				runPrologMachine newEnv newTarget db
			with
				Failure -> tryOne cls x xs env
				| NotUnificable -> tryOne cls x xs env
			)
		| _ -> raise Failure
	in
	match stack with
		x::xs -> tryOne db x xs env
		| [] -> print_string("yes\n");
			print_string(show_environment env); 
			print_string("Accept? (yes/no) ");
			if read_line() = "yes" then
				env
			else
				raise Failure
;;

