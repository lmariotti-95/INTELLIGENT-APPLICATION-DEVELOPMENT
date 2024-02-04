type 'a graph = Graph of ('a->'a list);;
type cell = Cell of (int * int);;
type weight = Weight of (cell * int);; (* Warnsdorff *)

(* 
-----------------------------------------------------
	Definizione delle eccezioni 
-----------------------------------------------------
*)
exception UnvalidPosition;;
exception NotFound;;
exception UnvalidAlgorithm;;

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

(* move : cell -> int -> cell list -> cell list *)
let move c n c_list =
	let rec aux = function
		[] -> []
		| f::rest -> try (f c n c_list)::(aux rest)
				with UnvalidPosition -> aux rest in
aux [move_up_rg; move_rg_up; move_rg_dn; move_dn_rg; move_dn_lf; move_lf_dn; move_lf_up; move_up_lf];;

(* 
-----------------------------------------------------
	Definizione della funzione euristica di Warnsdorff
	1) Una cella Q è accessibile dalla cella P se può essere raggiunta in 1 mossa e Q non è stata visitata
	2) S è l'insieme delle celle accessibili da P (Q c S)
	3) L'accessibilità di P è la cardinalità delle sue celle accessibili cioè |S|

	Data una cella P determino S, per ogni cella in S determino la sua accessibilità.
	Il valore dell'euristica di Warnsdorff sarà il minimo delle accessibilità in S.
-----------------------------------------------------
*)

(* 
	Data una cella determina l'insieme delle celle accessibili (S)
*)
(* move : cell -> int -> cell list -> cell list *)
let get_accessible_cells c n c_list = move c n c_list;;

(* 
	Calcola l'accessibilità di una cella cioè quante celle non visitate può raggiungere
*)
(* compute_accessibility: cell -> int -> cell list -> int *)
let compute_accessibility c n c_list = 
  let s = get_accessible_cells c n c_list in
  Weight(c, List.length s - 1);;

(* 
	Dati due pesi determina se w1 < w2
*)
(* min_weight: weight -> weight -> bool *)
let min_weight wgt_1 wgt_2 =
	let Weight(c1, w1) = wgt_1 in 
	let Weight(c2, w2) = wgt_2 in 
	w1 < w2;;

(* 
	Data una lista di pesi determina il peso minore e ne restituisce la cella
*)
(* get_min_weight: weight list -> cell *)
let get_min_weight wgt_list = 
  let minimum = ref (Weight(Cell(0,0), 65535)) in
  let n = List.length wgt_list in
  
  for i = 0 to (n - 1) do 
    let current_weight = List.nth wgt_list i in
    if min_weight current_weight !minimum then
      (
        minimum := current_weight
      )
  done;
  match !minimum with Weight(c, w) -> w;; 
	
(*
	Data una cella determina i valori di accessibilità di tutte le sue celle accessibili 
*)
(* warnsdorff_heuristic: cell -> int -> cell list -> int list *)
let warnsdorff_heuristic c n c_list = 
  let s = get_accessible_cells c n c_list in
  get_min_weight (List.map (function x -> compute_accessibility x n c_list) s);;

(* 
-----------------------------------------------------
	BFS - Breadth  First Search
-----------------------------------------------------
*)
let extend path n = 
  print_path path; 

	(* 
		val map : ('a -> 'b) -> 'a list -> 'b list
		map f [a1; ...; an] applies function f to a1, ..., an, and builds the list [f a1; ...; f an] with the results returned by f.
		
		val filter : ('a -> bool) -> 'a list -> 'a list
		filter f l returns all the elements of the list l that satisfy the predicate f. The order of the elements in the input list is preserved.
	*)
  List.map (function x -> x::path)
    (List.filter (function x -> not (List.mem x path)) (move (List.hd path) n (List.tl path)));;

(* 
	Implementazione dell'algorimo di ricerca in ampiezza;
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

(*
	Determina il migliore tra due percorsi secondo la logica:
	f = g + h
	g = Distanza dal nodo inziziale cioè la lunghezza attuale del cammino
	h = Valutazione euristica di Warnsdorff

	minimizziamo il valore di f

	"The comparison function must return 0 if its arguments compare as equal, a positive integer if the first is greater, and a negative integer if the first is smaller"
*)
	let compare_path p1 p2 = 
		let g1 = List.length p1 in
		let g2 = List.length p2 in
		let h1 = warnsdorff_heuristic (List.hd p1) 5 p1 in
		let h2 = warnsdorff_heuristic (List.hd p2) 5 p2 in
		let f1 = g1 + h1 in
		let f2 = g2 + h2 in
	
		if f1 > f2 then 1
		else if f1 < f2 then -1
		else 0;;

(* 
	Implementazione dell'algorimo di ricerca in A*;
	Implementa l'euristica di Warnsdorff;
	Prende in ingresso il nodo inziale (in questo caso la cella di partenza) e la dimensione della scacchiera;
*)
let a_star start n =
  let rec search_aux = function
		[] -> raise NotFound
    | path::rest -> 
			if goal path n
        then List.rev path
				else search_aux (List.sort compare_path (rest @ (extend path n)))
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
	match algo with 
	"BFS" -> 
		let solution = bfs (Cell(x, y)) n in
		Printf.printf("Solution:\n");
		print_path solution;
	|"DFS" -> 
		let solution = dfs (Cell(x, y)) n in
		Printf.printf("Solution:\n");
		print_path solution;
	|"A_STAR" -> 
		let solution = a_star (Cell(x, y)) n in
		Printf.printf("Solution:\n");
		print_path solution;
	|_ -> 
		Printf.printf "Unvalid algorithm\n";
		raise UnvalidAlgorithm;;

let main() = 
	let num_args = Array.length Sys.argv in
	if num_args < 4 then
	(
		Printf.printf "Unvalid args number\n";
		exit 1
	)
	else
	(
		let x = int_of_string Sys.argv.(1) in
		let y = int_of_string Sys.argv.(2) in
		let n = int_of_string Sys.argv.(3) in
		let algo = Sys.argv.(4) in

		print_conditions x y n algo;
		
		try
			solve x y n algo;
			Printf.printf "Done";
			exit 0
		with UnvalidAlgorithm -> exit 1
	)

let _ = main();; 