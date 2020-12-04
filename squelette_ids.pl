%%%%%%%%%%%%%%%%%%
% OTHELLO PROLOG %
% BRANCHEREAU C. %
% GRAVEY THIBAUT %
% DE ANDRIA Q.   %
% ROB LOUIS      %
% MIGNOT THOMAS  %
% OECHSLIN K.    %
%%%%%%%%%%%%%%%%%%

%Rules : https://www.ultraboardgames.com/othello/game-rules.php
%Heuristics : https://courses.cs.washington.edu/courses/cse573/04au/Project/mini1/RUSSIA/Final_Paper.pdf

%Objective : The goal is to get the majority of colour disks on the board at the end of the game.

%Creation of the boarding game at the begin of the play
%%The board will start with 2 black discs and 2 white discs at the centre of the board.
%%They are arranged with black forming a North-East to South-West direction.
%%White is forming a North-West to South-East direction.
%%Black always moves first.
:- writeln('Bienvenue sur Prolog_Othello-IA !').
:- dynamic(board/1).
:- dynamic(playerini/2).
:- dynamic(heuristicPlayer/2).
:- dynamic(timePlayer/2).
:- dynamic(playerType/2).
:- dynamic(hashmap/1).
:- retractall(hashmap(_)).
:- retractall(board(_)).
:- retractall(playerini(_, _)).
:- retractall(heuristicPlayer(_, _)).
:- retractall(timePlayer(_, _)).
:- retractall(playerType(_, _)).
:- writeln('Chargement de ids : ').
:- [ids].
:- writeln('Chargement des Heuristics : ').
:- [heuristic_disk_diff].
:- [heuristic_coin_parity].
:- [heuristic_actual_mobility].
:- [heuristic_potential_mobility].
:- [heuristic_stability].
:- [heuristic_cornersCaptured].

init :- 
	retractall(board(_)),
	retractall(hashmap(_)),
	retractall(playerini(_, _)),
	retractall(heuristicPlayer(_, _)),
	retractall(timePlayer(_, _)),
	retractall(playerType(_, _)),
	length(Board,64),
	nth0(27,Board,'w'),
	nth0(28,Board,'b'),
	nth0(35,Board,'b'),
	nth0(36,Board,'w'),
	assertz(board(Board)),
	assertz(hashmap(_{})),
	writeln('Initialisation du board OK'),
	repeat,
	writeln(' ----- '),
	writeln('Le joueur noir (b) est : '),
	writeln('1) Humain'),
	writeln('2) IA'),
	writeln(' ----- '),
	read(PB),
	PB > 0,
	PB < 3,
	assertz(playerType(b, PB)),
	(
		PB == 2 ->
		(
			repeat,
			writeln(' ----- '),
			writeln('Choisissez l\'heuristique pour le joueur noir (b)'),
			chooseHeuristic(b, HB),
			(
				HB > 1 ->
				(
					repeat,
					writeln('Choisissez le temps maximal pour le joueur noir (b)'),
					read(TB),
					TB>0,
					assertz(timePlayer(b, TB))
				) ;
				true
			)
		) ;
		true
	),
	repeat,
	writeln(' ----- '),
	writeln('Le joueur blanc (w) est : '),
	writeln('1) Humain'),
	writeln('2) IA'),
	writeln(' ----- '),
	read(PW),
	PW > 0,
	PW < 3,
	assertz(playerType(w, PW)),
	(
		PW == 2 ->
		(
			repeat,
			writeln(' ----- '),
			writeln('Choisissez l\'heuristique pour le joueur blanc (w)'),
			chooseHeuristic(w, HW),
			(
				HW > 1 ->
				(
					repeat,
					writeln('Choisissez le temps maximal pour le joueur blanc (w)'),
					read(TW),
					TW>0,
					assertz(timePlayer(w, TW))
				) ;
				true
			)
		) ;
		true
	),
	displayBoard,
	play('b').

%Choose the heuristic for the given player
chooseHeuristic(Player, H) :- 
	writeln(' 1) Heuristique "random"'),
	writeln(' 2) Heuristique "disk difference"'),
	writeln(' 3) Heuristique "stability"'),
	writeln(' 4) Heuristique "actual mobility"'),
	writeln(' 5) Heuristique "coin parity"'),
	writeln(' 6) Heuristique "corners captured"'),
	writeln(' 7) Heuristique "potential mobility"'),
	writeln(' ----- '),
	read(H),
	H>0,
	H<8,
	assertz(heuristicPlayer(Player, H)).

