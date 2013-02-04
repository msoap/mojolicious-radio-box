#!/usr/bin/perl

=head1 Mojolicious radio box

Small web application for control radio/music player (cmus).
It can be run on a server/desktop/raspberry pi.

https://github.com/msoap/mojolicious-radio-box

=cut

use strict;
use warnings;

use utf8;
use open qw/:std :utf8/;

use Mojolicious::Lite;
use JSON;
use Data::Dumper;

our $VERSION = '0.01';

our %OPTIONS = (
    ini_file => "$ENV{HOME}/.cmus/mojolicious-radio-box.ini",
    last_track_file => "$ENV{HOME}/.cmus/last_track.json",
    playlist_file => "$ENV{HOME}/.cmus/playlist.pl",
    listen_address => 'http://*:8080',
    hypnotoad_workers => 2,
    hypnotoad_accept_interval => 0.7,
);

# ------------------------------------------------------------------------------
#<<< src/util.pm

# ------------------------------------------------------------------------------
#<<< src/cmus-client.pm

# mojolicious routers ----------------------------------------------------------
#<<< src/routers.pm

# go ---------------------------------------------------------------------------
init();
app
    ->config(
        hypnotoad => {
            listen => [$OPTIONS{listen_address}],
            workers => $OPTIONS{hypnotoad_workers},
            accept_interval => $OPTIONS{hypnotoad_accept_interval},
        }
    )
    ->secret('KxY0bCQwtVmQa2QdxqX8E0WtmVdpv362NJxofWP')
    ->start(@ARGV ? @ARGV : ("daemon", "--listen=$OPTIONS{listen_address}"));

__DATA__
@@ index.html.ep
#<<< src/index.html

@@ not_found.html.ep
<h1>404</h1>

@@ script.js
#<<< coffee -p src/radio-box-client.coffee

@@ font-awesome.css
#<<< src/static/font-awesome.min.css


@@ fontawesome-webfont.eot (base64)
#<<< base64 -b 80 src/static/fontawesome-webfont.eot

@@ fontawesome-webfont.woff (base64)
#<<< base64 -b 80 src/static/fontawesome-webfont.woff

@@ fontawesome-webfont.ttf (base64)
#<<< base64 -b 80 src/static/fontawesome-webfont.ttf

@@ apple-touch-icon.png (base64)
#<<< base64 -b 80 src/static/apple-touch-icon-144x144.png

@@ apple-touch-icon-144x144.png (base64)
#<<< base64 -b 80 src/static/apple-touch-icon-144x144.png
