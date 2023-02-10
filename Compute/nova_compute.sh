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

# INPUT DATA PRINT
echo "$CONTROLLER_HOST"
echo "$COMPUTE_HOST"
echo "$SET_IP"
echo "$SET_IP2"
echo "$SET_IP_ALLOW"
echo "$INTERFACE_NAME_"
echo "$STACK_PASSWD"
echo "$CPU_ARCH"
echo "$OPENSTACK_VER"
echo "... set!!"


##################################
# Nova compute
##################################
echo "NOVA COMPUTE!!"
apt install nova-compute -y
crudini --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:${STACK_PASSWD}@${SET_IP}
crudini --set /etc/nova/nova.conf api auth_strategy keystone
crudini --set /etc/nova/nova.conf keystone_authtoken www_authenticate_uri http://${SET_IP}:5000/
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://${SET_IP}:5000/
crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers ${SET_IP}:11211
crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name Default
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name Default
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password ${STACK_PASSWD}
crudini --set /etc/nova/nova.conf DEFAULT my_ip ${SET_IP2}
crudini --set /etc/nova/nova.conf vnc enabled true
crudini --set /etc/nova/nova.conf vnc server_listen 0.0.0.0
crudini --set /etc/nova/nova.conf vnc server_proxyclient_address \$my_ip
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://${SET_IP}:6080/vnc_auto.html
crudini --set /etc/nova/nova.conf glance api_servers http://${SET_IP}:9292
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set /etc/nova/nova.conf placement region_name RegionOne
crudini --set /etc/nova/nova.conf placement project_domain_name Default
crudini --set /etc/nova/nova.conf placement project_name service
crudini --set /etc/nova/nova.conf placement auth_type password
crudini --set /etc/nova/nova.conf placement user_domain_name Default
crudini --set /etc/nova/nova.conf placement auth_url http://${SET_IP}:5000/v3
crudini --set /etc/nova/nova.conf placement username placement
crudini --set /etc/nova/nova.conf placement password ${STACK_PASSWD}
# Finalize installation
egrep -c '(vmx|svm)' /proc/cpuinfo
echo "libvirt ..."
echo "${CPU_ARCH}"
if [ "$CPU_ARCH" = "arm64" ]; then
    apt-get install qemu-kvm -y
    apt-get install libvirt-bin -y
    apt-get install virtinst -y
    apt-get install bridge-utils -y
    apt-get install cpu-checker -y
    apt-get install virt-manager -y 
    apt-get install qemu-efi -y
    sudo adduser $USER kvm
    service nova-compute restart
else
    crudini --set /etc/nova/nova-compute.conf libvirt virt_type qemu
    service nova-compute restart
fi

# Add the compute node to the cell database

# . admin-openrc
# openstack compute service list --service nova-compute
# su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

# discover_hosts
# crudini --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 300

echo "NOVA COMPUTE INSTALLED ... END"



