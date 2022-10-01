#!/bin/bash

set -e

echo $0

cd $(dirname $0)

find out -mindepth 1 -maxdepth 1 -name 'archlinux_*.squashfs*' -exec rm {} \;

FILENAME=archlinux_${FILENAME_SUFFIX}.squashfs

mksquashfs root out/$FILENAME -no-xattrs -no-progress -b ${SQUASHFS_BLOCK_SIZE} -comp ${SQUASHFS_COMP} ${SQUASHFS_ADDITIONAL_OPTIONS}
cat out/$FILENAME | sha256sum | sed "s/-/$FILENAME/" > out/$FILENAME.sha256sum
