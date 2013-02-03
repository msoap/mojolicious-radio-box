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
        $("#bt_get_music").on('click', App.do_get_music)
        $("#radio_stations").on('change', App.do_select_radio)
        $("#volume_slider").on('change', {absolute: true}, App.do_change_volume)
        $("#volume_slider").on('blur', {absolute: true}, App.do_change_volume)
        $("#volume_down").on('click', {down: 10}, App.do_change_volume)
        $("#volume_up").on('click', {up: 10}, App.do_change_volume)

        $(document).ajaxError () ->
            $("#div_error").show()
            .fadeOut 1500, () ->
                $("button.nav_buttons").removeAttr('disabled')

        App.update_info()

        # update info every 15 seconds (not on dashboard)
        window.setInterval App.update_info, 15 * 1000 if ! navigator.userAgent.match(/WebClip/)

    # ...........................................
    update_info: ->
        $.get '/get_info', (info_data) ->
            App.info = info_data.info
            App.volume = App.info.volume if App.info.volume?
            App.render_info()

    # ...........................................
    render_info: ->
        $("button.nav_buttons").removeAttr('disabled')
        if App.info.status == 'playing'
            $("#bt_pause").html('<i class="icon-pause">&nbsp;&nbsp;pause')
            if App.info.duration == "-1"
                $("#bt_prev").attr('disabled', 'disabled')
                $("#bt_next").attr('disabled', 'disabled')
        else if App.info.status == 'paused' || App.info.status == 'stopped'
            $("#bt_pause").html('<i class="icon-play">&nbsp;&nbsp;play')

        if App.info.tag
            position = if parseInt(App.info.position) > 0
                           " (" + App.format_track_time(parseInt(App.info.position)) + ")"
                       else
                           ""
            if App.info.radio_title
                $("#div_info").html """
                    #{App.info.tag.title}<br>
                    <b>#{App.info.radio_title}#{position}</b>
                """

            else if App.info.tag.artist && App.info.tag.album
                duration = if parseInt(App.info.duration) > 0
                               " (" + App.format_track_time(parseInt(App.info.duration)) + ")"
                           else
                               ""
                $("#div_info").html """
                    #{App.info.tag.artist}<br>
                    <i>#{App.info.tag.album}</i><br>
                    <b>#{App.info.tag.title}#{duration}</b>
                """
                $("#radio_stations").hide()[0].selectedIndex = 0

            else
                $("#div_info").html """
                    <b>#{App.info.tag.title}#{position}</b>
                """

        if App.info.radio_title || App.info.file? && App.info.file.match(/https?:\/\//)
            $("#radio_stations").show()
            if App.radio_stations.length
                App.render_select_radio()
            else
                App.do_get_radio()

        if App.volume?
            $('input#volume_slider').val(App.volume)

    # ...........................................
    render_select_radio: ->
        select_input = $('#radio_stations')[0]
        select_input.options.length = 0

        select_input.options.add(new Option(' - please select station -', ''))
        for item in App.radio_stations
            new_option = new Option(item.title, item.url)
            if App.info.file? && App.info.file.match(/https?:\/\//) && App.info.file == item.url
                new_option.selected = true
            select_input.options.add(new_option)

    # ...........................................
    format_track_time: (all_seconds) ->
        hours = Math.floor(all_seconds / 3600)
        minutes = Math.floor((all_seconds - hours * 3600) / 60)
        seconds = (all_seconds - hours * 3600 - minutes * 60) % 60
        minutes = "0#{minutes}" if minutes < 10
        seconds = "0#{seconds}" if seconds < 10
        result = "#{minutes}:#{seconds}"
        result = "#{hours}:#{result}" if hours > 0
        return result

    # events ....................................
    do_pause: ->
        $("#bt_pause").attr('disabled', 'disabled')
        if App.info.duration > 0 && ! App.info.radio_title
            $.post '/pause', (info_data) ->
                App.info = info_data.info
                App.render_info()
        else if App.info.status == 'playing'
            $.post '/stop', (info_data) ->
                App.info = info_data.info
                App.render_info()
        else if App.info.status == 'stopped'
            $.post '/play', (info_data) ->
                App.info = info_data.info
                App.render_info()

    # ...........................................
    do_next: ->
        $("#bt_next").attr('disabled', 'disabled')
        $.post '/next', (info_data) ->
            App.info = info_data.info
            App.render_info()

    # ...........................................
    do_prev: ->
        $("#bt_prev").attr('disabled', 'disabled')
        $.post '/prev', (info_data) ->
            App.info = info_data.info
            App.render_info()

    # ...........................................
    do_get_radio: ->
        $.get '/get_radio', (result) ->
            $("#radio_stations").show()
            App.radio_stations = result.radio_stations;
            App.render_select_radio()

    # ...........................................
    do_get_music: ->
        $.get '/get_music', (info_data) ->
            App.info = info_data.info
            App.render_info()

    # ...........................................
    do_select_radio: (event) ->
        if event.target.value
            $.post '/play_radio'
                url: event.target.value
                (info_data) ->
                    App.info = info_data.info
                    App.render_info()

    # ...........................................
    do_change_volume: (event) ->
        if App._change_valume_tid
            window.clearTimeout App._change_valume_tid
            App._change_valume_tid = undefined

        new_volume = 0
        if event.data.up && App.volume?
            new_volume = App.volume + event.data.up
            new_volume = 100 if new_volume > 100
        else if event.data.down && App.volume?
            new_volume = App.volume - event.data.down
            new_volume = 0 if new_volume < 0
        else if event.data.absolute
            new_volume = parseInt($("#volume_slider").val())
        else
            return

        App._change_valume_tid = window.setTimeout(
            () ->
                if new_volume? && new_volume != App.volume
                    App.volume = new_volume
                    $("#volume_slider").val(new_volume)
                    $.post '/set_volume/' + new_volume
            200
        )
# .............................................................................
$ () -> App.init()
