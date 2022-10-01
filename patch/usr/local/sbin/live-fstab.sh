#!/bin/bash

cat /etc/fstab | grep -Pv '^(#|$)' | awk '{print $2}' | grep -P '^/.+' | xargs -r mkdir -p

exit 0
