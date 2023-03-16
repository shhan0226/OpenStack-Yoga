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


echo "TEST CMD..."
echo "openstack container create test-container"
echo "openstack container list"
echo "touch testfile.txt"
echo "openstack object create test-container testfile.txt"
echo "openstack object list test-container"
echo "rm testfile.txt"
echo "ls"
echo "openstack object save test-container testfile.txt"
echo "ls"
echo "openstack object delete test-container testfile.txt"
echo "openstack object list test-container"
echo "openstack container delete test-container"
echo "openstack container list"

echo "SWIFT FINAL INSTALLED ... END"