% MINIMAX
% IA selon la methode minimax
% Elle cherche les differents coups à jouer sur une profondeur donnée, puis selectionne le chemin qui mene vers le meilleur selon lheuristique choisie.

:- writeln('Minimax has loaded.').

%Select the chosen heuristic
heuristic(2, Board, Value, _, _) :- heuristic_disk_diff(Board, Value).
heuristic(3, Board, Value, P1, P2) :- heuristic_stability(Board, P1, P2, Value).
heuristic(4, Board, Value, P1, P2) :- heuristic_actual_mobility(Board, P1, P2, Value).
heuristic(5, Board, Value, P1, P2) :- heuristic_coin_parity(Board, P1, P2, Value).
heuristic(6, Board, Value, P1, P2) :- heuristic_cornersCaptured(Board, P1, P2, Value).
heuristic(7, Board, Value, P1, P2) :- heuristic_potential_mobility(Board, P1, P2, Value).

%Launch the alpha-beta algorithm and return the best move that has been found
alpha_beta(Pos, Move, Depth, Player) :- alpha_beta_vertical(Depth, Pos,Player, _, Move, -1000000000, 1000000000).

%Find all valid moves for a player and sorts them according to position on the board. 
%The potential best moves go at the beginning of the list and the worst moves at the end.
allValidMovesSorted(Board, Player, List,ListSorted):-
	allValidMoves(Board, Player, List),
	sortMoves(List,
	[0, 7, 56, 63, 2,3,4,5,
	16,23,24,31,32,39,40,47,
	58,59,60,61,18,21,42,45,
	19,20,26,34,29,37,43,44,
	10,11,12,13,17,25,33,41,
	22,30,38,46,50,51,52,53,
	1,6,8,15,48,55,57,62,
	9,14,49,54],
	ListSorted).

%Sorts all Moves according to the static position on the board : corners first etc ...
%Each case has a value. More the play on the case is good (statically), the greater the value is.
sortMoves(Moves,Reference,[T|Q]):-nth0(Index,Reference,T),member(T,Moves),subtract(Moves,[T],NewMoves),sortMoves2(NewMoves,Reference,Q,Index).
sortMoves2([],_,[],_).
sortMoves2(Moves,Reference,[T|Q],I):-nth0(I2,Reference,T),member(T,Moves),subtract(Moves,[T],NewMoves),I<I2,sortMoves2(NewMoves,Reference,Q,I2).

%Vertical search for the alpha-beta algorithm : go deeper in the game tree
alpha_beta_vertical(_, Board, Player, Value, _, _, _) :-
      %Check if there is a winner
      gameoverWithResult(Board, Winner, Nb),
	playerini(1, X),
      playerini(-1, Opponent),
      (
            Winner == X ->
            Value is (1000) * Player * Nb;
            (Winner == Opponent -> 
            Value is (-1000) * Player * Nb;
            Value is 0
            )   
      ).

alpha_beta_vertical(0, Board, PlayerCoef, Value, _, _, _) :-
      %Depth = 0
	playerini(1, PlayerIni),
      playerini(-1, Opponent),
      heuristicPlayer(PlayerIni, H),
	heuristic(H, Board, V, PlayerIni, Opponent),
      Value is V * PlayerCoef.

alpha_beta_vertical(D, Board,Player, Value, Move, Alpha, Beta) :-
      D > 0, 
      D1 is D - 1,
      playerini(Player, PlayerIni),
      (
            
            allValidMovesSorted(Board, PlayerIni,_,Moves)->
            alpha_beta_horizontal(Moves, Board, D1, Player, nil, Value, Move, Alpha, Beta) ;
            alpha_beta_horizontal_vide([], Board, D1, Player, nil, Value, Move, Alpha, Beta)
	).

%Horizontal search for the alpha-beta algorithm : select the best move at a given depth of the game tree
alpha_beta_horizontal([], _, _, _, Best1, Value1, Best1, Value1, _).

alpha_beta_horizontal([Move|Moves], Board, D, Player, Move0, BestValue, BestMove, Alpha, Beta) :-
	getCopie(Board, BoardCopie),
	playerini(Player, PlayerIni),
	playMove(BoardCopie, Move, PlayerIni, Board1),
	Opponent is -Player,
      OppAlpha is -Beta,
      OppBeta is -Alpha,
      alpha_beta_vertical(D, Board1, Opponent, OppValue, _OppMove, OppAlpha, OppBeta), 
      Value is -OppValue,
      (
            Value >= Beta -> 
            BestValue = Value, BestMove = Move ;
            (
                  Value > Alpha ->        
                  alpha_beta_horizontal(Moves, Board, D, Player, Move, BestValue, BestMove, Value, Beta) ; 
                  alpha_beta_horizontal(Moves, Board, D, Player, Move0, BestValue, BestMove, Alpha, Beta)
            )
      ).

%Horizontal search when player cannot play : skip his turn
alpha_beta_horizontal_vide(Moves, Board, D, Player, Move0, BestValue, BestMove, Alpha, Beta) :-
      Opponent is -Player,
      OppAlpha is -Beta,
      OppBeta is -Alpha,
      alpha_beta_vertical(D, Board, Opponent, OppValue, _OppMove, OppAlpha, OppBeta),
      Value is -OppValue,
      (
            Value >= Beta -> 
            BestValue = Value, BestMove = Move ;
   	      (
                  Value > Alpha ->        
                  alpha_beta_horizontal(Moves, Board, D, Player, Move, BestValue, BestMove, Value, Beta) ; 
                  alpha_beta_horizontal(Moves, Board, D, Player, Move0, BestValue, BestMove, Alpha, Beta)
            )
      ).