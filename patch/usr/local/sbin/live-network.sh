#!/bin/bash

if test -f /usr/lib/systemd/system/NetworkManager.service && ! test "${NETWORK_SYSTEMD}" = yes
then
	systemctl enable NetworkManager
else
	pacman -Qs '^networkmanager$' > /dev/null && pacman -Rc --noconfirm networkmanager

	systemctl enable systemd-networkd
	systemctl enable systemd-resolved

	rm -f /etc/resolv.conf
	ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
fi

exit 0
