% CORNERS CAPTURED HEURISTICS

:- writeln('Corners Captured heuristic has loaded.').

% P1 is the current player while P2 is the ennemy
% Corners Captured
%P1 is the current player
heuristic_cornersCaptured(Board, P1, P2, H) :-
    %Récupérer tous les disques
    getCorners(Board, Corners),
    %Compter le nombre de disques occupés par joueur
    countByPlayer(Corners, P1, NbDiskP1),
    countByPlayer(Corners, P2, NbDiskP2),
    %Somme des disques sur les coins
    Somme is NbDiskP1 + NbDiskP2,
    %Calculer l heuristique
    heuristic_compute(NbDiskP1, NbDiskP2, Somme, H).

getCorners(Board, Corners) :- getCorners(Board, Corners, 0).
getCorners([],[],64).
getCorners([D|B], [D|C], I) :- (I==0 ; I==7 ; I==56; I==63) , J is I+1, getCorners(B, C, J).
getCorners([_|B], C, I) :-  J is I+1, getCorners(B, C, J).

countByPlayer([], _, 0).
countByPlayer([D|C], P, NbDiskP) :- var(D), countByPlayer(C, P, NbDiskP).
countByPlayer([P|C], P, NbDiskP) :- countByPlayer(C, P, NewNbDiskP), NbDiskP is NewNbDiskP + 1.
countByPlayer([_|C], P, NbDiskP) :- countByPlayer(C, P, NbDiskP).

heuristic_compute(_,_,0,0).
heuristic_compute(NbDiskP1, NbDiskP2, Somme, H) :- H is 100 * (NbDiskP1-NbDiskP2) / Somme.