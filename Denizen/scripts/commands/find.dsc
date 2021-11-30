command_handler_find:
    debug: true
    type: command
    name: cmd-pesquisar
    description: Comando de pesquisa de jogos.
    usage: /cmd-pesquisar
    permissions: gear-bot.bot.admin
    tab completions:
        1: ativar|desativar|deletar
    script:
    - define discord_group "Faculdade - Projeto Sossuer"
    - definemap options:
        1:
            type: string
            name: tag
            description: Tag do jogo a se pesquisar.
            required: true
        2:
            type: string
            name: plataforma
            description: Plataforma desejada.
            required: true
        3:
            type: integer
            name: preço
            description: Preço máximo do jogo.
            required: true
    - choose <context.args.get[1]>:
        - case ativar:
            - ~discordcommand id:gear_bot create group:<discord[gear_bot].group[<[discord_group]>]> name:pesquisar "description:Pesquisa jogos com base na informação dada." options:<[options]> enabled:true
        - case desativar:
            - ~discordcommand id:gear_bot create group:<discord[gear_bot].group[<[discord_group]>]> name:pesquisar "description:Pesquisa jogos com base na informação dada." options:<[options]> enabled:false
        - case deletar:
            - ~discordcommand id:gear_bot delete group:<discord[gear_bot].group[<[discord_group]>]> name:pesquisar
        - default:
            - debug log "Entrada inválida, por favor verifique as informações."

command_events_find:
    type: world
    events:
        on discord slash command name:pesquisar:
        - define author "Gearpunk | Jogos e Dados"
        - define discord_group "Faculdade - Projeto Sossuer"
        - define title "Pesquisa de Jogos"
        - define images https://cdn.discordapp.com/attachments/900882922435915776/900882986336149534/disc-size.png
        - define list <list>

        - foreach <yaml.list> as:game_list:
            - define game <yaml[<[game_list]>].list_keys[].get[1].if_null[Invalido]>
            - if <yaml[<[game_list]>].read[<[game]>.Game].if_null[false]> = true:
                - define tags <yaml[<[game_list]>].parsed_key[<[game]>.Tags].if_null[Desconhecido]>
                - define plat <context.options.get[plataforma].if_null[Invalido]>
                - choose <context.options.get[plataforma]>:
                    - case Steam:
                        - define price <yaml[<[game_list]>].read[<[game]>.Store.Steam.Price].if_null[none]>
                    - case Epic:
                        - define price <yaml[<[game_list]>].read[<[game]>.Store.Epic.Price].if_null[none]>
                    - case Playstation:
                        - define price <yaml[<[game_list]>].read[<[game]>.Store.Playstation.Price].if_null[none]>
                    - case XBOX:
                        - define price <yaml[<[game_list]>].read[<[game]>.Store.XBOX.Price].if_null[none]>
                    - case Nintendo:
                        - define price <yaml[<[game_list]>].read[<[game]>.Store.Nintendo.Price].if_null[none]>
                    - default:
                        - define price none
                - if <context.options.get[tag].if_null[Invalido]> != Invalido && <context.options.get[tag].contains_any_text[<[tags]>].if_null[Invalido]> && <[price].is_decimal> = true && <[price]> <= <context.options.get[preço]>:
                    - define list <[list].include[**<[game]>**<&sp>Preço:<&sp>R$<[price]><&sp>Plataforma:<&sp><context.options.get[plataforma]>]>
        - define game_embed <discord_embed[thumbnail=<[images]>;footer=<[author]>;color=#86cbfc;title=<[title]><&sp>-<&sp>Preço<&sp>Máximo:<&sp>R$<context.options.get[preço]>]>
        - define game_embed <[game_embed].add_field[Resultados:].value[<[list].separated_by[<&nl>]>]>
        - ~discordinteraction reply interaction:<context.interaction> <[game_embed]>
