Mojolicious radio box
=====================

Small web application for control radio/music player (cmus).
It can be run on a server/desktop/raspberry pi.

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
    open http://localhost:8080/

SCREENSHOTS
-----------

Mac OS X dashboard:

![Mac OS X dashboard](http://msoap.github.com/img/mrb-screenshot-dashboard.png)

iPad:

![iPad](http://msoap.github.com/img/mrb-screenshot-ipad.png)

LINKS
-----

 * [cmus player](http://cmus.sourceforge.net)
 * [cmus player github](https://github.com/cmus/cmus)
 * [Mojolicious framework](http://mojolicio.us/)
 * [Raspberry Pi](http://www.raspberrypi.org)

AUTHOR
------
Sergey Mudrik
