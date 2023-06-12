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
# create instance
##################################
sync
source admin-openrc
read -p "INPUT INSTANCE NAME? :" NAME_INST
openstack server create --image ubuntu2004 --flavor flavor1 --key-name arm-key --network internal --user-data init.sh --security-group arm-secu ${NAME_INSTANCE}
##################################
# add floating IP
##################################
sync
source admin-openrc
. demo-openrc
openstack floating ip create external
openstack floating ip list --fit-width
read -p "INPUT IP SET? :" INPUT_IP
openstack server add floating ip ${NAME_INSTANCE} ${INPUT_IP}
openstack floating ip list