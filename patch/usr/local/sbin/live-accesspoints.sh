#!/bin/bash

if test -f /usr/lib/systemd/system/NetworkManager.service && ! test "${NETWORK_SYSTEMD}" = yes
then
	IFS=$'\n'
	for LINE in $(cat /usr/local/etc/accesspoints)
	do
		SSID=$(echo $LINE | awk '{print $1}')
		PASS=$(echo $LINE | awk '{print $2}')
		UUID=$(uuidgen)

		cat > /etc/NetworkManager/system-connections/$SSID.nmconnection << EOF
[connection]
id=$SSID
uuid=$UUID
type=wifi

[wifi]
ssid=$SSID

[wifi-security]
key-mgmt=wpa-psk
psk=$PASS

[ipv4]
method=auto

[ipv6]
method=ignore

EOF
	done

	find /etc/NetworkManager/system-connections -type f -exec chmod 600 {} \;
fi

exit 0
