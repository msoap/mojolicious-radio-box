#!/usr/bin/perl

use strict;
use warnings;

use utf8;

use Mojolicious::Lite;
use Data::Dumper;

=head1 cmus player client

    http://cmus.sourceforge.net

=cut

# ------------------------------------------------------------------------------
sub cmus_get_info {
}

# mojolicious routers ----------------------------------------------------------
get '/' => 'index';

app->secret('KxY0bCQwtVmQa2QdxqX8E0WtmVdpv362NJxofWP')->start('daemon', '--listen=http://*:8080', @ARGV);

__DATA__
@@ index.html.ep
<!doctype html>
<head>
  <meta charset="utf-8">
  <title>Mojolicious radio box</title>
  <script src="script.js"></script>
</head>
<body>
</body>
</html>

@@ not_found.html.ep
<h1>404</h1>

@@ script.js
(function() {

  window.App = {
    init: function() {
      return console.log("init");
    }
  };

  App.init();

}).call(this);
