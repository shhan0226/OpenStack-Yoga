#!/bin/bash

echo "Install Controller for OpenStack ..."

# INPUT DATA PRINT
source set.conf
echo "$CONTROLLER_HOST"
echo "$COMPUTE_HOST"
echo "$SET_IP"
echo "$SET_IP2"
echo "$SET_IP_ALLOW"
echo "$INTERFACE_NAME_"
echo "$STACK_PASSWD"
echo "$CPU_ARCH"
echo "... set!!"

# INSTALL START
echo "1. Install Controller Setting ..."
source ./Controller/controller-setting.sh

echo "2. Install Keystone ..."
source ./Controller/keystone.sh

echo "3. Install Glance ..."
source ./Controller/glance.sh

echo "4. Install Placement ..."
source ./Controller/placement.sh

echo "5. Install Nova ..."
source ./Controller/nova.sh

read -p "Is Compute Node installed? {yes|no|ENTER=yes} :" CHECKER_Node
if [ "$CHECKER_Node" = "no" ]; then
    echo "6. No Check Compute Node!!"
else
    echo "6. Check Compute Node!!"
    source ./Controller/nova_check.sh    
fi

echo "7. Install Neutron ..."
read -p "Is OVS installed? {yes|no|ENTER=no} :" CHECKER_OVS
if [ "$CHECKER_OVS" = "yes" ]; then
    echo "OVS-Neutorn!!"
    source ./Controller/neutron-ovs.sh
else
    echo "Neutorn!!"
    source ./Controller/neutron.sh
fi

echo "8. Install Horizon ..."
source ./Controller/horizon.sh

echo "9. Floating IP port forwarding..."
read -p "SET PORT FORWARDING? {yes|no|ENTER=no} :" CHECKER_FORWARDING
if [ "$CHECKER_FORWARDING" = "yes" ]; then
        echo "FORWARDING..."
		source ./Controller/floating_ip_port_forwarding.sh
else
		echo "Done..."
fi
