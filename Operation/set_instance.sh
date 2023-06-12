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
cp /root/OpenStack-Yoga/admin-openrc .
source admin-openrc
##################################
# create instance
##################################
sync
source admin-openrc
openstack image list
read -p "INPUT IMAGE NAME ? :" NAME_IMAGE
read -p "INPUT INSTANCE NAME ? :" NAME_INSTANCE
openstack server create --image ${NAME_IMAGE} --flavor flavor1 --key-name arm-key --network internal --user-data init.sh --security-group arm-secu ${NAME_INSTANCE}
##################################
# add floating IP
##################################
sync
source admin-openrc
openstack floating ip create external
openstack floating ip list --fit-width
read -p "INPUT IP SET? :" INPUT_IP
openstack server add floating ip ${NAME_INSTANCE} ${INPUT_IP}
openstack floating ip list

echo "[cirros]"
echo ">>  ssh -i arm-key.pem cirros@$INPUT_IP"
echo "[ubuntu]"
echo ">>  ssh -i arm-key.pem ubuntu@$INPUT_IP"