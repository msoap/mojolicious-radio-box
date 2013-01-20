#!/usr/bin/perl

use strict;
use warnings;

use utf8;

use Mojolicious::Lite;
use Data::Dumper;

# ------------------------------------------------------------------------------
#<<< src/cmus-client.pm

# mojolicious routers ----------------------------------------------------------
get '/' => 'index';

get '/get_info'  => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', result => cmus_get_info()});
};

any '/pause'  => sub {
    my $self = shift;
    cmus_pause();
    return $self->render_json({status => 'ok'});
};

any '/next'  => sub {
    my $self = shift;
    cmus_next();
    return $self->render_json({status => 'ok'});
};

any '/prev'  => sub {
    my $self = shift;
    cmus_prev();
    return $self->render_json({status => 'ok'});
};

app->secret('KxY0bCQwtVmQa2QdxqX8E0WtmVdpv362NJxofWP')->start('daemon', '--listen=http://*:8080', @ARGV);

__DATA__
@@ index.html.ep
#<<< src/index.html

@@ not_found.html.ep
<h1>404</h1>

@@ script.js
#<<< coffee -p src/radio-box-client.coffee
