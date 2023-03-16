#!/bin/bash

##################################
# Change root privileges.
##################################
IAMACCOUNT=$(whoami)
echo "${IAMACCOUNT}"
if [ "$IAMACCOUNT" = "root" ]; then
    echo "It's root account."
else
    echo "It's not a root account."
	exit 100
fi

##################################
# Finalize installation
##################################
. ../admin-openrc
service memcached restart
service swift-proxy restart
swift stat

echo "SWIFT FINAL INSTALLED ... END"