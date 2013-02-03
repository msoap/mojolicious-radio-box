get '/' => 'index';

get '/get_info' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_get_info()});
};

post '/pause' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_pause()});
};

post '/play' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_play()});
};

post '/stop' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_stop()});
};

post '/next' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_next()});
};

post '/prev' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_prev()});
};

get '/get_radio' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', radio_stations => get_radio_stations()});
};

post '/play_radio' => sub {
    my $self = shift;
    my $url = $self->param("url");
    return $self->render_json({status => 'ok', info => cmus_play_radio($url)});
};

get '/get_music' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_get_music()});
};

post '/set_volume' => sub {
    my $self = shift;

    my $volume = $self->param("volume");
    cmus_set_volume($volume);
    return $self->render_json({status => 'ok'});
};

# curl -s http://localhost:8080/help.txt
get '/help' => sub {
    my $self = shift;
    my $routes = $self->app->routes();
    my $result = join "\n",
                 map {
                     ($_->{via} ? join("/", @{$_->{via}}) : "ANY")
                     . " "
                     . ($_->{pattern}->{pattern} || "/")
                 }
                 sort {($a->{pattern}->{pattern} || '') cmp ($b->{pattern}->{pattern} || '')}
                 @{$routes->{children}};

    return $self->render_text($result);
};

get '/version' => sub {
    my $self = shift;
    return $self->render_text($VERSION);
};

app->hook(
    before_dispatch => sub {
        my $self = shift;
        $self->res->headers->header('Server' => "Mojolicious radio box - $VERSION");
    }
);
