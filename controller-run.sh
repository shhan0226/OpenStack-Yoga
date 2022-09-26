#!/bin/bash

echo "Install Controller for OpenStack ..."
# INPUT DATA PRINT
source set.conf
echo "... set!!"
# INSTALL START
echo "1. Install Controller Setting ..."
source ./Controller/controller-setting.sh
sh ./fix.sh
echo "2. Install Keystone ..."
source ./Controller/keystone.sh
echo "3. Install Glance ..."
source ./Controller/glance.sh
echo "4. Install Placement ..."
source ./Controller/placement.sh
echo "5. Install Nova ..."
source ./Controller/nova.sh
echo "6. Check Compute Node ..."
source ./Controller/nova_check.sh
echo "7. Install Neutron ..."
#read -p "Is OVS installed? {yes|no|ENTER=no} :" CHECKER_OVS
echo "Is OVS installed? $CHECKER_OVS "
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
        echo "FORWARDING INSTALLED ... END"
else
		echo "FORWARDING NO CONFIG ... END"
fi
echo "CONTROLLER ... THE END"