# docker build -t mojolicious-radio-box .
# docker run --rm -it -p 8080:8080 -v $PWD/cmus:/home/.cmus -v $XDG_RUNTIME_DIR/cmus-socket:/app/cmus-socket -e HOME=/home -v /run/user/$UID/pulse:/run/user/1/pulse -e CMUS_SOCKET=/app/cmus-socket mojolicious-radio-box

FROM perl:5.28-slim-threaded

RUN cpan Mojolicious

RUN apt-get update \
    && apt-get install -y cmus pulseaudio-utils \
    && rm -rf /var/lib/apt/lists/*

ENV USER pauser

RUN echo "default-server = unix:/run/user/1/pulse/native\nautospawn = no\ndaemon-binary = /bin/true\nenable-shm = false\n" > /etc/pulse/client.conf

ADD mojolicious-radio-box.pl /app/mojolicious-radio-box.pl

EXPOSE 8080

CMD hypnotoad --foreground /app/mojolicious-radio-box.pl
