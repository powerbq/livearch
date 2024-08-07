#!/bin/bash

USERNAME=$1
USERID=$2
IS_ADMIN=$3

function present_groups() {
	for GROUP in $@
	do
		grep -o "^$GROUP:" /etc/group | tr -d ':'
	done
}

groupadd -g $USERID $USERNAME
useradd -u $USERID -g $USERID -G users -d /home/$USERNAME -s /bin/bash $USERNAME

if test "${IS_ADMIN}" = yes
then
	for GROUP in $(present_groups adm wheel audio disk floppy input kvm optical scanner storage video)
	do
		usermod -a -G $GROUP $USERNAME
	done
fi

mkdir -p /home/$USERNAME

cp -a --update=none /etc/skel/. /home/$USERNAME

chown -R $USERNAME:$USERNAME /home/$USERNAME

exit 0
