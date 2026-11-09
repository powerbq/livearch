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

prepare() {
	sed -i 's/^NoExtract/#NoExtract/g' /etc/pacman.conf

	pacman -Syu --noconfirm
	pacman -Syu --noconfirm $(pacman -Qqn)

	for FILE_FROM in $(find / -mount -type f -name '*.pacnew')
	do
		FILE_TO=$(echo $FILE_FROM | sed 's/\.pacnew$//')

		echo "restoring '$FILE_TO' from '$FILE_FROM'"
		cp -a $FILE_FROM $FILE_TO
		rm -v $FILE_FROM
	done

	sed -i -r    's|^#(Server = https://)|\1|'      /etc/pacman.d/mirrorlist
	sed -i -r    's|^(CheckSpace)$|DisableSandbox|' /etc/pacman.conf
	sed -i -r -z 's|\n#([[]multilib[]])\n#|\n\1\n|' /etc/pacman.conf
}

(
case $1 in
	init)
		find out -mindepth 1 -maxdepth 1 -exec rm -Rf {} \;
	;;

	custom)
		prepare

		pacman -Syu --noconfirm --needed pacman-contrib sudo

		time ./mirror.sh
		time ./custom.sh
		time ./cleanup.sh
	;;

	system)

		prepare

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
