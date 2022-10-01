#!/bin/bash

create-user.sh $USERNAME $USERID yes

if test -z "${HASHED_PASSWORD}"
then
	echo "$USERNAME:$PASSWORD" | chpasswd
	echo "root:$PASSWORD" | chpasswd
else
	echo "$USERNAME:${HASHED_PASSWORD}" | chpasswd -e
	echo "root:${HASHED_PASSWORD}" | chpasswd -e
fi

exit 0
