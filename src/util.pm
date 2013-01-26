# util functions
# ------------------------------------------------------------------------------
sub init {
    if (-r $OPTIONS{ini_file}) {
        open my $FH, '<', $OPTIONS{ini_file} or die "Error open file: $!\n";
        while (my $line = <$FH>) {
            chomp $line;
            next if $line =~ m/^ \s* \# .* $/x;
            my ($key, $value) = split /\s*=\s*/, $line, 2;
            $OPTIONS{$key} = $value;
        }
        close $FH;
        $OPTIONS{radio_playlist_dir} =~ s/^~/$ENV{HOME}/ if defined $OPTIONS{radio_playlist_dir};
    }
}

# ------------------------------------------------------------------------------
sub get_radio_stations {
    my $result = [];

    if ($OPTIONS{radio_playlist_dir} && -d -r $OPTIONS{radio_playlist_dir}) {
        for my $m3u_file (glob "$OPTIONS{radio_playlist_dir}/*.m3u") {
            my ($title) = $m3u_file =~ m{([^/]+\.m3u)$};
            my $url;
            open my $FH, '<', $m3u_file or die "Error open file: $!\n";
            while (my $line = <$FH>) {
                chomp $line;
                if ($line =~ m{^http://}) {
                    $url = $line;
                    $url =~ s/\s+//g;
                    last;
                }
            }
            close $FH;
            push @$result, {title => $title, url => $url} if $title && $url;
        }
    }

    return $result;
}
