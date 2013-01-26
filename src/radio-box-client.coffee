# Mojolicious radio box .......................................................
window.App =
    info:
        status: "-"
        position: 0
        duration: 0

    radio_stations: []

    # ...........................................
    init: ->
        $("#bt_pause").on('click', App.do_pause)
        $("#bt_next").on('click', App.do_next)
        $("#bt_prev").on('click', App.do_prev)
        $("#bt_get_radio").on('click', App.do_get_radio)
        $("#radio_stations").on('change', App.do_select_radio)

        $(document).ajaxError () ->
            $("#div_error").show()
            .fadeOut 1500, () ->
                $("button.nav_buttons").removeAttr('disabled')

        App.update_info()
        window.setInterval App.update_info, 15 * 1000

    # ...........................................
    update_info: ->
        $.get '/get_info', (info_data) ->
            App.info = info_data.info
            App.render_info()

    # ...........................................
    render_info: ->
        $("button.nav_buttons").removeAttr('disabled')
        if App.info.status == 'playing'
            $("#bt_pause").html('<i class="icon-pause">&nbsp;&nbsp;pause')
        else if App.info.status == 'paused' || App.info.status == 'stopped'
            $("#bt_pause").html('<i class="icon-play">&nbsp;&nbsp;play')

        if App.info.tag
            if App.info.radio_title
                $("#div_info").html """
                    #{App.info.tag.title}<br>
                    <b>#{App.info.radio_title}</b>
                """
            else if App.info.tag.artist && App.info.tag.album
                $("#div_info").html """
                    #{App.info.tag.artist}<br>
                    <i>#{App.info.tag.album}</i><br>
                    <b>#{App.info.tag.title}</b>
                """
            else
                $("#div_info").html """
                    <b>#{App.info.tag.title}</b>
                """

    # ...........................................
    do_pause: ->
        $("#bt_pause").attr('disabled', 'disabled')
        if App.info.duration > 0 && ! App.info.radio_title
            $.get '/pause', (info_data) ->
                App.info = info_data.info
                App.render_info()
        else if App.info.status == 'playing'
            $.get '/stop', (info_data) ->
                App.info = info_data.info
                App.render_info()
        else if App.info.status == 'stopped'
            $.get '/play', (info_data) ->
                App.info = info_data.info
                App.render_info()

    # ...........................................
    do_next: ->
        $("#bt_next").attr('disabled', 'disabled')
        $.get '/next', (info_data) ->
            App.info = info_data.info
            App.render_info()

    # ...........................................
    do_prev: ->
        $("#bt_prev").attr('disabled', 'disabled')
        $.get '/prev', (info_data) ->
            App.info = info_data.info
            App.render_info()

    # ...........................................
    do_get_radio: ->
        $("#radio_stations").show()
        $.get '/get_radio', (result) ->
            App.radio_stations = result.radio_stations;
            select_input = $('#radio_stations')[0]
            select_input.options.length = 0

            select_input.options.add(new Option(' - please select station -', ''))
            for item in App.radio_stations
                select_input.options.add(new Option(item.title, item.url))

    # ...........................................
    do_select_radio: (event) ->
        if event.target.value
            $.get '/play_radio'
                url: event.target.value
                (info_data) ->
                    App.info = info_data.info
                    App.render_info()

# .............................................................................
$ () -> App.init()
