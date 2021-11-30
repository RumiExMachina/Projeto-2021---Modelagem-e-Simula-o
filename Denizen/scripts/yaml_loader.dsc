yaml_game_loader:
    debug: false
    type: world
    events:
        on server start:
        - run yaml_game_loader_handler

yaml_game_loader_cmd:
    debug: false
    type: command
    name: game-loader
    description: Carrega os arquivos de jogo.
    usage: /game-loader
    permissions: gear-bot.bot.admin
    tab completions:
        1: ajuda|carregar
    script:
    - if <context.args.size> = 0:
        - debug log "Use /game-loader ajuda"
    - if <context.args.size> > 0:
        - choose <context.args.get[1]>:
            - case ajuda:
                - debug log "/game-loader ajuda"
                - debug log "/game-loader carregar"
            - case carregar:
                - debug log "Database de jogos foi carregada com sucesso!"
                - run yaml_game_loader_handler
            - default:
                - debug log "Use /game-loader ajuda"

yaml_game_loader_handler:
    debug: false
    type: task
    debug: true
    script:
    - if <server.has_file[../GearpunkBot/Config/game-list.yml]>:
        - ~yaml load:../GearpunkBot/Config/game-list.yml id:gear_game_list

        - run yaml_game_loader_manager
    - else:
        - yaml create id:gear_game_list

        - yaml id:gear_game_list set Games.Skyrim.Enabled:true
        - yaml id:gear_game_list set Games.Frostpunk.Enabled:true
        - ~yaml savefile:../GearpunkBot/Config/game-list.yml id:gear_game_list

        - run yaml_game_loader_manager

yaml_game_loader_manager:
    debug: false
    type: task
    script:
    - foreach <yaml[gear_game_list].list_keys[Games]> as:gear_games:
        - define gear_games_load gear_yaml_game_<[gear_games]>
        - if <yaml.list.contains[<[gear_games_load]>]>:
            - ~yaml unload id:gear_yaml_game_<[gear_games]>
        - if <yaml[gear_game_list].read[Games.<[gear_games]>.Enabled].if_null[false]> = true:
            - if <server.has_file[../GearpunkBot/Jogos/<[gear_games]>.yml]>:
                - ~yaml load:../GearpunkBot/Jogos/<[gear_games]>.yml id:gear_yaml_game_<[gear_games]>
            - else:
                - yaml create id:gear_yaml_game_<[gear_games]>

                - yaml id:gear_yaml_game_<[gear_games]> set <[gear_games]>.Display:<[gear_games]>
                - yaml id:gear_yaml_game_<[gear_games]> set <[gear_games]>.Internal_ID:<[gear_games]>

                - ~yaml savefile:../GearpunkBot/Jogos/<[gear_games]>.yml id:gear_yaml_game_<[gear_games]>