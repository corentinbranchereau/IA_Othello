% STABILITY HEURISTIC

:- writeln('Stability heuristic has loaded.').
% Resource : https://courses.cs.washington.edu/courses/cse573/04au/Project/mini1/RUSSIA/Final_Paper.pdf

% Daprès la simplification proposée dans larticle de la source
stability_weights([4,  -3,  2,  2,  2,  2, -3,  4,
                   -3, -4, -1, -1, -1, -1, -4, -3,
                   2,  -1,  1,  0,  0,  1, -1,  2,
                   2,  -1,  0,  1,  1,  0, -1,  2,
                   2,  -1,  0,  1,  1,  0, -1,  2,
                   2,  -1,  1,  0,  0,  1, -1,  2,
                   -3, -4, -1, -1, -1, -1, -4, -3,
                   4,  -3,  2,  2,  2,  2, -3,  4]).

% P1 is the current player while P2 is the ennemy
heuristic_stability(Board, P1, P2, H) :-
    %Somme des poids correspondant aux disques posés de P1
    countUtility(Board, P1, UtilityP1),
    %Somme des poids correspondant aux disques posés de P1
    countUtility(Board, P2, UtilityP2),
    %Calculer lheuristique
    H is UtilityP1 - UtilityP2.

countUtility(B, P, Utility) :- stability_weights(W), countUtility(B, W, P, Utility).

countUtility([], [], _, 0).
countUtility([P|B], [Z|W], P, Utility) :- countUtility(B, W, P, NewUtility), Utility is NewUtility + Z.
countUtility([_|B], [_|W], P, Utility) :- countUtility(B, W, P, Utility).