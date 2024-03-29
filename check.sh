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
sync
FILE_PATH="./admin-openrc"
if [ ! -f "$FILE_PATH" ]; then
  echo "The "admin-openrc" file does not exist.: $FILE_PATH"
  exit 1
fi

. admin-openrc

##################################
# nova check
##################################
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
openstack endpoint list
openstack catalog list
openstack catalog show object-store
openstack volume service list
openstack image list


