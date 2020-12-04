:- writeln('IHM has loaded.').

:- use_module(library(pce)).

drawInitBoard :-
    widthBoard(WB),
    heightBoard(HB),
    widthWindow(WW),
    heightWindow(HW),
    send(@window, display, new(_, box(WB, HB)), point((WW/2) - (WB/2), (HW/2) - (HB/2))),
    drawCase(0),
    drawDisk(27, white),
    drawDisk(28, black),
    drawDisk(35, black),
    drawDisk(36, white).

drawBoard([],_).
drawBoard([H|T], N) :-
    (
        nonvar(H) ->
        (
            H == w ->
            drawDisk(N, white) ;
            drawDisk(N, black)
        ) ;
        true
    ),
    NewN is N+1,
    drawBoard(T,NewN).

drawCase(64).
drawCase(N) :-
    widthBoard(WB),
    heightBoard(HB),
    widthWindow(WW),
    heightWindow(HW),
    X is ((N mod 8) * WB/8) + (WW/2) - (WB/2),
    Y is (floor(N/8) * HB/8) + (HW/2) - (HB/2),
    send(@window, display, new(Case, box(WB/8, HB/8)), point(X, Y)),
    send(Case, fill_pattern, colour(dark_green)),
    send(Case, recogniser, click_gesture(left, '', single, message(@prolog, clickCase, N))),
    NewN is N+1,
    drawCase(NewN).

drawDisk(N, Color) :-
    widthBoard(WB),
    heightBoard(HB),
    widthWindow(WW),
    heightWindow(HW),
    X is (N mod 8) * WB/8 + (WW/2) - (WB/2),
    Y is floor(N/8) * HB/8 + (HW/2) - (HB/2),
    send(@window, display, new(D, circle(WB/8)), point(X, Y)),
    send(D, fill_pattern, colour(Color)).

configMenuBlack :-
    new(@menuHeuristicBlack, menu("Heuristic", marked)),
    send(@config, display, @menuHeuristicBlack, point(0, 100)),
    send(@menuHeuristicBlack, center_x, @config?center_x),
    send(@menuHeuristicBlack, append, random),
    send(@menuHeuristicBlack, append, disk_Difference),
    send(@menuHeuristicBlack, append, stability),
    send(@menuHeuristicBlack, append, actual_Mobility),
    send(@menuHeuristicBlack, append, coin_Parity),
    send(@menuHeuristicBlack, append, corners_Captured),
    send(@menuHeuristicBlack, append, potential_Mobility),
    send(@menuHeuristicBlack, layout, vertical),
    get(@menuAlgo, selection, A),
    (
        A == alpha_Beta ->
        (
            new(@depthBlack, text_item(depth)),
            send(@config, display, @depthBlack, point(0, 240)),
            send(@depthBlack, center_x, @config?center_x),
            send(@depthBlack, type, int)
        ) ;
        (
            new(@timeBlack, text_item(time)),
            send(@config, display, @timeBlack, point(0, 240)),
            send(@timeBlack, center_x, @config?center_x),
            send(@timeBlack, type, int)
        )
    ).

configMenuWhite :-
    new(@menuHeuristicWhite, menu("Heuristic", marked)),
    send(@config, display, @menuHeuristicWhite, point(0, 350)),
    send(@menuHeuristicWhite, center_x, @config?center_x),
    send(@menuHeuristicWhite, append, random),
    send(@menuHeuristicWhite, append, disk_Difference),
    send(@menuHeuristicWhite, append, stability),
    send(@menuHeuristicWhite, append, actual_Mobility),
    send(@menuHeuristicWhite, append, coin_Parity),
    send(@menuHeuristicWhite, append, corners_Captured),
    send(@menuHeuristicWhite, append, potential_Mobility),
    send(@menuHeuristicWhite, layout, vertical),
    get(@menuAlgo, selection, A),
    (
        A == alpha_Beta ->
        (
            new(@depthWhite, text_item(depth)),
            send(@config, display, @depthWhite, point(0, 490)),
            send(@depthWhite, center_x, @config?center_x),
            send(@depthWhite, type, int)
        ) ;
        (
            new(@timeWhite, text_item(time)),
            send(@config, display, @timeWhite, point(0, 490)),
            send(@timeWhite, center_x, @config?center_x),
            send(@timeWhite, type, int)
        )
    ).

