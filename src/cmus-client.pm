=head1 cmus player client

    http://cmus.sourceforge.net

=cut

# ------------------------------------------------------------------------------

=head2 cmus_get_info

Get info from cmus player

testing:
    perl -ME -E 'do "src/cmus-client.pm"; p cmus_get_info()'
    perl -ME -E 'p from_json(get("http://localhost:8080/get_info"))'

=cut

sub cmus_get_info {
    my $info = _cmus_parse_info(`cmus-remote --query`);

    # for internet-radio get title from file
    if ($info->{status}
        && $info->{status} eq 'playing'
        && ($info->{duration} == -1 || $info->{file} =~ m[^https?://])
        && -r $OPTIONS{last_track_file}
       )
    {
        open my $FH, '<', $OPTIONS{last_track_file} or die "Error open file: $!\n";
        my $add_info = eval{from_json(join("", <$FH>))} || {};
        $info->{radio_title} = $add_info->{title} if $add_info->{title};
        close $FH;
    }

    if ($OPTIONS{is_mac}) {
        $info->{volume} = int(`osascript -e "output volume of (get volume settings)"`);
    } elsif ($OPTIONS{is_pulseaudio}) {
        my ($pa_info) = grep {/set-sink-volume/} `pacmd dump`;
        $pa_info =~ /\s+ ([0-9a-fx]+) \s* $/xi;
        if (defined $1 && hex($1) >= 0) {
            $info->{volume} = int(sprintf("%0.0f", hex($1) / 65536 * 100));
        }
    } elsif ($OPTIONS{is_alsa}) {
        my $alsa_info = join "#", grep {/Front\s+(Left|Right):\s+Playback/} `amixer get Master`;
        if ($alsa_info =~ /\d+ \s+ \[(\d{1,3})%\] .+ \d+ \s+ \[(\d{1,3})%\]/sx) {
            $info->{volume} = int((int($1) + int($2)) / 2);
        }
    }

    $info->{server_version} = $VERSION;

    return $info;
}

# ------------------------------------------------------------------------------

=head2 cmus_pause

Pause/unpause player

=cut

sub cmus_pause {
    return _cmus_parse_info(`cmus-remote --pause --query`);
}

# ------------------------------------------------------------------------------

=head2 cmus_play

Play player

=cut

sub cmus_play {
    return _cmus_parse_info(`cmus-remote --play --query`);
}

# ------------------------------------------------------------------------------

=head2 cmus_stop

Stop player

=cut

sub cmus_stop {
    return _cmus_parse_info(`cmus-remote --stop --query`);
}

# ------------------------------------------------------------------------------

=head2 cmus_next

do next song

=cut

sub cmus_next {
    return _cmus_parse_info(`cmus-remote --next --query`);
}

# ------------------------------------------------------------------------------

=head2 cmus_prev

do prev song

=cut

sub cmus_prev {
    return _cmus_parse_info(`cmus-remote --prev --query`);
}

# ------------------------------------------------------------------------------

=head2 cmus_play_radio

play radio by url

=cut

sub cmus_play_radio {
    my $url = shift;

    if ($url) {
        open my $PIPE, '|-', 'cmus-remote' or die "Error open file: $!\n";
        print $PIPE join("\n", 'view playlist'
                           , 'save'
                           , 'clear'
                           , 'player-stop'
                           , "add $url"
                           , 'player-play'
                           , 'player-next'
                      ) . "\n";
        close $PIPE;
    }

    return cmus_get_info();
}

# ------------------------------------------------------------------------------

=head2 cmus_get_music

=cut

sub cmus_get_music {
    if (-r $OPTIONS{playlist_file}) {
        open my $FH, '<', $OPTIONS{playlist_file} or die "Error open file: $!\n";
        my @playlist = grep {$_ && $_ ne '' && ! m|^https?://|}
                       map {chomp; $_}
                       <$FH>;
        close $FH;

        if (@playlist) {
            open my $PIPE, '|-', 'cmus-remote' or die "Error open file: $!\n";
            print $PIPE join("\n", 'view playlist'
                               , 'clear'
                               , 'player-stop'
                               , map({"add $_"} @playlist)
                               , 'player-play'
                               , 'player-next'
                          ) . "\n";
            close $PIPE;
        }
    }

    return cmus_get_info();
}

# ------------------------------------------------------------------------------

=head2 cmus_set_volume

Set sound volume

=cut

sub cmus_set_volume {
    my $volume = shift;

    die "cmus_set_volume: volume is invalid"
        unless defined $volume
            && $volume =~ /^\d+$/
            && $volume >= 0
            && $volume <= 100;

    if ($OPTIONS{is_mac}) {
        system("osascript", "-e", "set volume output volume $volume");
    } elsif ($OPTIONS{is_pulseaudio}) {
        system("pactl", "set-sink-volume", "0", "${volume}%");
    } elsif ($OPTIONS{is_alsa}) {
        system("amixer", "-q", "set", "Master", "${volume}%");
    }

    return;
}

# ------------------------------------------------------------------------------

=head1 _cmus_parse_info

Parse lines from cmus-remote -Q

=cut

sub _cmus_parse_info {
    my @info_lines = @_;

    my $result = {};

    for my $line (@info_lines) {
        chomp $line;
        my ($name, $value) = split /\s+/, $line, 2;
        if ($name =~ /^(tag|set)$/) {
            my ($sub_name, $value) = split /\s+/, $value, 2;
            $value = $value =~ /^(true|false)$/ ? {true => 1, false => 0}->{$value} : $value;
            $result->{$name}->{$sub_name} = $value;
        } else {
            $result->{$name} = $value;
        }
    }

    return $result;
}
