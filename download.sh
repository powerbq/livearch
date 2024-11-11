#!/bin/sh

set -e

echo $0

BASEURL=https://mirrors.kernel.org/archlinux/iso
RELEASE=$(wget -q -O - $BASEURL | grep -Eo '"20.+"' | tr -d '"/' | tail -n1)
FILENAME=archlinux-bootstrap-$RELEASE-x86_64.tar.zst

test -f $FILENAME.sha256sum && sha256sum -c $FILENAME.sha256sum > /dev/null && echo 'Already up to date.' && exit 0

rm -f *.tar.gz *.tar.gz.sha256sum
wget -q -O $FILENAME $BASEURL/$RELEASE/$FILENAME
wget -q -O - $BASEURL/$RELEASE/sha256sums.txt | grep $FILENAME > $FILENAME.sha256sum
sha256sum -c $FILENAME.sha256sum > /dev/null

echo 'Done.' && exit 0
