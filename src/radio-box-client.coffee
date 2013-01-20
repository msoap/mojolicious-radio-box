# Mojolicious radio box .......................................................
window.App =
    init: ->
        console.log "init"
        $("#bt_pause").on('click', App.do_pause)

    do_pause: ->
        console.log "pause"
        $.get('/pause', () -> console.log('pause ok'))

# .............................................................................
$ () -> App.init()
