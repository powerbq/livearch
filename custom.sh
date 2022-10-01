#!/bin/bash

set -e

echo $0

cd $(dirname $0)

sudo pacman -Syu --noconfirm base-devel git

export PKGDEST=$(pwd)/opt/pkg-built

sudo mkdir -p $PKGDEST
sudo chown $(id -u):$(id -g) $PKGDEST

if test -d kernels
then
	sudo chown -R $(id -u):$(id -g) kernels
	cd kernels

	for PKGBASE in *
	do
		cd $PKGBASE

		tar -zxpf pkgroot.tar.gz
		rm -Rf pkgroot.tar.gz

		VMLINUZ=$(find boot -type f -maxdepth 1 -name 'vmlinuz-*' | tail -n 1)
		MODULES=$(find lib/modules -type d -mindepth 2 -maxdepth 2 -name kernel | tail -n 1 | xargs -r -n 1 dirname)

		echo $PKGBASE > $MODULES/pkgbase
		mv $VMLINUZ $MODULES/vmlinuz
		rm -Rf boot

		cat > PKGBUILD << EOF
pkgname=linux-$PKGBASE
pkgver=latest
pkgrel=1
arch=(x86_64)
depends=(coreutils initramfs kmod)
options=(!strip)

package() {
	mkdir ../pkg/linux-$PKGBASE/usr
	cp -a ../lib ../pkg/linux-$PKGBASE/usr/
}
EOF

		makepkg -cs --noconfirm

		cd ..
	done

	cd ..
fi

if test -n "${AUR_PACKAGES}"
then
	sudo chown -R $(id -u):$(id -g) aur
	cd aur

	for AUR_PACKAGE in ${AUR_PACKAGES}
	do
		if ! test -d ${AUR_PACKAGE}
		then
			git clone https://aur.archlinux.org/${AUR_PACKAGE}.git
		fi

		cd ${AUR_PACKAGE}

		makepkg -cis --skippgpcheck --noconfirm

		cd ..
	done
fi
