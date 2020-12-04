% POTENTIAL MOBILITY HEURISTIC
:-writeln('potential mobility heuristic has loaded').

%Board le plateau actuel
%P1 est le joueur 1, pour lequel on calcule l'heuristique: ie joueur MAX
%P2 est son adversaire, ie joueur MIN
%H la valeur de l'heuristique (à passer comme variable)


heuristic_potential_mobility(Board, P1, P2, H) :- 
    %compter le nombre de cases vides près des pions de P2 puis
    %compter le nombre de cases vides près des pions de P1
    count_empty_near_player(Board, P2, 0, 0, NbEmptyP2), %mobilité potentielle de P1
    count_empty_near_player(Board, P1, 0, 0, NbEmptyP1), %mobilité potentielle de P2
    Somme is NbEmptyP1 + NbEmptyP2,
    heuristic_potential_mobility_compute(NbEmptyP1,NbEmptyP2,Somme,H).


count_empty_near_player(_, _, NbEmpty, 64, FinalNbEmpty):- FinalNbEmpty is NbEmpty, !.
count_empty_near_player(Board, Player, NbEmpty, Index, FinalNbEmpty):-
    %(if -> then ; else ) 
    whatColorIsThisIndex(Board, Index, Color),
    (%if
     (
        Color == 'b';
        Color == 'w'
     )
     %then
        ->  NextIndex is Index +1, count_empty_near_player(Board, Player, NbEmpty, NextIndex, FinalNbEmpty)
     %else
        ;
        (%if
          ( 
            ( (nextCell(Index,top,IndexTop), whatColorIsThisIndex(Board,IndexTop,ColorIndexTop)), ColorIndexTop == Player );                                    
            ( (nextCell(Index,down,IndexBottom), whatColorIsThisIndex(Board,IndexBottom,ColorIndexBottom)), ColorIndexBottom == Player );
            ( (nextCell(Index,left,IndexLeft), whatColorIsThisIndex(Board,IndexLeft,ColorIndexLeft)), ColorIndexLeft == Player );
            ( (nextCell(Index,right,IndexRight), whatColorIsThisIndex(Board,IndexRight,ColorIndexRight)), ColorIndexRight == Player );
            ( (nextCell(Index,diagNE,IndexNE), whatColorIsThisIndex(Board,IndexNE,ColorIndexNE)), ColorIndexNE == Player );
            ( (nextCell(Index,diagNW,IndexNW), whatColorIsThisIndex(Board,IndexNW,ColorIndexNW)), ColorIndexNW == Player );
            ( (nextCell(Index,diagSE,IndexSE), whatColorIsThisIndex(Board,IndexSE,ColorIndexSE)), ColorIndexSE == Player );
            ( (nextCell(Index,diagSW,IndexSW), whatColorIsThisIndex(Board,IndexSW,ColorIndexSW)), ColorIndexSW == Player )
          )
          %then             
                        -> NewNbEmpty is NbEmpty + 1, NextIndex is Index +1, count_empty_near_player(Board, Player, NewNbEmpty, NextIndex, FinalNbEmpty)
          %else
                        ;  NextIndex is Index+1, count_empty_near_player(Board, Player, NbEmpty, NextIndex, FinalNbEmpty)
        )
    ).



whatColorIsThisIndex(Board, Index, Color):- nth0(Index, Board, Color).


heuristic_potential_mobility_compute(_,_,0,H):- H is 0.                         %mobilitéP1 - %mobilitéP2
heuristic_potential_mobility_compute(NbEmptyP1,NbEmptyP2,Somme,H):- H is 100 * (NbEmptyP2-NbEmptyP1) / Somme.
    