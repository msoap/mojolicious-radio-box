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
    my $info = _cmus_parse_info(`cmus-remote --query`);

    # for internet-radio get title from file
    if ($info->{status} eq 'playing'
        && ($info->{duration} == -1 || $info->{file} =~ m[^http://])
        && -r $OPTIONS{last_track_file}
       )
    {
        open my $FH, '<', $OPTIONS{last_track_file} or die "Error open file: $!\n";
        my $add_info = eval{from_json(join("", <$FH>))} || {};
        $info->{radio_title} = $add_info->{title} if $add_info->{title};
        close $FH;
    }

    return $info;
}

# ------------------------------------------------------------------------------

=head1 cmus_pause

Pause/unpause player

    cmus_pause()  # toggle
    cmus_pause(1) # pause
    cmus_pause(0) # unpause

=cut

sub cmus_pause {
    return _cmus_parse_info(`cmus-remote --pause --query`);
}

# ------------------------------------------------------------------------------

=head1 cmus_next

do next song

=cut

sub cmus_next {
    return _cmus_parse_info(`cmus-remote --next --query`);
}

# ------------------------------------------------------------------------------

=head1 cmus_prev

do prev song

=cut

sub cmus_prev {
    return _cmus_parse_info(`cmus-remote --prev --query`);
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