%Playing turn
%%if there is no winner, we made a normal turn for the next player
%%If you cant outflank and flip at least one opposing disc, you must pass 
%%your turn. However, if a move is available to you, you cant forfeit your turn.
%%if a player cannot make a valide move, he pass his turn and the opponent continues
play(_) :- 	 gameover(Winner), !, format('Game is over, the winner is ~w ~n',[Winner]), displayBoard.
play(Player) :- board(Board), canMakeAMove(Board,Player), format('New turn for : ~w ~n',[Player]), displayBoard, playerType(Player, Type),
				(Type == 2 -> ia(Board,Player,Move) ; human(Board,Player,Move)), playMove(Board,Move,Player,NewBoard), applyIt(Board,NewBoard), switchPlayer(Player,NextPlayer), play(NextPlayer).
play(Player) :- format('Player "~w" can not play.~n',[Player]), switchPlayer(Player,NextPlayer), play(NextPlayer).

%Check if a move is still available for the player
%%find one valid move then stop backtrack
%TODO : IMPROVE PERF
canMakeAMove(Board,Player) :- setof(X, isValid(Board,Player,X), List), member(_,List).

%Get all valid moves for a player
allValidMoves(Board, Player, List) :- setof(X, isValid(Board,Player,X), List).

%Check if a move is valid
isValid(Board,Player,Index) :- 
	emptyCell(Board,Index),
	(isSandwich(Board,Player,Index,top);
	isSandwich(Board,Player,Index,down);
	isSandwich(Board,Player,Index,left);
	isSandwich(Board,Player,Index,right);
	isSandwich(Board,Player,Index,diagNW);
	isSandwich(Board,Player,Index,diagNE);
	isSandwich(Board,Player,Index,diagSE);
	isSandwich(Board,Player,Index,diagSW)). 

%Check if a cell is empty
emptyCell(Board,Index) :- nth0(Index,Board,X), var(X).

%Check in all direction if there is a sandwich (at least one opposite disk then a player disk)
isSandwich(Board,Player,Index,Direction) :- switchPlayer(Player,Opponent), listDiskInDirection(Board,Index,Direction,[],FinalList), nth0(0, FinalList, Temp), nonvar(Temp), Temp == Opponent, check_sandwich(Player, FinalList). 

%List all the disk in a precise direction from the index to the last cell of the direction
listDiskInDirection(_,Index,Direction,List,FinalList) :- \+ nextCell(Index,Direction,_), !, FinalList = List.
listDiskInDirection(Board,Index,Direction,List,FinalList) :- nextCell(Index,Direction,NextCellIndex), getDisk(Board, NextCellIndex, Disk), append(List,[Disk],NewList), listDiskInDirection(Board,NextCellIndex,Direction,NewList,FinalList). 

%Get the next cell depends on the direction, false if there is no more
nextCell(CellIndex, top, NextCellIndex) :- NextCellIndex is CellIndex-8, NextCellIndex > -1.
nextCell(CellIndex, down, NextCellIndex) :- NextCellIndex is CellIndex+8, NextCellIndex < 64.
nextCell(CellIndex, left, NextCellIndex) :- Mod is CellIndex mod 8, Mod =\= 0, NextCellIndex is CellIndex-1.
nextCell(CellIndex, right, NextCellIndex) :- Mod is CellIndex mod 8, Mod =\= 7, NextCellIndex is CellIndex+1.
nextCell(CellIndex, diagNW, NextCellIndex) :- Mod is CellIndex mod 8, Mod =\= 0, X is CellIndex-9, X > -1, NextCellIndex is CellIndex-9.
nextCell(CellIndex, diagNE, NextCellIndex) :- Mod is CellIndex mod 8, Mod =\= 7, X is CellIndex-7, X > -1, NextCellIndex is CellIndex-7.
nextCell(CellIndex, diagSE, NextCellIndex) :- Mod is CellIndex mod 8, Mod =\= 7, X is CellIndex+9, X < 64, NextCellIndex is CellIndex+9.
nextCell(CellIndex, diagSW, NextCellIndex) :- Mod is CellIndex mod 8, Mod =\= 0, X is CellIndex+7, X < 64, NextCellIndex is CellIndex+7.

%Get the disk at a precise index
getDisk(Board, Index, Disk) :- nth0(Index, Board, Disk).

