#!/bin/bash

if test -f /usr/lib/systemd/system/sshd.service && test "${ENABLE_SSH}" = yes
then
	systemctl enable sshd
fi

exit 0
