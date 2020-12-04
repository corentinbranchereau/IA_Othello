% IDS
% IA selon la methode iterative deepening depth-first search
% Elle augmente la profondeur de recherche jusqu à dépasser la profondeur max ou le temps de recherche max

:- writeln('IDS has loaded.').

%Return the unique key of the node : Board + Player
getKey(Board, Key, Player) :- atomic_list_concat(Board,KeyInter), atom_concat(KeyInter,Player,Key).

%Implementation of the iterative deepening depth-first search
%Increase the depth and launch the mtdf algorithm until depth max is reached or time is out.
ids(_, Depth, TimeMax, _, _, _, Move, FinalMove, Time) :-
      get_time(NewTime),
      DiffTime is (NewTime-Time)*(NewTime-Time),
      DiffTime >= TimeMax,
      write("DEPTH = "),
      DepthDisp is Depth-1,
      writeln(DepthDisp),
      FinalMove is Move,!.
ids(_, Depth, _, DepthMax, _, _, Move, FinalMove, _) :-
      Depth > DepthMax,
      write("DEPTH = "),
      DepthDisp is Depth-1,
      writeln(DepthDisp),
      FinalMove is Move,!.
ids(FirstGuess, Depth, TimeMax, DepthMax, Board, Player, _, FinalMove, Time) :-
      Depth =< DepthMax,
      mtdf(-1000000, 1000000, Depth, Board, Player, FirstGuess, _, NewMove, Value),
      NewDepth is Depth+1,
      ids(Value, NewDepth, TimeMax, DepthMax, Board, Player, NewMove, FinalMove, Time),!.

%Memory-enhanced Test Driver algorithm
%Launch alpha-beta algorithm with a zero-window search, search for a bound to the minimax value until converging to the minimax value.
mtdf(Low, Upp, _, _, _, Value, Move, MoveFinal, LastFinalValue) :-
      Low >= Upp,
      MoveFinal is Move,
      LastFinalValue is Value.
mtdf(Low, Upp, Depth, Board, Player, Value, _, MoveFinal, LastFinalValue) :-
      Low<Upp,
      (
            Value == Low ->
            Beta is Value + 1 ;
            Beta is Value
      ),
      Alpha is Beta - 1,
      alpha_beta_ids(Board, NewMove, Depth, Player, Alpha, Beta, ValueFinal),
      (
            ValueFinal < Beta ->
            Upp2 is ValueFinal, Low2 is Low ;
            Low2 is ValueFinal, Upp2 is Upp
      ),
      mtdf(Low2, Upp2, Depth, Board, Player, ValueFinal, NewMove, MoveFinal, LastFinalValue).

%Launch the alpha-beta algorithm and return the best move that has been found
alpha_beta_ids(Pos, Move, Depth, Player, Alpha, Beta, ValueFinal) :-
      getCopie(Pos, BoardCopie),
      alpha_beta_vertical_ids(Depth, BoardCopie, Player, ValueFinal, Move, Alpha, Beta).

alpha_beta_vertical_ids(_, Board, Player, Value, _, _, _) :-
      %Check if there is a winner
      gameoverWithResult(Board, Winner,Nb),
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

alpha_beta_vertical_ids(0, Board, PlayerCoef, Value, _, _, _) :-
      %Depth = 0
      playerini(1, PlayerIni),
      playerini(-1, Opponent),
      heuristicPlayer(PlayerIni, H),
      heuristic(H, Board, V, PlayerIni, Opponent),
      ValueRound is round(V),
      Value is ValueRound * PlayerCoef.

%If the node has been seen previously, return his value which was stored in a dictionnary
alpha_beta_vertical_ids(D, Board,Player, Value,_, _,_) :-
      D>0,
      hashmap(Map),
      getBoardDisplay(Board,Board1),
      getKey(Board1,Key,Player),
      MapValue = Map.get(Key),
      nth0(0,MapValue,EntryDepth),
      EntryDepth>=D,
      nth0(1,MapValue,Value).

