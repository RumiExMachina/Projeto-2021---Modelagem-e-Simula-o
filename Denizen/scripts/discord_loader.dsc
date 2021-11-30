gearpunk_core_command:
    debug: false
    type: command
    name: gear-bot
    description: Comando principal do sistema.
    usage: /gear-bot
    permissions: gear-bot.bot.admin
    tab completions:
        1: ajuda|conectar|desconectar
    script:
        - if <context.args.size> = 0:
            - debug log "Use /gear-bot ajuda"
        - if <context.args.size> > 0:
            - choose <context.args.get[1]>:
                - case ajuda:
                    - debug log "/gear-bot ajuda"
                    - debug log "/gear-bot conectar"
                    - debug log "/gear-bot desconectar"
                - case conectar:
                    - run gearpunk_core_task_connect
                - case desconectar:
                    - run gearpunk_core_task_disconnect
                - default:
                    - debug log "Use /gear-bot ajuda"

gearpunk_core_task_connect:
    debug: false
    type: task
    script:
        - if <discord[gear_bot].if_null[false]> != <discord[gear_bot].if_null[active]>:
            - debug log "[Gearpunk] Bot Conectado!"
            - ~discordconnect id:gear_bot tokenfile:../GearpunkBot/bot_key.txt
            - ~discord id:gear_bot status "Procurando jogos para você!" status:ONLINE activity:PLAYING

gearpunk_core_task_disconnect:
    debug: false
    type: task
    script:
        - if <discord[gear_bot].if_null[false]> == <discord[gear_bot].if_null[active]>:
            - debug log "[Gearpunk] Bot Desconectado!"
            - ~discord id:gear_bot disconnect