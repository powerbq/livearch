#!/bin/bash

set -e

echo $0

cd $(dirname $0)

su -c './custom.sh' build

mkdir -p root
find root -mindepth 1 -maxdepth 1 -exec rm -Rf {} \;
chmod 755 root
chown 0:0 root


depends=(
)

for PKGBUILD in $(find . -maxdepth 1 -type f -name 'PKGBUILD-*' | sort)
do
	source $PKGBUILD
done

mkdir -p root/var/lib/pacman

pacman -Sy -r root

LIST=$(find opt/pkg-built -maxdepth 1 -type f -name '*.pkg.*')
if test -n "$LIST"
then
	pacman -U -r root --dbonly --noconfirm $LIST
fi

pacman -Syu -r root --dbonly --noconfirm --needed base ${depends[*]}
pacman -Syu -r root --dbonly --noconfirm --needed cpio python

if test "${PLYMOUTH_INSTALL}" = yes
then
	pacman -Syu -r root --dbonly --noconfirm --needed plymouth
fi

LIST=$(find opt/pkg-deps -maxdepth 1 -type f -name '*.pkg.*')
if test -n "$LIST"
then
	pacman -U -r root --dbonly --noconfirm $LIST
fi

LIST=$(find opt/pkg-nodeps -maxdepth 1 -type f -name '*.pkg.*')
if test -n "$LIST"
then
	pacman -Udd -r root --dbonly --noconfirm $LIST
fi
