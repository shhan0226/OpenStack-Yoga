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
# INPUT DATA PRINT
##################################
source /root/OpenStack-Yoga/set.conf
echo "... set!!"

##################################
# admin check
##################################
cat > admin-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=stack
export OS_AUTH_URL=http://${SET_IP}:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

##################################
# nova check
##################################
sync
openstack compute service list --service nova-compute
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
crudini --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 300
# NOVA Verify operation
. admin-openrc
openstack compute service list
nova-status upgrade check

##################################
# service check
##################################
. admin-openrc
openstack user list
openstack service list
openstack catalog list
openstack endpoint list
#openstack image list


