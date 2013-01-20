#!/usr/bin/perl

use strict;
use warnings;

use utf8;

use Mojolicious::Lite;
use Data::Dumper;

# ------------------------------------------------------------------------------
=head1 cmus player client

    http://cmus.sourceforge.net

=cut

# ------------------------------------------------------------------------------

=head1 cmus_get_info

Get info from cmus player

testing:
    perl -ME -E 'do "src/cmus-client.pm"; p cmus_get_info()'

=cut

sub cmus_get_info {
    my $result = {};

    for my $line (`cmus-remote -Q`) {
        chomp $line;
        my ($name, $value) = split /\s+/, $line, 2;
        if ($name =~ /^(tag|set)$/) {
            my ($sub_name, $value) = split /\s+/, $value, 2;
            $value = $value =~ /^(true|false)$/ ? {true => 1, false => 0}->{$value} : $value;
            $result->{$name}->{$sub_name} = $value;
        } else {
            $result->{$name} = $value;
        }
    }

    return $result;
}

# ------------------------------------------------------------------------------

=head1 cmus_pause

Pause/unpause player

    cmus_pause()  # toggle
    cmus_pause(1) # pause
    cmus_pause(0) # unpause

=cut

sub cmus_pause {
    my $what = shift;

    if (! defined $what) {
        system('cmus-remote', '--pause');
    } elsif ($what) {
        my $info = cmus_get_info() || {};
        system('cmus-remote', '--pause') if $info->{status} eq 'playing';
    } elsif (! $what) {
        my $info = cmus_get_info() || {};
        system('cmus-remote', '--pause') if $info->{status} eq 'paused';
    }
}

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

app->secret('KxY0bCQwtVmQa2QdxqX8E0WtmVdpv362NJxofWP')->start('daemon', '--listen=http://*:8080', @ARGV);

__DATA__
@@ index.html.ep
<!doctype html>
<head>
  <meta charset="utf-8">
  <title>Mojolicious radio box</title>
  <script src="/js/jquery.js"></script>
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
