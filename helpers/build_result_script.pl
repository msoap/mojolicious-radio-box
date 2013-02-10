#!/usr/bin/perl

=head1 DESCRIPTION

Build result Mojolicious::Lite server script from src/* parts

usage:
    cat ./src/mojolicious-lite-radio-box-server.pl | ./helpers/build_result_script.pl > ./mojolicious-radio-box.pl

=cut

use strict;
use warnings;

# ------------------------------------------------------------------------------
sub main {
    while (my $line = <>) {
        if ($line =~ m/^ \s* \#<<< \s* (.+) \s* $/x) {
            # include file or include stdout of command
            my $cmd = $1;
            if ($cmd =~ /\s/) {
                $cmd =~ s/^base64 /base64 -b 80 / if $^O eq 'darwin'; # Mac OS specific
                print `$cmd`;
            } else {
                print `cat $cmd`;
            }
        } else {
            print $line;
        }
    }
}

# ------------------------------------------------------------------------------
main();
