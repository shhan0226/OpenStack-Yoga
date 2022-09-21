#!/bin/bash

echo "Install Compute for OpenStack ..."

# INPUT DATA PRINT
source set.conf
echo "... set!!"

# INSTALL START
echo "1. Install Compute Setting ..."
source ./Compute/compute_setting.sh

read -p "Are you going to install Nova? {yes|no|ENTER=yes} :" CHECKER_Node
if [ "$CHECKER_Node" = "no" ]; then
    echo "Please Install Contoller Node (Nova)"
    exit 100
else
    echo "2. Install Nova ..."
    source ./Compute/nova_compute.sh
fi

read -p "Are you going to install Neutron? {yes|no|ENTER=yes} :" CHECKER_Node
if [ "$CHECKER_Node" = "no" ]; then
    echo "Please Install Contoller Node (Neutron)"
    exit 100
else
    echo "3. Install Neutron ..."
    read -p "Is OVS installed? {yes|no|ENTER=no} :" CHECKER_OVS
    if [ "$CHECKER_OVS" = "yes" ]; then
        echo "OVS-Neutorn!!"
        source ./Compute/neutron-compute-ovs.sh
    else
        echo "Neutorn!!"
        source ./Compute/neutron-compute.sh        
    fi
fi

echo "END."