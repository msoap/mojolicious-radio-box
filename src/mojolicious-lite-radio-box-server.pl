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
<!doctype html>
<head>
  <meta charset="utf-8">
  <title>Mojolicious radio box</title>
  <script src="/js/jquery.js"></script>
  <script src="script.js"></script>
  <style>
      h1 {
          font-size: 80%;
      }
  </style>
</head>
<body>
    <h1>♫♬Mojolicious radio box</h1>
    <button id="bt_prev">pause</button>
    <button id="bt_pause">pause</button>
    <button id="bt_next">next</button>
    <div id="div_info"></div>
</body>
</html>

@@ not_found.html.ep
<h1>404</h1>

@@ script.js
#<<< coffee -p src/radio-box-client.coffee
