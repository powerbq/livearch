#!/bin/bash

set -e

echo $0

test -n "${BOOT_SKIP_HOOKS}" && BOOT_SKIP_HOOKS="${BOOT_SKIP_HOOKS},"
test -n "${BOOT_ADD_HOOKS}" && BOOT_ADD_HOOKS="${BOOT_ADD_HOOKS},"

if test "${PLYMOUTH_INSTALL}" = yes
then
	BOOT_ADD_HOOKS="plymouth,${BOOT_ADD_HOOKS}"
fi

sed -i 's/^default_options=.*$/default_options="-S ${BOOT_SKIP_HOOKS}autodetect -A ${BOOT_ADD_HOOKS}livearch"/' /etc/mkinitcpio.d/linux.preset

mkinitcpio -P

find out -maxdepth 1 -type f -name 'vmlinuz-*' -exec rm {} \;
find out -maxdepth 1 -type f -name 'initramfs-*.img' -exec rm {} \;

find /boot -maxdepth 1 -type f -name 'vmlinuz-*' -exec cp --no-preserve=mode {} out \;
find /boot -maxdepth 1 -type f -name 'initramfs-*.img' -exec cp --no-preserve=mode {} out \;