%Vertical search for the alpha-beta algorithm : go deeper in the game tree
alpha_beta_vertical_ids(D, Board,Player, Value, Move, Alpha, Beta) :-
      D > 0,
      D1 is D - 1,
      playerini(Player, PlayerIni),
      (
            allValidMovesSorted(Board, PlayerIni,_,Moves)->
            alpha_beta_horizontal_ids(Moves, Board, D1, Player,-1, Value, Move, Alpha, Beta,-1000000,_) ;
            alpha_beta_horizontal_vide_ids([], Board, D1, Player,-1, Value, Move, Alpha, Beta,-1000000,_)
      ),

      alpha_beta_store_ids(D1, Board,Player,Value).

%Store the value of the node in a dictonnary
alpha_beta_store_ids(D, Board,Player, Value):-
      hashmap(Map1),
      retract(hashmap(Map1)),
      getBoardDisplay(Board,Board1),
      getKey(Board1,Key,Player),
      length(ValueAdd,2),
      nth0(0,ValueAdd,D),
      nth0(1,ValueAdd,Value),
      MapF=Map1.put(Key,ValueAdd),
      assertz(hashmap(MapF)).

%Horizontal search for the alpha-beta algorithm : select the best move at a given depth of the game tree

alpha_beta_horizontal_ids([], _, _, _, Best1, Value1, Best1, Value1, _,_,_):-Best1>=0.

alpha_beta_horizontal_ids([], _, _, _, _, OldValue,OldMove,_, _,OldValue,OldMove).

alpha_beta_horizontal_ids([Move|Moves], Board, D, Player, Move0, BestValue, BestMove, Alpha, Beta,OldValue,OldMove) :-
      getCopie(Board, BoardCopie),
      playerini(Player, PlayerIni),
      playMove(BoardCopie, Move, PlayerIni, Board1),
      Opponent is -Player,
      OppAlpha is -Beta,
      OppBeta is -Alpha,
      alpha_beta_vertical_ids(D, Board1, Opponent, OppValue, _OppMove, OppAlpha, OppBeta),
      Value is -OppValue,
      (
            Value >= Beta ->
            BestValue = Value, BestMove = Move ;
            (
                  (
                        Value > Alpha ->
                        alpha_beta_horizontal_ids(Moves, Board, D, Player, Move, BestValue, BestMove, Value, Beta,Value,Move) ;
                        (
                              Value>OldValue ->
                              alpha_beta_horizontal_ids(Moves, Board, D, Player, Move0, BestValue, BestMove, Alpha, Beta,Value,Move);
                              alpha_beta_horizontal_ids(Moves, Board, D, Player, Move0, BestValue, BestMove, Alpha, Beta,OldValue,OldMove)
                        )
                  )
            )
      ).

%Horizontal search when player cannot play : skip his turn
alpha_beta_horizontal_vide_ids(Moves, Board, D, Player, Move0, BestValue, BestMove, Alpha, Beta,OldValue,OldMove) :-
      Opponent is -Player,
      OppAlpha is -Beta,
      OppBeta is -Alpha,
      alpha_beta_vertical_ids(D, Board, Opponent, OppValue, _OppMove, OppAlpha, OppBeta),
      Value is -OppValue,
      (
            Value >= Beta ->
            BestValue = Value ;
            (
                  (
                        Value > Alpha ->
                        alpha_beta_horizontal_ids(Moves, Board, D, Player, _, BestValue, BestMove, Value, Beta,Value,_) ;
                        (
                              Value > OldValue ->
                              alpha_beta_horizontal_ids(Moves, Board, D, Player, Move0, BestValue, BestMove, Alpha, Beta,Value,_) ;
                              alpha_beta_horizontal_ids(Moves, Board, D, Player, Move0, BestValue, BestMove, Alpha, Beta,OldValue,OldMove)
                        )
                  )
            )
      ).