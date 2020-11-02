% ACTUAL MOBILITY HEURISTIC

:-writeln('Mobility heuristic has loaded').

%Board le plateau actuel
%P1 est le joueur 1, pour lequel on calcule lheuristique: ie joueur MAX
%P2 est son adversaire, ie joueur MIN
%H la valeur de lheuristique (à passer comme variable)


heuristic_actual_mobility(Board, P1, P2, H) :- 
    %compter le nombre de coups possibles pour P1 puis
    %compter le nombre de coups possibles pour P2
    (
        allValidMoves(Board, P1, ListP1) ->
        length(ListP1,X) ;
        X is 0
    ),
    (
        allValidMoves(Board, P2, ListP2) ->
        length(ListP2,Y) ;
        Y is 0
    ),
    Somme is X + Y,
    heuristic_actual_mobility_compute(X,Y,Somme,H).

heuristic_actual_mobility_compute(_,_,0,H):- H is 0.
heuristic_actual_mobility_compute(NbMoveP1,NbMoveP2,Somme,H):- H is 100 * (NbMoveP1-NbMoveP2) / Somme.
    