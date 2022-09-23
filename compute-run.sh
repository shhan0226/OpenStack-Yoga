#!/bin/bash

echo "Install Compute for OpenStack ..."
# INPUT DATA PRINT
source set.conf
echo "... set!!"
# INSTALL START
echo "1. Install Compute Setting ..."
source ./Compute/compute_setting.sh
echo "2. Install Nova Compute ..."
source ./Compute/nova_compute.sh
echo "3. Install Neutron ..."
read -p "Is OVS installed? {yes|no|ENTER=no} :" CHECKER_OVS
if [ "$CHECKER_OVS" = "yes" ]; then
    echo "OVS-Neutorn!!"
    source ./Compute/neutron-compute-ovs.sh
else
    echo "Neutorn!!"
    source ./Compute/neutron-compute.sh        
fi
echo "... THE END"