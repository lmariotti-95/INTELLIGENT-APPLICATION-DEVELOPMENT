# Intelligent-Application-Development
Progetto per il corso [LM-18] INFORMATICA / ARTIFICIAL INTELLIGENT SYSTEMS - INTELLIGENT APPLICATION DEVELOPMENT

## Progetto

**Problema salto del cavallo pigro (ricerca ampiezza)**  
Data una scacchiera NxN ed un cavallo posizionato su una casella trovare una  
sequenza di mosse che consenta al cavallo di occupare tutte le caselle delle  
scacchiera ciascuna esattamente una volta.  
Si risolva il problema utilizzando un algoritmo di ricerca in ampiezza.

## Enviroment
- https://try.ocamlpro.com/
- https://ocaml.org/play
  
## Compilazione
> ocamlc main.ml -o main.exe

## Esecuzione
> main.exe x y n 
x = Coordinata X della cella iniziale  
y = Coordinata Y della cella iniziale  
n = Dimensione della scacchiera NxN

## Implementazioni
- [ ] Gestione degli argomenti in ingresso all'esecuzione
- [x] BFS - Breadth-first search;
- [x] DFS - Depth-first search;
- [ ] A*  - Ricerca euristica implementando **Warnsdorf's rule**;
