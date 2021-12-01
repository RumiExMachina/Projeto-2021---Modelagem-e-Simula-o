command_handler_game:
    debug: true
    type: command
    name: cmd-jogo
    description: Comando de informação sobre um jogo.
    usage: /cmd-jogo
    permissions: gear-bot.bot.admin
    tab completions:
        1: ativar|desativar|deletar
    script:
    - define discord_group "Faculdade - Projeto Sossuer"
    - definemap options:
        1:
            type: string
            name: jogo
            description: Informações sobre o jogo.
            required: true
    - choose <context.args.get[1]>:
        - case ativar:
            - ~discordcommand id:gear_bot create group:<discord[gear_bot].group[<[discord_group]>]> name:jogo "description:Exibe informações sobre o jogo selecionado." options:<[options]> enabled:true
        - case desativar:
            - ~discordcommand id:gear_bot create group:<discord[gear_bot].group[<[discord_group]>]> name:jogo "description:Exibe informações sobre o jogo selecionado." options:<[options]> enabled:false
        - case deletar:
            - ~discordcommand id:gear_bot delete group:<discord[gear_bot].group[<[discord_group]>]> name:jogo
        - default:
            - debug log "Entrada inválida, por favor verifique as informações."

command_events_game:
    type: world
    events:
        on discord slash command name:jogo:
        - define author "Gearpunk | Jogos e Dados"
        - define game <context.options.get[jogo].if_null[Invalido]>
        - define discord_group "Faculdade - Projeto Sossuer"
        - define images https://cdn.discordapp.com/attachments/900882922435915776/900882986336149534/disc-size.png
        - define list <list>
        - define list_tags <list>
        - define price_null ???

        - if <server.has_file[../GearpunkBot/Jogos/<[game]>.yml]>:

            # PREÇOS DOS JOGOS NO MERCADO SEM ALTERAÇÃO DE PROMOÇÕES.
            - define price_steam <yaml[gear_yaml_game_<[game]>].read[<[game]>.Store.Steam.Price].if_null[<[price_null]>]>
            - define price_epic <yaml[gear_yaml_game_<[game]>].read[<[game]>.Store.Epic.Price].if_null[<[price_null]>]>
            - define price_playstation <yaml[gear_yaml_game_<[game]>].read[<[game]>.Store.Playstation.Price].if_null[<[price_null]>]>
            - define price_xbox <yaml[gear_yaml_game_<[game]>].read[<[game]>.Store.XBOX.Price].if_null[<[price_null]>]>
            - define price_nintendo <yaml[gear_yaml_game_<[game]>].read[<[game]>.Store.Nintendo.Price].if_null[<[price_null]>]>

            - define list_average <list>
            - define list_average <[list].include[<[price_steam]>|<[price_epic]>|<[price_playstation]>|<[price_xbox]>|<[price_nintendo]>]>

            - define link_steam <yaml[gear_yaml_game_<[game]>].read[<[game]>.Store.Steam.Link].if_null[<[price_null]>]>
            - define link_epic <yaml[gear_yaml_game_<[game]>].read[<[game]>.Store.Epic.Link].if_null[<[price_null]>]>
            - define link_playstation <yaml[gear_yaml_game_<[game]>].read[<[game]>.Store.Playstation.Link].if_null[<[price_null]>]>
            - define link_xbox <yaml[gear_yaml_game_<[game]>].read[<[game]>.Store.XBOX.Link].if_null[<[price_null]>]>
            - define link_nintendo <yaml[gear_yaml_game_<[game]>].read[<[game]>.Store.Nintendo.Link].if_null[<[price_null]>]>
            # TAGS DOS JOGOS, SERVEM PARA A ENGINE DE PESQUISA.
            - define tags <yaml[gear_yaml_game_<[game]>].parsed_key[<[game]>.Tags].if_null[Desconhecido]>
            - define list_tags <[list_tags].include[<[tags]>]>
            - define game_title <yaml[gear_yaml_game_<[game]>].read[<[game]>.Display].if_null[Desconhecido]>
            - define list <[list].include[<yaml[gear_yaml_game_<[game]>].parsed_key[<[game]>.Description].if_null[Nenhuma]>]>
            - define game_embed <discord_embed[thumbnail=<[images]>;footer=<[author]>;color=#86cbfc;title=<[game_title]>]>
            - define game_embed <[game_embed].add_field[Descrição:].value[<[list].comma_separated>]>
            - define game_embed <[game_embed].add_field[Steam:].value[Preço:<&sp>R$<[price_steam]><&nl>Loja:<&sp><[link_steam]>]>
            - define game_embed <[game_embed].add_field[Epic:].value[Preço:<&sp>R$<[price_epic]><&nl>Loja:<&sp><[link_epic]>]>
            - define game_embed <[game_embed].add_field[Playstation:].value[Preço:<&sp>R$<[price_playstation]><&nl>Loja:<&sp><[link_playstation]>]>
            - define game_embed <[game_embed].add_field[XBOX:].value[Preço:<&sp>R$<[price_xbox]><&nl>Loja:<&sp><[link_xbox]>]>
            - define game_embed <[game_embed].add_field[Nintendo:].value[Preço:<&sp>R$<[price_nintendo]><&nl>Loja:<&sp><[link_nintendo]>]>
            - define game_embed <[game_embed].add_field[Média<&sp>de<&sp>Preço:].value[Valor:<&sp>R$<[list_average].average>]>
            - define game_embed <[game_embed].add_field[Tags:].value[<[list_tags].comma_separated>]>
            - ~discordinteraction reply interaction:<context.interaction> <[game_embed]>

        - else:
            - define error_field "Erro! Verifique os valores."
            - define error_value "Os valores inseridos não foram encontrados em nosso bando de dados."
            - define game_invalid <discord_embed[thumbnail=<[images]>;footer=<[author]>;color=#992817;title=<[game]>]>
            - define game_invalid <[game_invalid].add_field[<[error_field]>].value[<[error_value]>]>
            - ~discordinteraction reply interaction:<context.interaction> ephemeral:true <[game_invalid]>