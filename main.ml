type 'a graph = Gr of ('a * 'a list) list ;;
type cell = Cell of (x of int * y of int);;

let grafo = Gr [(1,[2;3;4]); (2,[6]); (3,[5]); (4,[6]); (5,[4]); (6,[5;7])] ;;

(* 
-----------------------------------------------------
	Definizione delle eccezioni 
-----------------------------------------------------
*)
exception UnvalidPosition;;
exception NotFound;;

(* 
-----------------------------------------------------
	Definizione delle azioni 
-----------------------------------------------------
*)

(* cell -> int -> bool *)
let is_valid c n = match c with
  | Cell(x, y) -> x >= 0 && y >= 0 && x < n && y < n;;

(* cell -> int -> cell *)
let move_up_rg c n = match c with
	Cell(x, y) -> let landing = Cell(x + 1, y - 2) in
		if (is_valid landing n) then landing
        else raise UnvalidPosition;;
				  
(* cell -> int -> cell *)
let move_rg_up c n = match c with
	Cell(x, y) -> let landing = Cell(x + 2, y - 1) in
		if (is_valid landing n) then landing
        else raise UnvalidPosition;;
				  
(* cell -> int -> cell *)
let move_rg_dn c n = match c with
	Cell(x, y) -> let landing = Cell(x + 2, y + 1) in
		if (is_valid landing n) then landing
        else raise UnvalidPosition;;
				  
(* cell -> int -> cell *)
let move_dn_rg c n = match c with
	Cell(x, y) -> let landing = Cell(x + 1, y + 2) in
		if (is_valid landing n) then landing
        else raise UnvalidPosition;;
				  
(* cell -> int -> cell *)
let move_dn_lf c n = match c with
	Cell(x, y) -> let landing = Cell(x - 1, y + 2) in
		if (is_valid landing n) then landing
        else raise UnvalidPosition;;
				  
(* cell -> int -> cell *)
let move_lf_dn c n = match c with
	Cell(x, y) -> let landing = Cell(x - 2, y + 1) in
		if (is_valid landing n) then landing
        else raise UnvalidPosition;;
				  
(* cell -> int -> cell *)
let move_lf_up c n = match c with
	Cell(x, y) -> let landing = Cell(x - 2, y + 1) in
		if (is_valid landing n) then landing
        else raise UnvalidPosition;;
				  
(* cell -> int -> cell *)
let move_up_lf c n = match c with
	Cell(x, y) -> let landing = Cell(x - 1, y - 2) in
		if (is_valid landing n) then landing
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

(* move : cell -> int -> 'a list *)
let move c n =
	let rec aux = function
		[] -> []
		| f::rest -> try (f c n)::(aux rest)
				   with UnvalidPosition -> aux rest in
aux [move_up_rg; move_rg_up; move_rg_dn; move_dn_rg; move_dn_lf; move_lf_dn; move_lf_up; move_up_lf];;

(* 
-----------------------------------------------------
	BFS - Breadth  First Search
-----------------------------------------------------
*)

let bfs(Graph succ) p start = 
	let rec search visited = function
		[] -> raise NotFound
		| path::rest -> let a = List.hd path in
						if List.mem a visited then search visited rest
						else if p a then path
						else search (a::visited)(rest @ (succ path)) in
search [][start];;

let bf_search_path(Graph succ) p start = 
	List.rev(bfs(Graph (succpath succ)) p [start]);;
	
let solve() = bf_search_path(Graph boccali) goal;;