=head1 cmus player client

    http://cmus.sourceforge.net

=cut

# ------------------------------------------------------------------------------

=head1 cmus_get_info

Get info from cmus player

testing:
    perl -ME -E 'do "src/cmus-client.pm"; p cmus_get_info()'
    curl -s 'http://localhost:8080/get_info' | perl -ME -E 'p from_json(<STDIN>)'

=cut

sub cmus_get_info {
    return _cmus_parse_info(`cmus-remote -Q`);
}

# ------------------------------------------------------------------------------

=head1 cmus_pause

Pause/unpause player

    cmus_pause()  # toggle
    cmus_pause(1) # pause
    cmus_pause(0) # unpause

=cut

sub cmus_pause {
    return _cmus_parse_info(`echo "player-pause\nstatus" | cmus-remote`);
}

# ------------------------------------------------------------------------------

=head1 cmus_next

do next song

=cut

sub cmus_next {
    return _cmus_parse_info(`echo "player-next\nstatus" | cmus-remote`);
}

# ------------------------------------------------------------------------------

=head1 cmus_prev

do prev song

=cut

sub cmus_prev {
    return _cmus_parse_info(`echo "player-prev\nstatus" | cmus-remote`);
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
