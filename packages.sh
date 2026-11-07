#!/bin/bash

set -e

echo $0

depends=(
)

conflicts=(
)

for PKGBUILD in $(find . -maxdepth 1 -type f -name 'PKGBUILD-*' | sort)
do
	source $PKGBUILD
done

cat > /etc/vconsole.conf <<EOF
KEYMAP=us
EOF

pacman -Syu --noconfirm --needed base linux linux-firmware intel-ucode amd-ucode ${depends[*]}

LIST=${conflicts[*]}
if test -n "$LIST"
then
	pacman -Rcn --noconfirm $LIST
fi

LIST=$(find opt/pkg-deps -maxdepth 1 -type f -name '*.pkg.*')
if test -n "$LIST"
then
	pacman -U --noconfirm $LIST
fi

LIST=$(find opt/pkg-nodeps -maxdepth 1 -type f -name '*.pkg.*')
if test -n "$LIST"
then
	pacman -Udd --noconfirm $LIST
fi
