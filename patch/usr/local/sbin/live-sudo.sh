#!/bin/bash

if test -x /usr/bin/sudo
then
	groupadd -f adm
	echo '%adm ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/adm
fi

exit 0
