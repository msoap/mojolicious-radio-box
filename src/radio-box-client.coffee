# Mojolicious radio box .......................................................
window.App =
    info:
        status: "-"
        position: 0
        duration: 0

    init: ->
        console.log "init"
        $("#bt_pause").on('click', App.do_pause)
        $("#bt_next").on('click', App.do_next)
        App.update_info()

    update_info: ->
        $.get '/get_info', (info_data) ->
            App.info = info_data.result
            App.render_info()

    render_info: ->
        $("#div_info").html """
            Artist: #{App.info.tag.artist}<br>
            album: #{App.info.tag.album}<br>
            <b>#{App.info.tag.title}</b><br>
        """

    do_pause: ->
        console.log "pause"
        $.get '/pause', () -> console.log('pause ok')

    do_next: ->
        console.log "next"
        $.get '/next', () ->
            console.log('next ok')
            App.update_info()

# .............................................................................
$ () -> App.init()
