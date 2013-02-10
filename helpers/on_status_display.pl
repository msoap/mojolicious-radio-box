#!/usr/bin/perl

=head1 DESCRIPTION

Place this script into ~/.cmus/ for save title for last track or title of icecast stream
and change ~/.cmus/autosave:
    set status_display_program=~/.cmus/on_status_display.pl

=cut

use strict;
use warnings;

# ------------------------------------------------------------------------------
sub main {
    my %params = @ARGV;

    open my $FH, '>', "$ENV{HOME}/.cmus/last_track.tsv" or die "Error open file: $!\n";
    for my $key (keys %params) {
        print $FH "$key\t$params{$key}\n";
    }
    close $FH;
}

# ------------------------------------------------------------------------------
main();
