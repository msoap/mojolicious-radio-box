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
