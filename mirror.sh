#!/bin/bash

set -e

echo $0

cd $(dirname $0)

if test -n "${MIRROR_COUNTRY_CODE}"
then
	curl -s "https://archlinux.org/mirrorlist/?country=${MIRROR_COUNTRY_CODE}&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 1 - | grep '^Server' > /etc/pacman.d/mirrorlist
fi
