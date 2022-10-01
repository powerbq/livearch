#!/bin/bash

HEADLESS=$(cat /proc/cmdline | busybox xargs -rn1 | grep -P '^headless$')

if ! test -z "$HEADLESS"
then
	exit 0
fi

SESSION=$(test "$WAYLAND" = yes && test -d /usr/share/wayland-sessions && find /usr/share/wayland-sessions -maxdepth 1 -type f -name '*.desktop' -exec basename {} \; | tail -n 1 | sed 's/\.desktop$//')
if test -z "$SESSION"
then
	SESSION=$(test -d /usr/share/xsessions && find /usr/share/xsessions -maxdepth 1 -type f -name '*.desktop' -exec basename {} \; | tail -n 1 | sed 's/\.desktop$//')
fi

if test -f /usr/lib/systemd/system/lightdm.service
then
	systemctl enable lightdm

	cat > /etc/lightdm/lightdm.conf << EOF
[Seat:*]
session-wrapper=/etc/lightdm/Xsession
EOF

	if test "$AUTOLOGIN" = yes
	then
		groupadd --system autologin
		usermod -a -G autologin $USERNAME

		cat >> /etc/lightdm/lightdm.conf << EOF
autologin-user=$USERNAME
autologin-session=$SESSION
EOF
	fi
elif test -f /usr/lib/systemd/system/sddm.service
then
	systemctl enable sddm

	echo > /etc/sddm.conf

	mkdir -p /etc/sddm.conf.d

	if test "$WAYLAND" = yes
	then
		cat > /etc/sddm.conf.d/wayland.conf << EOF
[General]
DisplayServer=wayland
EOF
	fi

	if ! test "$AUTOLOGIN" = yes
	then
		XSESSION=
		USERNAME=
	fi

	cat > /etc/sddm.conf.d/kde_settings.conf << EOF
[Autologin]
Relogin=false
Session=$SESSION
User=$USERNAME

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=breeze

[Users]
MaximumUid=60513
MinimumUid=1000
EOF
fi

exit 0