%Check if its a sandwich or not
check_sandwich(_, []) :- !, fail.
check_sandwich(_, [H|_]) :- var(H), !, fail.
check_sandwich(Player, [H|_]) :- H == Player.
check_sandwich(Player, [H|T]) :- H \== Player, check_sandwich(Player,T).

%Play a regular move
playMove(Board, Move, Player, NewBoard) :- nth0(Move,Board,Player), flipAll(Board,Move,Player,List),majBoard(Board,Player,List,NewBoard),!.

%Get the list of all flipped disk
flipAll(Board,Move,Player,List) :- 
	flip(Board,Move,Player,top,L1),
	flip(Board,Move,Player,down,L2),
	flip(Board,Move,Player,left,L3),
	flip(Board,Move,Player,right,L4),
	flip(Board,Move,Player,diagNE,L5),
	flip(Board,Move,Player,diagNW,L6),
	flip(Board,Move,Player,diagSE,L7),
	flip(Board,Move,Player,diagSW,L8),
	append([L1,L2,L3,L4,L5,L6,L7,L8],List),!.

%Try to Flip in a precise direction, give the flipped disk index (FinalList)
flip(Board,Move,Player,Direction,FinalList) :- 
	switchPlayer(Player,Opponent), 
	listDiskInDirection(Board,Move,Direction,[],CompleteDiskList),
	((\+(member(_,CompleteDiskList)) ; [H|_] = CompleteDiskList, \+(H==Opponent)) -> FinalList = [] ;
	[_|DiskList] = CompleteDiskList,
	checkSandwichEmptyList(Player, DiskList, List), (\+ member(_,List) -> FinalList = [] ;
	countAlignedDisk(Player, DiskList, 1, FinalValue), flipNDisk(Move, Direction, FinalValue, [], FinalList))).

%Count the number of aligned disk (of the same color) on the list
countAlignedDisk(_,[], Value, FinalValue) :- FinalValue is Value, !.
countAlignedDisk(_,[H|_], Value, FinalValue) :- var(H), FinalValue is Value, !.
countAlignedDisk(Player,[H|_], Value, FinalValue) :- H == Player, FinalValue is Value, !.
countAlignedDisk(Player, [H|T], Value, FinalValue) :- H \== Player, X is Value+1, countAlignedDisk(Player, T, X, FinalValue).

%Give the index list of n disk in a precise direction
flipNDisk(_, _, 0, List, FinalList) :- FinalList = List, !.
flipNDisk(Index, Direction, N, List, FinalList) :- nextCell(Index, Direction, NextCellIndex), N1 is N-1, append(List, [NextCellIndex], NewList), flipNDisk(NextCellIndex, Direction, N1, NewList, FinalList).

%Check sandwich which return an empty list if false
checkSandwichEmptyList(_, [], List) :- !, List = [].
checkSandwichEmptyList(_, [H|_], List) :- var(H), !, List = [].
checkSandwichEmptyList(Player, [H|_], List) :- H == Player, List = [true].
checkSandwichEmptyList(Player, [H|T], List) :- H \== Player, checkSandwichEmptyList(Player,T, List).

%Maj the board with by flipping the disk in the list
majBoard(Board,_,[],NewBoard) :- NewBoard = Board, !.
majBoard(Board,Player,[H|T],NewBoard) :- replace(Board,H,Player,BoardUpdated), majBoard(BoardUpdated,Player,T,NewBoard).

%Replace an element at a given index to another element
replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]):- I > -1, NI is I-1, replace(T, NI, X, R), !.

%Implement IA
ia(Board, Player, Move) :-
	heuristicPlayer(Player, H),
	(
		H == 1 ->
		(
			%Random IA
			allValidMoves(Board, Player, List), 
			length(List, Length), 
			random(0, Length, Index), 
			nth0(Index, List, Move)
		);
		(
			timePlayer(Player, TimeMax),
			switchPlayer(Player, Opponent),
			getCopie(Board, BoardCopie),
			retractall(hashmap(_)),
			assertz(hashmap(_{})),
			get_time(Time),
			assertz(playerini(-1, Opponent)),
			assertz(playerini(1, Player)),
			countDisk(Board,0,0,B,W),
			DepthMax is (64 - B - W),
			ids(0,1,TimeMax,DepthMax,BoardCopie,1,_,Move,Time),
			retract(playerini(-1, Opponent)),
			retract(playerini(1, Player))
		)
	),
	format('IA plays move number ~w ~n', [Move]).

