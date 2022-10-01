#!/bin/bash

LIST=
test -d /opt/pkg-deps   && LIST=$(find /opt/pkg-deps -maxdepth 1 -type f -name '*.pkg.*')
test -n "$LIST" && pacman -U --noconfirm $LIST && rm -f $LIST

LIST=
test -d /opt/pkg-nodeps && LIST=$(find /opt/pkg-nodeps -maxdepth 1 -type f -name '*.pkg.*')
test -n "$LIST" && pacman -Udd --noconfirm $LIST && rm -f $LIST

exit 0
