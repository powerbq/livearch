#!/bin/bash

cd /

for DESC in $(find /var/lib/pacman/local/* -name 'desc' -printf '%T@ %p\n' | sort | cut -d' ' -f2); do
	SCRIPT=$(dirname $DESC)/install
	test ! -f $SCRIPT && continue

	if grep -iF 'post_install()' $SCRIPT > /dev/null; then
		NAME=$(cat $DESC | grep -1 %NAME% | tail -n 1)
		VER=$(cat $DESC | grep -1 %VERSION% | tail -n 1)

		echo "installing $NAME..."
		sh -c "source $SCRIPT && post_install $VER"
	fi
done
