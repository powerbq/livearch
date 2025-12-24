#!/bin/bash

set -e

FLAGFILE=.already-run-before
LOGFILE=/var/log/livearch-build.log

if test -f $FLAGFILE
then
	echo "This container was already run before. Remove it and create new. Exiting..."
	exit 1
fi

touch $FLAGFILE

(
rm -f out/*

pacman -Syu --noconfirm --needed pacman-contrib squashfs-tools sudo

time ./mirror.sh

time ./custom.sh
time ./packages.sh

time ./boot.sh
time ./save.sh

time ./cleanup.sh
) 2>&1 | tee $LOGFILE

cat $LOGFILE > out/build.log
