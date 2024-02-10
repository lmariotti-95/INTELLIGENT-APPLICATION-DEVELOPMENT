type 'a graph = Graph of ('a->'a list);;
type cell = Cell of (int * int);;

let g_size = ref 0;;
let explored_path = ref [];;

(* 
-----------------------------------------------------
	Definizione delle eccezioni 
-----------------------------------------------------
*)
exception UnvalidPosition;;
exception NotFound;;
exception UnvalidAlgorithm;;
exception Invalid_argument;;

(* 
-----------------------------------------------------
	Utility
-----------------------------------------------------
*)

(* cell -> string *)
let string_of_cell (Cell (x, y)) =
  Printf.sprintf "(%d, %d)" x y;;

(* cell list -> unit *)
let print_cell_list c_list =
  let string_list = List.map string_of_cell c_list in
  Printf.printf "[%s]\n" (String.concat "; " string_list);;

(* cell list -> unit *)
let print_path path = 
  print_cell_list path;;

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
-----------------------------------------------------
	Definizione della funzione successori
-----------------------------------------------------
*)

(* move : cell -> int -> cell list -> cell list *)
let move c n c_list =
	let rec aux = function
		[] -> []
		| f::rest -> try (f c n c_list)::(aux rest)
				with UnvalidPosition -> aux rest in
aux [move_up_rg; move_rg_up; move_rg_dn; move_dn_rg; move_dn_lf; move_lf_dn; move_lf_up; move_up_lf];;

(* is_closed : cell list -> int -> bool *)
let is_closed c_list n = 
	let last = List.nth c_list ((List.length c_list) - 1) in
	List.mem last (move (List.hd c_list) n (List.tl c_list));;

(* 
-----------------------------------------------------
	BFS - Breadth  First Search
-----------------------------------------------------
*)
(* extend: cell list -> int -> cell list list *)
let extend path n = 
	explored_path := path;
	print_path (List.rev !explored_path);

	(*print_path path; *)

	(* Doc OCaml:
		val map : ('a -> 'b) -> 'a list -> 'b list
		map f [a1; ...; an] applies function f to a1, ..., an, and builds the list [f a1; ...; f an] with the results returned by f.
		
		val filter : ('a -> bool) -> 'a list -> 'a list
		filter f l returns all the elements of the list l that satisfy the predicate f. The order of the elements in the input list is preserved.
	*)
  List.map (function x -> x::path)
    (List.filter (function x -> not (List.mem x path)) (move (List.hd path) n (List.tl path)));;

(* 
	Implementazione dell'algoritmo di ricerca in ampiezza;
	Prende in ingresso il nodo inziale (in questo caso la cella di partenza) e la dimensione della scacchiera	 
*)
let bfs start n =
  let rec search_aux = function
		[] -> raise NotFound
    | path::rest -> 
			if goal path n
        then List.rev path
        else search_aux (rest @ (extend path n))
  in search_aux [[start]];;

(* 
	Implementazione dell'algorimo di ricerca in profondità;
	Prende in ingresso il nodo inziale (in questo caso la cella di partenza) e la dimensione della scacchiera	 
*)
let dfs start n=
	let rec search_aux = function
		[] -> raise NotFound
		| path::rest -> 
			if goal path n
				then List.rev path
			else search_aux ((extend path n) @ rest)
in search_aux [[start]];;

(* Dato un cammino determina il numero dei successori *)
(* warnsdorff_heuristic: cell list -> int *)
let warnsdorff_heuristic path = List.length (List.filter (function x -> not(List.mem x path)) (move (List.hd path) !g_size (List.tl path)));;

(*
	Determina il migliore tra due percorsi secondo la logica:
	Il percorso con meno successori è da preferirsi
*)
(* compare_path: cell list -> cell list -> int *)
	let compare_path p1 p2 = 
		let c1 = (warnsdorff_heuristic p1) in
		let c2 = (warnsdorff_heuristic p2) in

		(* 
			OCaml doc: The comparison function must return 0 if its arguments compare as equal, 
			a positive integer if the first is greater, and a negative integer if the first is smaller 
		*)
		if c1 = c2 then 0
		else if c1 > c2 then 1
		else -1;;

(* 
	Implementazione dell'algorimo di ricerca Hill-climbing;
	Ad ogni passo viene espansa la soluzione parziale generata al passo
  precedente più promettente implementando l'euristica di Warnsdorff;
	Prende in ingresso il nodo inziale (in questo caso la cella di partenza) e la dimensione della scacchiera;
*)
let hill_climbing start n =
  let rec search_aux = function
      [] -> raise NotFound
    | path::rest -> 
        if goal path n
        then List.rev path
        else search_aux ((List.sort compare_path (extend path n)) @ rest)
  in search_aux [[start]];;

let print_conditions x y n algo = 
  Printf.printf "Executing %s\n" algo;
  Printf.printf "Start = (%d,%d)\n" x y;
  Printf.printf "Size = %d\n" n;;

(*
let x = 2;;
let y = 2;;
let n = 5;;

print_conditions x y n "DFS";;
let solution = dfs (Cell(x,y)) n;;
print_path solution;;

print_conditions x y n "A*";;
let solution = a_star (Cell(x,y)) n;;
print_path solution;;
*)

let solve x y n algo = 
	(* Mi assicuro della coerenza dei parametri *)
	assert(n > 0);
	assert(x >= 0 && x < n);
	assert(y >= 0 && y < n);

	let aviable_algos = ["BFS"; "DFS"; "HILL_CLIMBING"] in
	assert(List.mem algo aviable_algos);

	g_size := n;

	print_conditions x y n algo;

	match algo with 
	"BFS" -> 
		let solution = bfs (Cell(x, y)) n in

		Printf.printf("Solution:\n");
		print_path solution;
		if is_closed solution n then Printf.printf("Closed!:\n");

	|"DFS" -> 
		let solution = dfs (Cell(x, y)) n in

		Printf.printf("Solution:\n");
		print_path solution;
		if is_closed solution n then Printf.printf("Closed!:\n");

	|"HILL_CLIMBING" -> 
		let solution = hill_climbing (Cell(x, y)) n in

		Printf.printf("Solution:\n");
		print_path solution;
		if is_closed solution n then Printf.printf("Closed!:\n");

	|_ -> 
		Printf.printf "Unvalid algorithm\n";
		raise UnvalidAlgorithm;;

(*
	Inizio programma
*)
let num_args = Array.length Sys.argv in

(* Esempio: main.exe 0 0 5 BFS *)
assert (num_args = 5);

let x = int_of_string Sys.argv.(1) in
let y = int_of_string Sys.argv.(2) in
let n = int_of_string Sys.argv.(3) in
let algo = Sys.argv.(4) in

try
	solve x y n algo;
	Printf.printf "Done";
with UnvalidAlgorithm -> exit 1;;