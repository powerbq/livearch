#!/bin/bash

if test -x /usr/bin/sudo
then
	echo "$USERNAME ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
fi

exit 0
