#!/bin/bash

set -e

cd $(dirname $0)

time ./packages.sh
time ./unpack.sh
time ./save.sh

time ./cleanup.sh / $(pwd)/root

time find root -mindepth 1 -maxdepth 1 -exec rm -Rf {} \;
