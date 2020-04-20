% To be called to start the program
run() :-
    % assert that it is the user's first time
    assert(first_time()),
    % start the dialogue
    start().

% Start the conversation for a game round
start() :-
    % start a new game
    (   first_time() -> write('Hey! Would you like to play Ten Questions with me?');
        write('Would you like to play again?')
    ),
    write(' (y/n) : '),
    % get user's response
    read(Option),
    (   Option==n ->  % user does not wish to play
        (  first_time() ->
            write('Aww, okay, goodbye then.');
            write('Thanks for playing with me! Goodbye!')
         ),
        retractall(first_time())
        ;  % user wishes to play
        Option==y -> start_game()
    ).

% Start a game round
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
    % no longer the player's first_time
    retractall(first_time()),
    % initialize game - choose a Pokemon
    init_game(),

    % print options for user
    write('\nAlright! Since there\'s so many Pokemon, I\'ll limit it to just a few. Here\'s a list of attributes among the possible Pokemon options.\n\n'),
    list_options(),
    write('\n\nYou can ask me anything from here! Remember, you have 10 questions!\n'),
    % start game loop
    game_loop(10).


% Game loop to ask for question and wait for answer
game_loop(C) :-
    % check if user has asked 10 questions already
    C == 0 ->  % user has ran out of questions
    (
        % prompt user to guess
        write('\nAlright, you\'ve used up all your questions! Try making a guess now!\n(Guess the Pokemon) '),
        read(Guess),  % read user's guess
        check_guess(Guess),  % check user's guess and print response
        write('\n\n'),
        % restart game
        start()
    );
    (
        % show number of questions remaining
        write('Questions Left: '),
        write(C),
        % get option from user
        write('\nIs it ... '),
        read(X),
        (
            % first, check if user made a correct guess
            selected(X) ->   % user is correct
            write('Correct! Great job!\n\n'),  % user's response
            % start a new round
            start()
         ;
            % else, get list of attributes of the selected Pokemon
            selected(Y), get_attributes(Y, L),
            % check if X is an attribute of the selected Pokemon
            (
               member(X, L) -> Truth = true; Truth = false
            ),
            % print response to user's question
            print_response(X, Truth),
            write('\n'),

            % decrement counter
            countdown(C, NewC),
            % go to next iteration
            game_loop(NewC)
        )
    ).

% Check the guess made by the user.
check_guess(X) :-
    (   selected(X) -> write('Correct! Great job!');
        write('Wrong! It was '), selected(Y), write(Y)
    ).

% Prints all possible options user can ask
list_options() :-
    all_options(X), write(X).

% Randomly selects a Pokemon and starts a new round of Ten Questions.
init_game() :-
    % remove existing Pokemon choice (if any)
    retractall(selected(_)),
    % randomly pick another Pokemon
    random_selection(X),
    % assert the picked Pokemon as the choice
    assert(selected(X)).

% get attributes of the selected Pokemon
get_attributes(X, L) :-
    % if X = <pokemon name>, return that Pokemon's attributes
    X = pikachu -> pikachu(L);
    X = lapras -> lapras(L);
    X = mewtwo -> mewtwo(L);
    X = charizard -> charizard(L);
    X = haunter -> haunter(L);
    X = goldeen -> goldeen(L);
    X = kadabra -> kadabra(L);
    X = electrode -> electrode(L);
    X = zubat -> zubat(L).

% Counts down a value C0 and returns C
countdown(C0, C) :-
    C is C0 - 1.

% Possible Pokemon attributes
colour([red, yellow, blue, green, brown, purple]).
is([monotype, legendary]).
has([mega-variant]).
type([electric, water, psychic, fire, grass, flying, ghost, poison, rock, ground]).
shape([quadruped, fish, upright, arms, ball, wings]).
stage([basic, intermediate, final]).
evolveby([does-not-evolve, evolves-by-stone, evolves-by-level, evolves-by-trade]).
ability([static, water-absorb, pressure, blaze, levitate, swift-swim, synchronize, inner-focus]).

% List of attributes available for guessing
all_options(X) :-  % X = a list containing ALL attributes
    colour(A), is(B), append(A, B, Temp),
    has(C), append(Temp, C, Temp2),
    type(D), append(Temp2, D, Temp3),
    shape(E), append(Temp3, E, Temp4),
    stage(F), append(Temp4, F, Temp5),
    evolveby(G), append(Temp5, G, Temp6),
    ability(H), append(Temp6, H, X).

% Print result of question asked by user
print_response(X, IsCorrect) :-
    % if user asked about a colour, print this response
    colour(L1), member(X, L1), (IsCorrect=true -> write('Yes, its colour is '); write('No, its colour is not ')),write(X), write('.');
    % if user asked about a boolean, print this response
    is(L2), member(X, L2), (IsCorrect=true -> write('Yes, it is '); write('No, it is not ')), write(X), write('.');
    % if user asked about some trait the Pokemon has, print this response
    has(L3), member(X, L3), (IsCorrect=true -> write('Yes, it has '); write('No, it does not have ')), write(X), write('.');
    % if user asked about the Pokemon type, print this response
    type(L4), member(X, L4), (IsCorrect=true -> write('Yes, it is a '); write('No, it is not a ')), write(X), write('-type.');
    % if user asked about the body shape, print this response
    shape(L5), member(X, L5), (IsCorrect=true -> write('Yes, its body shape is '); write('No, its body shape is not ')), write(X), write('.');
    % if user asked about the evolutionary stage, print this response
   stage(L6), member(X, L6), (IsCorrect=true -> write('Yes, it is in the '); write('No, it is not in the ')), write(X), write(' stage.');
    % if user asked about the evolution methods, print this response
    evolveby(L7), member(X, L7), (IsCorrect=true -> write('Yes, it '); write('No, it does not ')), write(X), write('.');
    % if user asked about the Pokemon's ability, print this response
    ability(L8), member(X, L8), (IsCorrect=true -> write('Yes, its ability is '); write('No, its ability is not ')), write(X), write('.');
    write('Hey, ask me something only from the list!').

% Facts about the possible Pokemon
pikachu([electric, monotype, yellow, quadruped, basic, evolves-by-stone, static]).
lapras([water, monotype, blue, fish, final, does-not-evolve, water-absorb]).
mewtwo([psychic, monotype, legendary, purple, upright, final, does-not-evolve, mega-variant, pressure]).
charizard([fire, flying, red, upright, final, does-not-evolve, mega-variant, blaze]).
haunter([ghost, poison, purple, arms, intermediate, evolves-by-trade, levitate]).
goldeen([water, monotype, fish, red, basic, evolves-by-level, swift-swim]).
kadabra([psychic, monotype, upright, brown, intermediate, evolves-by-trade, synchronize]).
electrode([electric, monotype, ball, red, final, does-not-evolve, static]).
zubat([poison, flying, wings, purple, basic, evolves-by-level, inner-focus]).

% List of possible Pokemon
selection_list([pikachu, lapras, mewtwo, charizard, haunter, goldeen, kadabra, electrode, zubat]).

% Generate a possible Pokemon selection
random_selection(X) :-
    selection_list(L), random_member(X, L).

% allow selected Pokemon to be set at runtime
:- dynamic(selected/1).

% fact: for program to know whether it's the first run.
first_time().
% allow program to assert/retract first_time
:- dynamic(first_time/0).

