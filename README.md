Mojolicious radio box for Raspberry Pi
======================================

Small web application for control radio/music player (cmus).
It can be run on a raspberry pi, server or desktop.

INSTALL
-------

    cpan Mojolicious
    
    brew install cmus
    # or
    sudo apt-get install cmus
    
    curl https://raw.github.com/msoap/mojolicious-radio-box/master/mojolicious-radio-box.pl > mojolicious-radio-box.pl
    chmod +x mojolicious-radio-box.pl

RUN
---

    ./mojolicious-radio-box.pl
    # or run as daemon:
    hypnotoad ./mojolicious-radio-box.pl

    # and open in your browser:
    open http://hostname:8080/

SCREENSHOTS
-----------

iPad:

![iPad](http://msoap.github.io/mojolicious-radio-box/img/rpi_ipad_screenshot.png)

Mac OS X dashboard:

![Mac OS X dashboard](http://msoap.github.io/mojolicious-radio-box/img/rpi_dashboard_screenshot.png)

LINKS
-----

 * [Home page](http://msoap.github.io/mojolicious-radio-box/)
 * [cmus player](http://cmus.sourceforge.net) ([github](https://github.com/cmus/cmus))
 * [Mojolicious framework](http://mojolicio.us/)
 * [Raspberry Pi](http://www.raspberrypi.org)

AUTHOR
------
Sergey Mudrik
