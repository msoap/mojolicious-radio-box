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
        $("#bt_prev").on('click', App.do_prev)
        App.update_info()

    update_info: ->
        $.get '/get_info', (info_data) ->
            App.info = info_data.result
            App.render_info()

    render_info: ->
        if App.info.status == 'playing'
            $("#bt_pause").html("&#9724; pause")
        else if App.info.status == 'paused'
            $("#bt_pause").html("&#9658; play")

        $("#div_info").html """
            #{App.info.tag.artist}<br>
            <i>#{App.info.tag.album}</i><br>
            <b>#{App.info.tag.title}</b><br>
        """

    do_pause: ->
        console.log "pause"
        $.get '/pause', () -> console.log('pause ok')
        App.update_info()

    do_next: ->
        console.log "next"
        $.get '/next', () ->
            console.log('next ok')
            App.update_info()

    do_prev: ->
        console.log "prev"
        $.get '/prev', () ->
            console.log('prev ok')
            App.update_info()

# .............................................................................
$ () -> App.init()
