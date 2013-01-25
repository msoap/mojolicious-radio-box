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
