#!/bin/bash

depmod

ln -srf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

echo $HOSTNAME > /etc/hostname

echo "$LOCALE.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

echo "LANG=$LOCALE.UTF-8" > /etc/locale.conf

sed -ri 's|^(GROUP=.*)$|# \1|' /etc/default/useradd

systemctl enable live-sync
systemctl enable postinst-image

test -f /usr/lib/systemd/system/man-db.timer && systemctl disable man-db.timer

sed -i -r -z 's|\n#([[]multilib[]])\n#|\n\1\n|' /etc/pacman.conf
sed -i -r 's|^#(Server = https://mirrors\.kernel\.org)|\1|' /etc/pacman.d/mirrorlist

exit 0
