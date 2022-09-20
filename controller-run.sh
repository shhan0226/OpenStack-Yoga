#!/bin/bash

echo "Install Controller for OpenStack ..."

# Inpute Value
CONTROLLER_HOSTv="controller"
COMPUTE_HOSTv="compute1"
SET_IPv="192.168.1.5"
SET_IP2v="192.168.1.6"
SET_IP_ALLOWv="192.168.0.0/22"
INTERFACE_NAME_v="eth0|enP6p1s0|br-provider"
STACK_PASSWDv="stack"

read -p "Do you want to input ?? {yes|no|ENTER=no}" CHECKER_O_
if [ "$CHECKER_O_" = "yes" ]; then
    read -p "Input CONTROLLER HOSTNAME: " CONTROLLER_HOSTv
    read -p "Input COMPUTE HOSTNAME: " CONTROLLER_HOSTv
    read -p "Input Contorller IP: (ex.192.168.0.2) " SET_IPv
    read -p "Input Compute1 IP: (ex.192.168.0.3) " SET_IP2v
    read -p "Input the allow IP (ex 192.168.0.0/24): " SET_IP_ALLOWv
    read -p "Input INTERFACE_NAME: " INTERFACE_NAME_v
    read -p "Input STACK_PASSWD: " STACK_PASSWDv
    export CONTROLLER_HOST=$CONTROLLER_HOSTv
    export COMPUTE_HOST=$COMPUTE_HOSTv
    export SET_IP=$SET_IPv
    export SET_IP2=$SET_IP2v
    export SET_IP_ALLOW=$SET_IP_ALLOWv
    export INTERFACE_NAME_=$INTERFACE_NAME_v
    export STACK_PASSWD=$STACK_PASSWDv
else
    export CONTROLLER_HOST=$CONTROLLER_HOSTv
    export COMPUTE_HOST=$COMPUTE_HOSTv
    export SET_IP=$SET_IPv
    export SET_IP2=$SET_IP2v
    export SET_IP_ALLOW=$SET_IP_ALLOWv
    export INTERFACE_NAME_=$INTERFACE_NAME_v
    export STACK_PASSWD=$STACK_PASSWDv
fi

# INPUT DATA PRINT
echo "$CONTROLLER_HOST"
echo "$COMPUTE_HOST"
echo "$SET_IP"
echo "$SET_IP2"
echo "$SET_IP_ALLOW"
echo "$INTERFACE_NAME_"
echo "$STACK_PASSWD"
echo "... set!!"

# INSTALL START
echo "1. Install Controller Setting ..."
source ./Contorller/controller-setting.sh
echo "2. Install Keystone ..."
source ./Contorller/keystone.sh
echo "3. Install Glance ..."
source ./Contorller/glance.sh
echo "4. Install Placement ..."
source ./Contorller/placement.sh
echo "5. Install Nova ..."
source ./Contorller/nova.sh
echo "Compelete, Nova!!"
read -p "Is Compute Node installed? {yes|no|ENTER=yes} :" CHECKER_Node
if [ "$CHECKER_Node" = "no" ]; then
    echo "6. No Check Compute Node!!"
else
    echo "6. Check Compute Node!!"
    source ./Contorller/nova_check.sh    
fi
echo "7. Install Neutron ..."
read -p "Is OVS installed? {yes|no|ENTER=no} :" CHECKER_OVS
if [ "$CHECKER_OVS" = "yes" ]; then
    echo "OVS-Neutorn!!"
    source ./Contorller/neutron-ovs.sh
else
    echo "Neutorn!!"
    source ./Contorller/neutron.sh
fi
echo "8. Install Horizon ..."
source ./Contorller/horizon.sh


echo "9. Floating IP port forwarding..."
read -p "SET PORT FORWARDING? {yes|no|ENTER=no} :" CHECKER_FORWARDING
if [ "$CHECKER_FORWARDING" = "yes" ]; then
		source ./Contorller/floating_ip_port_forwarding.sh
else
		echo "Done..."
fi
