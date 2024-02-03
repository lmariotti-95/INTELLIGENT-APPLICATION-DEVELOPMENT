type 'a graph = Graph of ('a->'a list);;
type cell = Cell of (int * int);;

(* 
-----------------------------------------------------
	Definizione delle eccezioni 
-----------------------------------------------------
*)
exception UnvalidPosition;;
exception NotFound;;

(* 
-----------------------------------------------------
	Utility
-----------------------------------------------------
*)

let string_of_cell (Cell (x, y)) =
  Printf.sprintf "(%d, %d)" x y;;

let print_cell_list c_list =
  let string_list = List.map string_of_cell c_list in
  Printf.printf "[%s]\n" (String.concat "; " string_list);;

let print_path path = 
  (*Printf.printf "----\n";*)
  print_cell_list path;;

let wait_for_key = let _ = read_line() in ()

(* 
-----------------------------------------------------
	Definizione delle azioni 
-----------------------------------------------------
*)

(* cell -> int -> bool *)
let is_in_board c n = 
	match c with Cell(x, y) -> x >= 0 && y >= 0 && x < n && y < n;;

(* cell -> int -> cell list -> bool *)
let is_valid c n c_list = (is_in_board c n) && (not (List.mem c c_list));; 

(* cell -> int -> cell list -> cell *)
let move_up_rg c n c_list = match c with
	Cell(x, y) -> let landing = Cell(x + 1, y - 2) in
		if (is_valid landing n c_list) then landing
    else raise UnvalidPosition;;
				  
(* cell -> int -> cell list -> cell *)
let move_rg_up c n c_list = match c with
	Cell(x, y) -> let landing = Cell(x + 2, y - 1) in
		if (is_valid landing n c_list) then landing
		else raise UnvalidPosition;;
				  
(* cell -> int -> cell list -> cell *)
let move_rg_dn c n c_list = match c with
	Cell(x, y) -> let landing = Cell(x + 2, y + 1) in
		if (is_valid landing n c_list) then landing
		else raise UnvalidPosition;;
				  
(* cell -> int -> cell list -> cell *)
let move_dn_rg c n c_list = match c with
	Cell(x, y) -> let landing = Cell(x + 1, y + 2) in
		if (is_valid landing n c_list) then landing
		else raise UnvalidPosition;;
				  
(* cell -> int -> cell list -> cell *)
let move_dn_lf c n c_list = match c with
	Cell(x, y) -> let landing = Cell(x - 1, y + 2) in
		if (is_valid landing n c_list) then landing
		else raise UnvalidPosition;;
				  
(* cell -> int -> cell list -> cell *)
let move_lf_dn c n c_list = match c with
	Cell(x, y) -> let landing = Cell(x - 2, y + 1) in
		if (is_valid landing n c_list) then landing
		else raise UnvalidPosition;;
				  
(* cell -> int -> cell list -> cell *)
let move_lf_up c n c_list = match c with
	Cell(x, y) -> let landing = Cell(x - 2, y - 1) in
		if (is_valid landing n c_list) then landing
		else raise UnvalidPosition;;
				  
(* cell -> int -> cell list -> cell *)
let move_up_lf c n c_list = match c with
	Cell(x, y) -> let landing = Cell(x - 1, y - 2) in
		if (is_valid landing n c_list) then landing
		else raise UnvalidPosition;;

(* 
-----------------------------------------------------
	Definizione dello stato obbiettivo
-----------------------------------------------------
*)

(* Verifica se la lista contiene duplicati *)
(* has_duplicate : 'a list -> bool *)
let rec has_duplicate lst = 
    match lst with
		[] -> false
		| x::rest -> if List.mem x rest then true
                 else has_duplicate(rest);;
	
(* Verifica che sia una lista NxN e non contenga duplicati *)
(* goal : cell list -> int -> bool *)
let goal c_list n = List.length c_list = (n * n) && not (has_duplicate c_list);;

(*
goal 
[
  Cell(0,0);Cell(0,1);Cell(0,2);
  Cell(1,0);Cell(1,0);Cell(1,2);
  Cell(2,0);Cell(2,1);Cell(2,2);
] 3;;

(* -:bool = true *)
*)

(* 
-----------------------------------------------------
	Definizione della funzione successori
-----------------------------------------------------
*)

(* move : cell -> int -> cell list -> 'a list *)
let move c n c_list =
	let rec aux = function
		[] -> []
		| f::rest -> try (f c n c_list)::(aux rest)
				   with UnvalidPosition -> aux rest in
aux [move_up_rg; move_rg_up; move_rg_dn; move_dn_rg; move_dn_lf; move_lf_dn; move_lf_up; move_up_lf];;

(* 
-----------------------------------------------------
	BFS - Breadth  First Search
-----------------------------------------------------
*)
let extend path n = 
  (*print_path path; *)

	(* 
		val map : ('a -> 'b) -> 'a list -> 'b list
		map f [a1; ...; an] applies function f to a1, ..., an, and builds the list [f a1; ...; f an] with the results returned by f.
		
		val filter : ('a -> bool) -> 'a list -> 'a list
		filter f l returns all the elements of the list l that satisfy the predicate f. The order of the elements in the input list is preserved.
	*)
  List.map (function x -> x::path)
    (List.filter (function x -> not (List.mem x path)) (move (List.hd path) n (List.tl path)));;

let bfs start n =
  let rec search_aux = function
		[] -> raise NotFound
    | path::rest -> 
			if goal path n
        then List.rev path
        else search_aux (rest @ (extend path n))
  in search_aux [[start]];;

let dfs start n=
	let rec search_aux = function
		[] -> raise NotFound
		| path::rest -> 
			if goal path n
				then List.rev path
				else search_aux ((extend path n) @ rest)
in search_aux [[start]];;

(*
let main() = 
	let num_args = Array.length Sys.argv in
	if num_args < 3 then
	(
		Printf.printf "Unvalid args number\n";
		wait_for_key,
		exit 1
	)
	else
	(
		let x = int_of_string Sys.argv.(1) in
		let y = int_of_string Sys.argv.(2) in
		let n = int_of_string Sys.argv.(3) in

		let c = Cell(x, y) in

		Printf.printf "Executing DFS\n";
		Printf.printf "Start = (%d,%d)\n" x y;
		Printf.printf "Size = %d\n" n;

		let solution = dfs c n in
		(* bfs (Cell(2,2)) 5;; *)
		print_path solution;
		wait_for_key,
		exit 0
	)
	*)
(* let _ = main();; *)

let print_conditions x y n = 
	Printf.printf "Executing DFS\n";
	Printf.printf "Start = (%d,%d)\n" x y;
	Printf.printf "Size = %d\n" n;;

let x = 2;;
let y = 2;;
let n = 5;;

print_conditions x y n;;
let solution = dfs (Cell(x,y)) n;;
print_path solution;;

wait_for_key;;