configWindow :-
    free(@config),
    free(@menuHeuristicBlack),
    free(@menuPlayerBlack),
    free(@depthBlack),
    free(@menuHeuristicWhite),
    free(@menuPlayerWhite),
    free(@depthWhite),
    free(@buttonStart),
    free(@menuAlgo),
    free(@timeBlack),
    free(@timeWhite),
    new(@config, dialog("Configuration", size(400, 550))),
    send(@config, height, 550),
    send(@config, display, new(@menuAlgo, menu("Algorithm", marked)), point(0,10)),
    send(@menuAlgo, append, alpha_Beta),
    send(@menuAlgo, append, iDS),
    send(@menuAlgo, center_x, @config?center_x),
    send(@menuAlgo, recogniser, click_gesture(left, '', single, message(@prolog, clickMenuAlgo))),
    send(@config, display, new(TextBlack, text("Black Player", center, font(normal, normal, 16))), point(0, 40)),
    send(TextBlack, center_x, @config?center_x - 20),
    send(@config, display, new(@menuPlayerBlack, menu("Player Type", marked)), point(0, 70)),
    send(@menuPlayerBlack, center_x, @config?center_x - 80),
    send(@menuPlayerBlack, append, human),
    send(@menuPlayerBlack, append, iA),
    send(@menuPlayerBlack, recogniser, click_gesture(left, '', single, message(@prolog, clickMenuPlayer, @menuPlayerBlack))),
    send(@config, display, new(TextWhite, text("White Player", center, font(normal, normal, 16))), point(0, 290)),
    send(TextWhite, center_x, @config?center_x - 20),
    send(@config, display, new(@menuPlayerWhite, menu("Player Type", marked)), point(0, 320)),
    send(@menuPlayerWhite, center_x, @config?center_x - 80),
    send(@menuPlayerWhite, append, human),
    send(@menuPlayerWhite, append, iA),
    send(@menuPlayerWhite, recogniser, click_gesture(left, '', single, message(@prolog, clickMenuPlayer, @menuPlayerWhite))),
    new(@buttonStart, button(start, message(@prolog, startPlay))),
    send(@config, display, @buttonStart, point(0, 530)),
    send(@buttonStart, center_x, @config?center_x - 20),
    send(@config, open).

clickMenuPlayer(Menu) :-
    get(Menu, selection, OldSelect),
    (
        OldSelect == human ->
        NewSelect = iA,
        (
            Menu == @menuPlayerBlack ->
            configMenuBlack ;
            configMenuWhite
        ) ;
        NewSelect = human,
        (
            Menu == @menuPlayerBlack ->
            (
                free(@menuHeuristicBlack),
                free(@depthBlack),
                free(@timeBlack)
            ) ;
            (
                free(@menuHeuristicWhite),
                free(@depthWhite),
                free(@timeWhite)
            )
        )
    ),
    get(Menu?members, find, @arg1?value == NewSelect, Item),
    send(Menu, selection, Item).

clickMenuAlgo :-
    get(@menuAlgo, selection, OldSelect),
    (
        OldSelect == alpha_Beta ->
        NewSelect = iDS ;
        NewSelect = alpha_Beta
    ),
    get(@menuAlgo?members, find, @arg1?value == NewSelect, Item),
    send(@menuAlgo, selection, Item),
    get(@menuPlayerBlack, selection, SelectBlack),
    (
        SelectBlack == iA ->
        (
            free(@depthBlack),
            free(@timeBlack),
            (
                NewSelect == iDS ->
                (
                    new(@timeBlack, text_item(time)),
                    send(@config, display, @timeBlack, point(0, 240)),
                    send(@timeBlack, center_x, @config?center_x),
                    send(@timeBlack, type, int)
                ) ;
                (
                    new(@depthBlack, text_item(depth)),
                    send(@config, display, @depthBlack, point(0, 240)),
                    send(@depthBlack, center_x, @config?center_x),
                    send(@depthBlack, type, int)
                )
            )
        ) ;
        true
    ),
    get(@menuPlayerWhite, selection, SelectWhite),
    (
        SelectWhite == iA ->
        (
            free(@depthWhite),
            free(@timeWhite),
            (
                NewSelect == iDS ->
                (
                    new(@timeWhite, text_item(time)),
                    send(@config, display, @timeWhite, point(0, 490)),
                    send(@timeWhite, center_x, @config?center_x),
                    send(@timeWhite, type, int)
                ) ;
                (
                    new(@depthWhite, text_item(depth)),
                    send(@config, display, @depthWhite, point(0, 490)),
                    send(@depthWhite, center_x, @config?center_x),
                    send(@depthWhite, type, int)
                )
            )
        ) ;
        true
    ).

