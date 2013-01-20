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
