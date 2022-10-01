#!/bin/bash

set -e

echo $0

list() {
	ls /var/cache/pacman/pkg | sed -r 's/-[^-]*\.pkg\.tar(\.(xz|zst))?(\.sig)?$//' | sort -u

	for ROOT in $@
	do
		pacman -Q -r $ROOT | tr ' ' '-'
	done | sort -u
}

for PACKAGE in $(list $@ | sort | uniq -u)
do
	rm -fv /var/cache/pacman/pkg/$PACKAGE*
done
