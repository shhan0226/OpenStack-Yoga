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
# auth
##################################
source ../set.conf
echo "... set!!"
##################################
# Finalize installation
##################################


# Controller node에서 아래 복사 :
# scp /etc/swift/*.gz vraptor@192.168.2.54:/home/vraptor

# Storage node에서 아래 실행 :



## Controller node :
# /etc/swift/internal-client.conf
#curl -o /etc/swift/internal-client.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/internal-client.conf-sample






#. ../admin-openrc
#swift stat



echo "SWIFT FINAL INSTALLED ... END"