#!/usr/bin/perl

use strict;
use warnings;

use utf8;
use open qw/:std :utf8/;

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

# ------------------------------------------------------------------------------

=head1 cmus_next

do next song

=cut

sub cmus_next {
    system('cmus-remote', '--next');
}

# ------------------------------------------------------------------------------

=head1 cmus_prev

do prev song

=cut

sub cmus_prev {
    system('cmus-remote', '--prev');
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
      #div_info {
          font-family: "Arial Narrow", sans-serif;
          font-size: 90%;
      }
  </style>
</head>
<body>
    <h1>♫♬ Mojolicious radio box</h1>
    <button id="bt_prev">⌫ prev</button>
    <button id="bt_pause"> pause</button>
    <button id="bt_next">next ⌦</button>
    <div id="div_info"></div>
</body>
</html>

@@ not_found.html.ep
<h1>404</h1>

@@ script.js
(function() {

  window.App = {
    info: {
      status: "-",
      position: 0,
      duration: 0
    },
    init: function() {
      console.log("init");
      $("#bt_pause").on('click', App.do_pause);
      $("#bt_next").on('click', App.do_next);
      $("#bt_prev").on('click', App.do_prev);
      return App.update_info();
    },
    update_info: function() {
      return $.get('/get_info', function(info_data) {
        App.info = info_data.result;
        return App.render_info();
      });
    },
    render_info: function() {
      if (App.info.status === 'playing') {
        $("#bt_pause").html("&#9724; pause");
      } else if (App.info.status === 'paused') {
        $("#bt_pause").html("&#9658; play");
      }
      return $("#div_info").html("" + App.info.tag.artist + "<br>\n<i>" + App.info.tag.album + "</i><br>\n<b>" + App.info.tag.title + "</b><br>");
    },
    do_pause: function() {
      console.log("pause");
      return $.get('/pause', function() {
        console.log('pause ok');
        return App.update_info();
      });
    },
    do_next: function() {
      console.log("next");
      return $.get('/next', function() {
        console.log('next ok');
        return App.update_info();
      });
    },
    do_prev: function() {
      console.log("prev");
      return $.get('/prev', function() {
        console.log('prev ok');
        return App.update_info();
      });
    }
  };

  $(function() {
    return App.init();
  });

}).call(this);
