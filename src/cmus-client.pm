=head1 cmus player client

    http://cmus.sourceforge.net

=cut

# ------------------------------------------------------------------------------

=head1 cmus_get_info

Get info from cmus player

testing:
    perl -ME -E 'do "src/cmus-client.pm"; p cmus_get_info()'

=cut

sub cmus_get_info {
    my $result = {};

    for my $line (`cmus-remote -Q`) {
        chomp $line;
        my ($name, $value) = split /\s+/, $line, 2;
        if ($name =~ /^(tag|set)$/) {
            my ($sub_name, $value) = split /\s+/, $value, 2;
            $result->{$name}->{$sub_name} = $value;
        } else {
            $result->{$name} = $value;
        }
    }

    return $result;
}

# ------------------------------------------------------------------------------

=head1 cmus_pause

Pause/unpause player

    cmus_pause()  # toggle
    cmus_pause(1) # pause
    cmus_pause(0) # unpause

=cut

sub cmus_pause {
    my $what = shift;

    if (! defined $what) {
        system('cmus-remote', '--pause');
    } elsif ($what) {
        my $info = cmus_get_info() || {};
        system('cmus-remote', '--pause') if $info->{status} eq 'playing';
    } elsif (! $what) {
        my $info = cmus_get_info() || {};
        system('cmus-remote', '--pause') if $info->{status} eq 'paused';
    }
}
