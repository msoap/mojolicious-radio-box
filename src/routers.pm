get '/' => 'index';

get '/get_info' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_get_info()});
};

any '/pause' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_pause()});
};

any '/play' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_play()});
};

any '/stop' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_stop()});
};

any '/next' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_next()});
};

any '/prev' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', info => cmus_prev()});
};

any '/get_radio' => sub {
    my $self = shift;
    return $self->render_json({status => 'ok', radio_stations => get_radio_stations()});
};

any '/play_radio' => sub {
    my $self = shift;
    my $url = $self->param("url");
    return $self->render_json({status => 'ok', info => cmus_play_radio($url)});
};
