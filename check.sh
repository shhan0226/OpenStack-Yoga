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
# admin check
##################################
FILE_PATH="./admin-openrc"
if [ ! -f "$FILE_PATH" ]; then
  echo "admin-openrc 파일이 존재하지 않습니다: $FILE_PATH"
  exit 1
fi

echo "admin-openrc 파일이 존재합니다: $FILE_PATH"
. admin-openrc

##################################
# nova check
##################################
sync
. admin-openrc
openstack compute service list --service nova-compute
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
crudini --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 300
openstack compute service list
nova-status upgrade check

##################################
# service check
##################################

openstack user list
openstack service list
openstack catalog list
openstack endpoint list
#openstack image list


