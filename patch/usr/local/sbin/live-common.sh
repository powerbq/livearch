#!/bin/bash

ln -srf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

echo $HOSTNAME > /etc/hostname

echo "$LOCALE.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

echo "LANG=$LOCALE.UTF-8" > /etc/locale.conf

systemctl enable live-sync

exit 0
