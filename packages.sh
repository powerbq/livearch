#!/bin/bash

set -e

echo $0

depends=(
)

for PKGBUILD in $(find . -maxdepth 1 -type f -name 'PKGBUILD-*' | sort)
do
	source $PKGBUILD
done

pacman -Syu --noconfirm --needed base linux linux-firmware intel-ucode amd-ucode ${depends[*]}

if test "${PLYMOUTH_INSTALL}" = yes
then
	pacman -Syu --noconfirm plymouth

	if test -n "${BOOT_PLYMOUTH_THEME}"
	then
		cat > /etc/plymouth/plymouthd.conf << EOF
[Daemon]
Theme=${BOOT_PLYMOUTH_THEME}
EOF
	fi
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
