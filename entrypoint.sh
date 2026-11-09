#!/bin/bash

set -e
set -o pipefail

FLAGFILE=.already-run-before
LOGFILE=/var/log/livearch-build.log

if test -f $FLAGFILE
then
	echo "This container was already run before. Remove it and create new. Exiting..."
	exit 1
fi

touch $FLAGFILE

(
case $1 in
	init)
		find out -mindepth 1 -maxdepth 1 -exec rm -Rf {} \;
	;;

	custom)
		pacman -Syu --noconfirm --needed pacman-contrib sudo

		time ./mirror.sh
		time ./custom.sh
		time ./cleanup.sh
	;;

	system)
		pacman -Syu --noconfirm --needed pacman-contrib squashfs-tools

		time ./mirror.sh
		time ./packages.sh
		time ./boot.sh
		time ./save.sh
		time ./cleanup.sh
	;;

	success)
		touch out/build-finished.txt
	;;

	*)
		exit 1
	;;
esac
) 2>&1 | tee $LOGFILE

cat $LOGFILE > out/build-$1.log

find out -mindepth 1 -maxdepth 1 -type f -name '*.log' -size 0 -delete
