#!/usr/bin/perl

use strict;
use warnings;

use utf8;
use open qw/:std :utf8/;

use Mojolicious::Lite;
use Data::Dumper;

our %OPTIONS = (
    ini_file => "$ENV{HOME}/.cmus/mojolicious-radio-box.ini",
);

# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
=head1 cmus player client

    http://cmus.sourceforge.net

=cut

# ------------------------------------------------------------------------------

=head1 cmus_get_info

Get info from cmus player

testing:
    perl -ME -E 'do "src/cmus-client.pm"; p cmus_get_info()'
    curl -s 'http://localhost:8080/get_info' | perl -ME -E 'p from_json(<STDIN>)'

=cut

sub cmus_get_info {
    return _cmus_parse_info(`cmus-remote --query`);
}

# ------------------------------------------------------------------------------

=head1 cmus_pause

Pause/unpause player

    cmus_pause()  # toggle
    cmus_pause(1) # pause
    cmus_pause(0) # unpause

=cut

sub cmus_pause {
    return _cmus_parse_info(`cmus-remote --pause --query`);
}

# ------------------------------------------------------------------------------

=head1 cmus_next

do next song

=cut

sub cmus_next {
    return _cmus_parse_info(`cmus-remote --next --query`);
}

# ------------------------------------------------------------------------------

=head1 cmus_prev

do prev song

=cut

sub cmus_prev {
    return _cmus_parse_info(`cmus-remote --prev --query`);
}

# ------------------------------------------------------------------------------

=head1 _cmus_parse_info

Parse lines from cmus-remote -Q

=cut

sub _cmus_parse_info {
    my @info_lines = @_;

    my $result = {};

    for my $line (@info_lines) {
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

# mojolicious routers ----------------------------------------------------------
get '/' => 'index';

get '/get_info'  => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_get_info()});
};

any '/pause'  => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_pause()});
};

any '/next'  => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_next()});
};

any '/prev'  => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_prev()});
};

# go ---------------------------------------------------------------------------
init();
app
    ->secret('KxY0bCQwtVmQa2QdxqX8E0WtmVdpv362NJxofWP')
    ->start('daemon', '--listen=http://*:8080', @ARGV);

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
      #div_error {
          color: red;
          display: none;
          font-family: sans-serif;
          margin-top: 10px;
      }
  </style>
</head>
<body>
    <h1>♫♬ Mojolicious radio box</h1>
    <button id="bt_prev">⌫ prev</button>
    <button id="bt_pause"> pause</button>
    <button id="bt_next">next ⌦</button>
    <div id="div_info"></div>
    <div id="div_error">Server unavailable...</div>
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
      $("#bt_pause").on('click', App.do_pause);
      $("#bt_next").on('click', App.do_next);
      $("#bt_prev").on('click', App.do_prev);
      $(document).ajaxError(function() {
        return $("#div_error").css({
          display: 'block'
        }).fadeOut(1500);
      });
      return App.update_info();
    },
    update_info: function() {
      return $.get('/get_info', function(info_data) {
        App.info = info_data.info;
        return App.render_info();
      });
    },
    render_info: function() {
      if (App.info.status === 'playing') {
        $("#bt_pause").html("&#9724; pause");
      } else if (App.info.status === 'paused') {
        $("#bt_pause").html("&#9658; play");
      }
      if (App.info.tag) {
        return $("#div_info").html("" + App.info.tag.artist + "<br>\n<i>" + App.info.tag.album + "</i><br>\n<b>" + App.info.tag.title + "</b><br>");
      }
    },
    do_pause: function() {
      return $.get('/pause', function(info_data) {
        App.info = info_data.info;
        return App.render_info();
      });
    },
    do_next: function() {
      return $.get('/next', function(info_data) {
        App.info = info_data.info;
        return App.render_info();
      });
    },
    do_prev: function() {
      return $.get('/prev', function(info_data) {
        App.info = info_data.info;
        return App.render_info();
      });
    }
  };

  $(function() {
    return App.init();
  });

}).call(this);
