% COIN PARITY HEURISTICS

:- writeln('Coin Parity Heuristic has loaded.').

%Board est le plateau actuel
% P1 is the current player while P2 is the ennemy
% Coin Parity
%P1 is the current player

heuristic_coin_parity(Board, P1, P2, H) :-
	%compter le nombre de jetons pour P1 puis
    %compter le nombre de jetons pour P2
    countDiskPerPlayer(Board,P1,0,NbDiskP1),
    countDiskPerPlayer(Board,P2,0,NbDiskP2),
    Somme is NbDiskP1 + NbDiskP2,
    %Calculer l heuristique
    heuristic_coin_parity_compute(NbDiskP1, NbDiskP2, Somme, H).

heuristic_coin_parity_compute(_,_,0,H):- H is 0.
heuristic_coin_parity_compute(NbDiskP1,NbDiskP2,Somme,H):- H is 100 * (NbDiskP1-NbDiskP2) / Somme.
