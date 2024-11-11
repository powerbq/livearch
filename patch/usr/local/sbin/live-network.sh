#!/bin/bash

if test -f /usr/lib/systemd/system/NetworkManager.service
then
	systemctl enable NetworkManager
else
	systemctl enable systemd-networkd
	systemctl enable systemd-resolved

	rm -f /etc/resolv.conf
	ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
fi

exit 0
