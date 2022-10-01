#!/bin/bash

set -e

echo $0

cd $(dirname $0)

pacman -Syu --noconfirm

find /boot -maxdepth 1 -type f -exec rm {} \;

su -c './custom.sh' build

test -n "${BOOT_SKIP_HOOKS}" && BOOT_SKIP_HOOKS="${BOOT_SKIP_HOOKS},"
test -n "${BOOT_ADD_HOOKS}" && BOOT_ADD_HOOKS="${BOOT_ADD_HOOKS},"

if test "${PLYMOUTH_INSTALL}" = yes
then
	BOOT_ADD_HOOKS="plymouth,${BOOT_ADD_HOOKS}"
	pacman -Syu --noconfirm plymouth

	if test -n "${BOOT_PLYMOUTH_THEME}"
	then
		cat > /etc/plymouth/plymouthd.conf << EOF
[Daemon]
Theme=${BOOT_PLYMOUTH_THEME}
EOF
	fi
fi

sed -i 's/^default_options=.*$/default_options="-S ${BOOT_SKIP_HOOKS}autodetect -A ${BOOT_ADD_HOOKS}livearch"/' /usr/share/mkinitcpio/hook.preset

pacman -Syu --noconfirm intel-ucode amd-ucode ${BOOT_PACKAGES}

LIST=$(find opt/pkg-built -maxdepth 1 -type f -name '*.pkg.*')
if test -n "$LIST"
then
	pacman -U --needed --noconfirm $LIST
fi

mkinitcpio -P

find out -maxdepth 1 -type f -name 'vmlinuz-*' -exec rm {} \;
find out -maxdepth 1 -type f -name 'initramfs-*.img' -exec rm {} \;
find out -maxdepth 1 -type f -name 'modules-*.squashfs*' -exec rm {} \;
find out -maxdepth 1 -type f -name '*-ucode.img' -exec rm {} \;

find /boot -maxdepth 1 -type f -name 'vmlinuz-*' -exec cp --no-preserve=mode {} out \;
find /boot -maxdepth 1 -type f -name 'initramfs-*.img' -exec cp --no-preserve=mode {} out \;
find /boot -maxdepth 1 -type f -name 'modules-*.squashfs*' -exec cp --no-preserve=mode {} out \;
find /boot -maxdepth 1 -type f -name '*-ucode.img' -exec cp --no-preserve=mode {} out \;

./cleanup.sh /
