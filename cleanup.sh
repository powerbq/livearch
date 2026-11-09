#!/bin/bash

set -e

echo $0

list() {
	ls /var/cache/pacman/pkg | sed -r 's/-[^-]*\.pkg\.tar(\.(xz|zst))?(\.sig)?$//' | sort -u

	pacman -Q | tr ' ' '-'
}

unneeded() {
	pacman -Qeq | grep -vxf <(pacman -Qq base)
}

for PACKAGE in $(list $@ | sort | uniq -u)
do
	rm -fv /var/cache/pacman/pkg/$PACKAGE*
done

pacman -Rns --noconfirm $(unneeded)
