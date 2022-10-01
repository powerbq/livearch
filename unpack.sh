#!/bin/bash

set -e

echo $0

cd $(dirname $0)

for DIR in $(find root/var/lib/pacman/local -mindepth 1 -maxdepth 1 -type d)
do
	NAME=$(cat $DIR/desc | grep -P1 '^%NAME%$'    | tail -n1)
	VER=$( cat $DIR/desc | grep -P1 '^%VERSION%$' | tail -n1)
	ARCH=$(cat $DIR/desc | grep -P1 '^%ARCH%$'    | tail -n1)
	PKG=/var/cache/pacman/pkg/$NAME-$VER-$ARCH.pkg.tar
	test -f $PKG.xz  && PKG=$PKG.xz
	test -f $PKG.zst && PKG=$PKG.zst
	test -f $PKG || continue
	bsdtar -xp -C root -f $PKG
done

if test -d opt
then
	for DIR in $(find opt -mindepth 1 -maxdepth 1 -type d -name 'pkg-*')
	do
		for PKG in $(find $DIR -maxdepth 1 -type f -name '*.pkg.*')
		do
			bsdtar -xp -C root -f $PKG
		done
	done
fi

find root -mindepth 1 -maxdepth 1 -name '.*' -exec rm -Rf {} \;
