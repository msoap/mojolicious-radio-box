#!/usr/bin/perl

use strict;
use warnings;

use utf8;
use open qw/:std :utf8/;

use Mojolicious::Lite;
use JSON;
use Data::Dumper;

our %OPTIONS = (
    ini_file => "$ENV{HOME}/.cmus/mojolicious-radio-box.ini",
    last_track_file => "$ENV{HOME}/.cmus/last_track.txt",
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
    ->secret('KxY0bCQwtVmQa2QdxqX8E0WtmVdpv362NJxofWP')
    ->start('daemon', '--listen=http://*:8080', @ARGV);

__DATA__
@@ index.html.ep
#<<< src/index.html

@@ not_found.html.ep
<h1>404</h1>

@@ script.js
#<<< coffee -p src/radio-box-client.coffee
