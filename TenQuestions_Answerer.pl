% User asks if X is true.
has(X) :-
    % check counter to see if 10 questions have been used up
    qn_counter(C),
    % if user has asked 10 questions already (>= for safety)
    C >= 10 ->
    (   write('Stop asking; make a guess now!')
    );
    (   % get list of attributes of the selected Pokemon
        selected(Y), get_attributes(Y, L),
        % check if X is an attribute of the selected Pokemon
        (member(X, L) -> write('Yes\n'); write('No\n')),
        % increment counter
        counter_incr(NewC),
        write('Questions asked: '),
        write(NewC)
    ).

% User makes a guess.
make_guess(X) :-
    selected(X) -> write('Correct! Great job!'); write('Wrong! Try again!').

% TBC
view_options() :-
    all_options(X), write(X).

% Randomly selects a Pokemon and starts a new round of Ten Questions.
start_new_game(0) :-
    % remove existing Pokemon choice (if any)
    retractall(selected(_)),
    % randomly pick another Pokemon
    random_selection(X),
    % assert the picked Pokemon as the choice
    assert(selected(X)),
    % reset counter
    counter_init(0).
    %Goal = selected(Y).

% get attributes of the selected Pokemon
get_attributes(X, L) :-
    X = pikachu -> pikachu(L);
    X = lapras -> lapras(L);
    X = mewtwo -> mewtwo(L);
    X = charizard -> charizard(L);
    X = haunter -> haunter(L);
    X = goldeen -> goldeen(L).

% Counter
:- dynamic(qn_counter/1).  % allow counter to be set at runtime

counter_init(C) :-
    retractall(qn_counter(_)),  % remove current counter value (if any)
    assert(qn_counter(C)).  % set counter value = C

counter_next(C0, C) :-
    C is C0 + 1.

counter_incr(C) :-
    qn_counter(C0),  % get current counter value
    retractall(qn_counter(_)),  % remove current counter value
    counter_next(C0, C),  % get next counter value
    assert(qn_counter(C)).  % set next counter value

% Facts about the possible Pokemon
pikachu([electric, monotype, yellow, quadruped, stage_basic, evolve_by_stone, ability_static]).
lapras([water, monotype, blue, fish, does_not_evolve, ability_waterabsorb]).
mewtwo([psychic, monotype, legendary, purple, upright, does_not_evolve, mega_variant, ability_pressure]).
charizard([fire, flying, red, upright, stage_final, mega_variant, ability_blaze]).
haunter([ghost, poison, purple, arms, stage_intermediate, evolve_by_trade, ability_levitate]).
goldeen([water, monotype, fish, red, stage_basic, evolve_by_level, ability_swiftswim]).

% List of possible Pokemon
selection_list([pikachu, lapras, mewtwo, charizard, haunter, goldeen]).

% Possible guesses
random_selection(X) :-
    selection_list(L), random_member(X, L).

% TO-DO: Remove duplicates in list
all_options(X) :-  %X = the list of ALL options
    pikachu(A), lapras(B), append(A, B, TempList),
    mewtwo(C), append(TempList, C, TempList2),
    charizard(D), append(TempList2, D, TempList3),
    haunter(E), append(TempList3, E, TempList4),
    goldeen(F), append(TempList4, F, X).

% allow selected Pokemon to be set at runtime
:- dynamic(selected/1).
