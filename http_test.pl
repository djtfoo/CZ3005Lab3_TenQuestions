:-
    use_module(library(http/http_open)),
    use_module(library(http/json)),
    dynamic(species_data/1),  % from /pokemon-species endpoint
    dynamic(pokemon_data/1).  % from /pokemon endpoint

get_pokemon_data(Id) :-
    retractall(species_data(_)),
    retractall(pokemon_data(_)),

    number_string(Id, IdStr),

    % get species data
    species_url(UrlS),
    string_concat(UrlS, IdStr, UrlSpecies),
    get_req(UrlSpecies, SpeciesData),
    assert(species_data(SpeciesData)),

    % get Pokemon data
    pokemon_url(UrlP),
    string_concat(UrlP, IdStr, UrlPokemon),
    get_req(UrlPokemon, PokemonData),
    assert(pokemon_data(PokemonData)),

    write('Done fetching').

get_req(URL, Data) :-
    setup_call_cleanup(
        http_open(URL, In, [request_header('Accept'='application/json')]),
        json_read_dict(In, Data),
        close(In)
    ).

get_pokemon_data() :-
    pokemon_data(Data),

    % get is monotype
    Types = Data.get(types),
    length(Types, NumTypes),
    (   NumTypes = 1 ->
        write('Is monotype')
    ;
        write('Is dual-typed')
    ),
    write('\n'),

    % get first Type
    nth0(0, Types, T),
    Type1 = T.get(type).get(name),
    write('Type 1: '), write(Type1),
    write('\n'),

    % get Ability
     Abilities = Data.get(abilities),
     nth0(0, Abilities, A),
     Ability = A.get(ability).get(name),
     write('Ability: '), write(Ability).

get_species_data() :-
    species_data(Data),
    % get Color
    Color = Data.get(color).get(name),
    write('Color: '), write(Color),
    write('\n'),
    % get Base Happiness
    Happiness = Data.get(base_happiness),
    write('Base Happiness: '), write(Happiness),
    write('\n'),
    % get Name
    Name = Data.get(name),
    write('Name: '), write(Name),
    write('\n'),
    % get Shape
    Shape = Data.get(shape).get(name),
    write('Shape: '), write(Shape),
    write('\n'),
    % get Habitat
    Habitat = Data.get(habitat).get(name),
    write('Habitat: '), write(Habitat),
    write('\n'),
    % get first Egg Group
    EggGroups = Data.get(egg_groups),
    nth0(0, EggGroups, EG),
    EggGroup = EG.get(name),
    write('Egg Group: '), write(EggGroup).

species_url("https://pokeapi.co/api/v2/pokemon-species/").
pokemon_url("https://pokeapi.co/api/v2/pokemon/").
