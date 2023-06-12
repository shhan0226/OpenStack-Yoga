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
read -p "NAME_INST? {yes|no|ENTER=no} :" NAME_INST
openstack server create --image ubuntu2004 --flavor flavor1 --key-name arm-key --network internal --user-data init.sh --security-group arm-secu ${NAME_INST}
##################################
# add floating IP
##################################
sync
source admin-openrc
. demo-openrc
openstack floating ip create external
openstack floating ip list --fit-width
read -p "IF SET? {yes|no|ENTER=no} :" CHECKER_IF
if [ "$CHECKER_IF" = "yes" ]; then
  read -p "INPUT IF? :" INPUT_IF
  openstack server add floating ip ${NAME_INST} ${INPUT_IF}
else
  echo "IF no SET ..."
fi
openstack floating ip list