heuristicNumber(random, 1).
heuristicNumber(disk_Difference, 2).
heuristicNumber(stability, 3).
heuristicNumber(actual_Mobility, 4).
heuristicNumber(coin_Parity, 5).
heuristicNumber(corners_Captured, 6).
heuristicNumber(potential_Mobility, 7).

startPlay :-
    get(@menuAlgo, selection, A),
    (
        A == alpha_Beta ->
        assertz(choiceAlgorithm(alpha_beta)) ;
        assertz(choiceAlgorithm(ids))
    ),
    get(@menuPlayerBlack, selection, PB),
    (
        PB == human ->
        assertz(playerType(b, 1)) ;
        (
            A == alpha_Beta ->
            (
                get(@depthBlack, selection, DB),
                DB > 0,
                assertz(depthPlayer(b, DB))
            ) ;
            (
                get(@timeBlack, selection, TB),
                TB > 0,
                assertz(timePlayer(b, TB))
            )
        ),
        assertz(playerType(b, 2)),
        get(@menuHeuristicBlack, selection, HB),
        heuristicNumber(HB, HBN),
        assertz(heuristicPlayer(b, HBN))
    ),
    get(@menuPlayerWhite, selection, PW),
    (
        PW == human ->
        assertz(playerType(w, 1)) ;
        (
            A == alpha_Beta ->
            (
                get(@depthWhite, selection, DW),
                DW > 0,
                assertz(depthPlayer(w, DW))
            ) ;
            (
                get(@timeWhite, selection, TW),
                TW > 0,
                assertz(timePlayer(w, TW))
            )
        ),
        assertz(playerType(w, 2)),
        get(@menuHeuristicWhite, selection, HW),
        heuristicNumber(HW, HWN),
        assertz(heuristicPlayer(w, HWN))
    ),
    free(@config),
    initIHM,
    displayBoard,
    thread_create(play('b'), _). % create thread to play and display at the same time

initIHM :-
    free(@window),
    retractall(widthWindow(_)),
    retractall(heightWindow(_)),
    retractall(widthBoard(_)),
    retractall(heightBoard(_)),
    WW is 800,
    HW is 800,
    WB is 704,
    HB is 704,
    assertz(widthWindow(WW)),
    assertz(heightWindow(HW)),
    assertz(widthBoard(WB)),
    assertz(heightBoard(HB)),
    new(@window, picture("Othello Prolog", size(WW, HW))),
    send(@window, open),
    drawInitBoard.

clickCase(N) :-
    assertz(playerMoveGUI(N)).

displayWinner(Winner) :-
    widthWindow(WW),
    heightWindow(HW),
    send(@window, display, new(B, box(400, 400)), point(WW/2 - 400/2, HW/2 - 400/2)),
    send(B, fill_pattern, colour(white)),
    atom_concat("Game Over !\nThe winner is : ", Winner, Text),
    send(@window, display, new(T, text(Text, center, font(screen, roman, 25)))),
    send(T, center, B?center).

colorValidMoves([]).
colorValidMoves([H|T]) :-
    widthBoard(WB),
    heightBoard(HB),
    widthWindow(WW),
    heightWindow(HW),
    X is ((H mod 8) * WB/8) + (WW/2) - (WB/2),
    Y is (floor(H/8) * HB/8) + (HW/2) - (HB/2),
    send(@window, display, new(ValidMoveBox, box(WB/8, HB/8)), point(X, Y)),
    send(ValidMoveBox, fill_pattern, colour(yellow)),
    colorValidMoves(T).

clearValidMoves([]).
clearValidMoves([H|T]) :-
    widthBoard(WB),
    heightBoard(HB),
    widthWindow(WW),
    heightWindow(HW),
    X is ((H mod 8) * WB/8) + (WW/2) - (WB/2),
    Y is (floor(H/8) * HB/8) + (HW/2) - (HB/2),
    send(@window, display, new(ValidMoveBox, box(WB/8, HB/8)), point(X, Y)),
    send(ValidMoveBox, fill_pattern, colour(dark_green)),
    clearValidMoves(T).

humanPlayIhm(ListMoves, Move) :-
    colorValidMoves(ListMoves),
    retractall(playerMoveGUI(_)),
    %wait for user input with repeat (bad)
    repeat,
    playerMoveGUI(Choice),
    nonvar(Choice),
    member(Choice, ListMoves),
    clearValidMoves(ListMoves),
    Move is Choice.