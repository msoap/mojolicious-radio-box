# Mojolicious radio box .......................................................
window.App =
    info:
        status: "-"
        position: 0
        duration: 0

    init: ->
        $("#bt_pause").on('click', App.do_pause)
        $("#bt_next").on('click', App.do_next)
        $("#bt_prev").on('click', App.do_prev)
        $(document).ajaxError () ->
            $("#div_error").css
                display: 'block'
            .fadeOut 1500
        App.update_info()
        window.setInterval App.update_info, 15 * 1000

    update_info: ->
        $.get '/get_info', (info_data) ->
            App.info = info_data.info
            App.render_info()

    render_info: ->
        if App.info.status == 'playing'
            $("#bt_pause").html("&#9724; pause")
        else if App.info.status == 'paused'
            $("#bt_pause").html("&#9658; play")

        if App.info.tag
            if App.info.radio_title
                $("#div_info").html """
                    #{App.info.tag.title}<br>
                    <b>#{App.info.radio_title}</b><br>
                """
            else
                $("#div_info").html """
                    #{App.info.tag.artist}<br>
                    <i>#{App.info.tag.album}</i><br>
                    <b>#{App.info.tag.title}</b><br>
                """

    do_pause: ->
        $.get '/pause', (info_data) ->
            App.info = info_data.info
            App.render_info()

    do_next: ->
        $.get '/next', (info_data) ->
            App.info = info_data.info
            App.render_info()

    do_prev: ->
        $.get '/prev', (info_data) ->
            App.info = info_data.info
            App.render_info()

# .............................................................................
$ () -> App.init()