%Ask for the move of the human player
human(Board,Player,Move) :-
	allValidMoves(Board, Player, ListMoves),
	repeat,
	writeln('Selectionnez le coup que vous voulez jouer parmis les suivants :'),
	write(ListMoves),
	read(Move),
	member(Move, ListMoves),
	format('Vous avez joue le coup ~w ~n', [Move]).

%Save the new board and remove the old one from the knowledge base
applyIt(Board,NewBoard) :- 
	retract(board(Board)),
	assertz(board(NewBoard)).

%Switch player
switchPlayer('b','w').
switchPlayer('w','b').

%End of the game
%%When it is no longer possible for either player to move, the game is over.
%%The discs are now counted and the player with the majority of his or her color 
%%discs on the board is the winner.
%%A tie is possible.
gameover(Winner) :- board(Board), \+ canMakeAMove(Board,'w'), \+ canMakeAMove(Board,'b'), findWinner(Board,Winner, B, W), format('~w black disks against ~w white disks.~n',[B,W]).
gameover(Board, Winner) :- \+ canMakeAMove(Board,'w'), \+ canMakeAMove(Board,'b'), findWinner(Board,Winner, _, _).

gameoverWithResult(Board, Winner,Nb) :- \+ canMakeAMove(Board,'w'), \+ canMakeAMove(Board,'b'), findWinner(Board,WinnerInter, B, W),(WinnerInter=='White' -> Winner='w',Nb is W ; Winner='b', Nb is B).

%Find the winner
findWinner(Board, Winner, B, W):- countDisk(Board,0,0,B,W), selectWinner(B,W,Winner).
	
%Count the number of disk for each player B and W
countDisk([],B,W,FinalB,FinalW) :- FinalB is B, FinalW is W.
countDisk([H|T],B,W,FinalB,FinalW) :- nonvar(H),H == 'b', X is B+1, countDisk(T,X,W,FinalB,FinalW).
countDisk([H|T],B,W,FinalB,FinalW) :- nonvar(H),H == 'w', Y is W+1, countDisk(T,B,Y,FinalB,FinalW).
countDisk([_|T],B,W,FinalB,FinalW) :- countDisk(T,B,W,FinalB,FinalW).

countDiskPerPlayer([],_,NbDisk,FinalNbDisk) :- FinalNbDisk is NbDisk.
countDiskPerPlayer([H|T],Player,NbDisk,FinalNbDisk) :- H == Player, X is NbDisk+1, countDiskPerPlayer(T,Player,X,FinalNbDisk).
countDiskPerPlayer([_|T],Player,NbDisk,FinalNbDisk) :- countDiskPerPlayer(T,Player,NbDisk,FinalNbDisk).

%Select the winner depends on B and W the count of the disk
selectWinner(B,W,Winner) :- B=:=W, Winner='Draw'.
selectWinner(B,W,Winner) :- B=\=W, B<W, Winner='White'.
selectWinner(B,W,Winner) :- B=\=W, B>W, Winner='Black'.

%Display the othello board
displayBoard :- writeln('ABCDEFGH'), board(Board), displayRow(Board,0), writeln('ABCDEFGH').

displayBoardPerso(Board) :- writeln('ABCDEFGH'),displayRow(Board,0), writeln('ABCDEFGH').

%Display the othello board
displayBoardPerso(Board) :- writeln('ABCDEFGH'), displayRow(Board,0), writeln('ABCDEFGH').

displayRow([],_) :- writeln('').
displayRow(Board,8) :- writeln(''), displayRow(Board,0).
displayRow([H|T],X) :- Y is X+1, display(H), displayRow(T,Y).

display(Elem) :- var(Elem), write('_').
display(Elem) :- write(Elem).

%Get a copie of the board
getCopie([],[]).
getCopie([H|T],[H1|T1]):-var(H),var(H1),H1\==H,getCopie(T,T1).
getCopie([H1|T1],[H1|T2]):- \+(var(H1)),getCopie(T1,T2).

%Get a copie of the board with the special value o for the blank cases
getBoardDisplay([],[]).
getBoardDisplay([H|T],[H1|T1]):-var(H),H1=o,getBoardDisplay(T,T1).
getBoardDisplay([H1|T1],[H1|T2]):- \+(var(H1)),getBoardDisplay(T1,T2).