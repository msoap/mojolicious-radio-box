# util functions
# ------------------------------------------------------------------------------
sub init {
    if (-r $OPTIONS{ini_file}) {
        open my $FH, '<', $OPTIONS{ini_file} or die "Error open file: $!\n";
        while (my $line = <$FH>) {
            chomp $line;
            next if $line =~ m/^ \s* $/x || $line =~ m/^ \s* \# .* $/x;
            my ($key, $value) = split /\s*=\s*/, $line, 2;
            $OPTIONS{$key} = $value;
        }
        close $FH;
        $OPTIONS{radio_playlist_dir} =~ s/^~/$ENV{HOME}/ if defined $OPTIONS{radio_playlist_dir};
    }

    $OPTIONS{is_mac} = 1 if $^O eq 'darwin';
    $OPTIONS{is_linux} = 1 if $^O eq 'linux';
    $OPTIONS{is_pulseaudio} = 1 if $OPTIONS{is_linux} && `pacmd --version` =~ m/^pacmd\s+\d+/;
    $OPTIONS{is_alsa} = 1 if $OPTIONS{is_linux} && `amixer --version` =~ m/^amixer\s+version\s+\d+/;

    # get default sound card for pulseaudio
    if ($OPTIONS{is_pulseaudio} && ! defined $OPTIONS{"pa-default-sink"}) {
        $OPTIONS{"pa-default-sink"} = `pacmd dump | grep set-default-sink | awk '{print \$2}'`;
        if (defined $OPTIONS{"pa-default-sink"} && length($OPTIONS{"pa-default-sink"}) > 0) {
            chomp $OPTIONS{"pa-default-sink"};
        } else {
            $OPTIONS{"pa-default-sink"} = "0";
        }
    }
}

# ------------------------------------------------------------------------------

=head2 get_radio_stations

Get array with radio-station urls (from $OPTIONS{radio_playlist_dir} dir)

testing:
    perl -ME -E 'p from_json(get("http://localhost:8080/get_radio"))'

=cut

sub get_radio_stations {
    my $result = [];

    if ($OPTIONS{radio_playlist_dir} && -d -r $OPTIONS{radio_playlist_dir}) {
        for my $playlist_file (sort glob("$OPTIONS{radio_playlist_dir}/*.m3u"), glob("$OPTIONS{radio_playlist_dir}/*.pls")) {

            my ($title_from_name, $ext) = $playlist_file =~ m{([^/]+)\.(m3u|pls)$};
            $title_from_name =~ s/_/ /g;
            my ($title, $url);

            open my $FH, '<', $playlist_file or die "Error open file: $!\n";

            my %pls;
            while (my $line = <$FH>) {
                chomp $line;

                if ($ext eq 'm3u') {

                    $title = $1 if ! $title && $line =~ /^\#EXTINF: -?\d+, (.+?) \s* $/x;
                    if (! $url && $line =~ m{^https?://}) {
                        $url = $line;
                        $url =~ s/\s+//g;
                    }
                    if ($url) {
                        push @$result, {title => $title || $title_from_name, url => $url};
                        ($url, $title) = (undef, undef);
                    }

                } elsif ($ext eq 'pls') {

                    $pls{$1}->{title} = $title = $2 if $line =~ m{^Title(\d+)=(.+)\s*$};
                    $pls{$1}->{url} = $2 if $line =~ m{^File(\d+)=(https?://.+?)\s*$};

                }
            }

            for my $i (sort {$a <=> $b} keys %pls) {
                push @$result, {title => $pls{$i}->{title} || $title_from_name
                                , url => $pls{$i}->{url}
                               } if $pls{$i}->{url};
            }

            close $FH;
        }
    }

    return $result;
}
