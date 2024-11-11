#!/bin/bash

set -e

pacman -Syu --noconfirm --needed pacman-contrib squashfs-tools sudo

time ./mirror.sh

time ./custom.sh
time ./packages.sh

time ./boot.sh
time ./save.sh

time ./cleanup.sh
