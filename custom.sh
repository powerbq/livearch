#!/bin/bash

set -e

echo $0

if test $(id -u) = 0
then
	USERID=60000
	GROUPID=60000
	USERNAME=build

	pacman -Syu --noconfirm base-devel git

	sed -i -e '/^OPTIONS=/s/debug/!debug/' /etc/makepkg.conf

	groupadd -g $GROUPID $USERNAME
	useradd -u $USERID -g $GROUPID -m $USERNAME
	echo "$USERNAME ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

	chown -R $USERNAME:$USERNAME aur
	chown -R $USERNAME:$USERNAME src

	su -c $0 $USERNAME

	rm /etc/sudoers.d/$USERNAME

	userdel -r $USERNAME

	exit 0
fi

if test -n "${AUR_PACKAGES}"
then
	cd aur

	for AUR_PACKAGE in ${AUR_PACKAGES}
	do
		if ! test -d ${AUR_PACKAGE}
		then
			git clone https://aur.archlinux.org/${AUR_PACKAGE}.git
		fi

		cd ${AUR_PACKAGE}

		export SRCDEST=$(pwd)/../../src/${AUR_PACKAGE}

		mkdir -p $SRCDEST

		makepkg -srci --skippgpcheck --noconfirm

		find $SRCDEST -mindepth 1 -maxdepth 1 -name '* *' -exec rm -Rfv {} \;
		(
			find $SRCDEST -mindepth 1 -maxdepth 1
			makepkg --nobuild --skippgpcheck --verifysource 2>&1 | grep -F ' ... ' | grep -E ' Passed$' | awk "{print \"$SRCDEST/\"\$1}"
		) | sort | uniq -u | xargs rm -Rfv

		cd ..
	done
fi
