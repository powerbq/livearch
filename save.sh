#!/bin/bash

set -e

echo $0

find out -mindepth 1 -maxdepth 1 -name 'archlinux_*.squashfs*' -exec rm {} \;

FILENAME=archlinux_${FILENAME_SUFFIX}.squashfs

cd out

mksquashfs / $FILENAME -ef ../excludes.txt -wildcards -one-file-system -no-xattrs -no-progress -b ${SQUASHFS_BLOCK_SIZE} -comp ${SQUASHFS_COMP} ${SQUASHFS_ADDITIONAL_OPTIONS}
sha256sum $FILENAME > $FILENAME.sha256sum
