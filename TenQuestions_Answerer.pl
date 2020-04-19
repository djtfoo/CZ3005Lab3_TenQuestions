run() :-
    % assert that it is the user's first time
    assert(first_time()),
    % start the dialogue
    start().

start() :-
    % start a new game
    (   first_time() -> write('Hey! Would you like to play Ten Questions with me?');
        write('Would you like to play again?')
    ),
    write(' (y/n) : '),
    read(Option),
    (   Option==n ->
        (  first_time() ->
            write('Aww, okay, goodbye then.');
            write('Thanks for playing with me! Goodbye!')
         ),
        retractall(first_time())
        ;
        Option==y -> start_game()
    ).

start_game() :-
    % say a different message just for the first time
    (   first_time() ->
        write('Great! I\'m a big Pokemon fan. I\'ll think about a Pokemon, and you try to guess, alright?\n');
        write('')
    ),
    write('Let me know when you\'re ready.'),
    % prompt for user to be ready
    write(' (I\'m ready!) '),
    read(Option),
    retractall(first_time()),
    % initialize game - choose a Pokemon
    init_game(10),

    % print options for user
    write('\nAlright! Since there\'s so many Pokemon, I\'ll limit it to just a few. Here\'s a list of attributes among the possible Pokemon options.\n\n'),
    list_options(),
    write('\n\nYou can ask me anything from here! Remember, you have 10 questions!\n'),
    % start game loop
    game_loop(10).


% Game loop to ask for question and wait for answer
game_loop(C) :-
    % Check counter to see if 10 questions have been used up
    %qn_counter(C),  % global counter
    % if user has asked 10 questions already
    C == 0 ->
    (
        write('\nAlright, you\'ve used up all your questions! Try making a guess now! (Guess the Pokemon) '),
        read(Guess),
        check_guess(Guess),
        write('\n\n'),
        % restart game
        start()
    );
    (
        % show number of questions remaining
        write('Questions Left: '),
        write(C),
        % get option from user
        write('\nIs it ... : '),
        read(X),
        % first, check if user made a correct guess
        (
            selected(X) -> write('Correct! Great job!\n\n'), start();
            % get list of attributes of the selected Pokemon
            selected(Y), get_attributes(Y, L),
            % check if X is an attribute of the selected Pokemon
            (
               member(X, L) -> write('Yes, it is ');
               write('No, it\'s not ')
            ),
            write(X), write('.\n'),

            % decrement counter
            countdown(C, NewC),
            % go to next iteration
            game_loop(NewC)
        )
    ).

% User asks if X is true.
has(X) :-
    % Check counter to see if 10 questions have been used up
    qn_counter(C),
    % If user has asked 10 questions already
    C == 0 ->
    (   write('Hey, no more asking! Try making a guess now!')
    );
    (   % get list of attributes of the selected Pokemon
        selected(Y), get_attributes(Y, L),
        % check if X is an attribute of the selected Pokemon
        (member(X, L) -> write('Yes\n'); write('No\n')),
        % decrement counter
        counter_decr(NewC),
        write('Questions asked: '),
        write(NewC)
    ).

% Check the guess made by the user.
check_guess(X) :-
    (   selected(X) -> write('Correct! Great job!');
        write('Wrong! It was '), selected(Y), write(Y)
    ).

% Prints all attribute options from Pokemon options
list_options() :-
    %question_options(X), write(X).
    all_options(X), write(X).

% Randomly selects a Pokemon and starts a new round of Ten Questions.
init_game(NumQns) :-
    % remove existing Pokemon choice (if any)
    retractall(selected(_)),
    % randomly pick another Pokemon
    random_selection(X),
    % assert the picked Pokemon as the choice
    assert(selected(X)),
    % reset counter
    counter_init(NumQns).
    %Goal = selected(Y).

% get attributes of the selected Pokemon
get_attributes(X, L) :-
    X = pikachu -> pikachu(L);
    X = lapras -> lapras(L);
    X = mewtwo -> mewtwo(L);
    X = charizard -> charizard(L);
    X = haunter -> haunter(L);
    X = goldeen -> goldeen(L);
    X = kadabra -> kadabra(L);
    X = electrode -> electrode(L).

% Global Counter (not in use)
:- dynamic(qn_counter/1).  % allow counter to be set at runtime

counter_init(C) :-
    retractall(qn_counter(_)),  % remove current counter value (if any)
    assert(qn_counter(C)).  % set counter value = C

countdown(C0, C) :-
    C is C0 - 1.

counter_decr(C) :-
    qn_counter(C0),  % get current counter value
    retractall(qn_counter(_)),  % remove current counter value
    countdown(C0, C),  % get next counter value
    assert(qn_counter(C)).  % set next counter value

% Facts about the possible Pokemon
pikachu([electric, monotype, yellow, quadruped, stage_basic, evolve_by_stone, static]).
lapras([water, monotype, blue, fish, does_not_evolve, water_absorb]).
mewtwo([psychic, monotype, legendary, purple, upright, does_not_evolve, mega_variant]).
charizard([fire, flying, red, upright, stage_final, mega_variant, blaze]).
haunter([ghost, poison, purple, arms, stage_intermediate, evolve_by_trade, levitate]).
goldeen([water, monotype, fish, red, stage_basic, evolve_by_level, swift_swim]).
kadabra([psychic, monotype, upright, brown, stage_intermediate, evolve_by_trade, synchronize]).
electrode([electric, monotype, ball, red, stage_final, static]).

% List of possible Pokemon
selection_list([pikachu, lapras, mewtwo, charizard, haunter, goldeen, kadabra, electrode]).

question_options([monotype, type1, type2, legendary, colour, body_shape, stage, evolve_by, ability, variants]).

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

% fact: for program to know whether it's the first run.
first_time().
:- dynamic(first_time/0).
