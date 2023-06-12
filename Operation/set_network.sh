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
# . admin-openrc
##################################
cp /root/OpenStack-Yoga/admin-openrc .
source admin-openrc
##################################
# img dowonload
##################################
read -p "Do you want to img file? {yes|no|ENTER=no} :" IMG_FILE_CHECK
if [ "$IMG_FILE_CHECK" = "yes" ]; then
    echo "Focal IMG Download ..."
    wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-arm64.img
    openstack image create "ubuntu2004" --file ./focal-server-cloudimg-arm64.img --disk-format qcow2 --public    
    openstack image show ubuntu2004 --fit-width
else
    echo "NO DOWNLOAD FILE ... END"
fi
##################################
# Flavor
##################################
sync
source admin-openrc
openstack flavor create --vcpus 1 --ram 2048 --disk 4 flavor1
openstack flavor list
##################################
# External NetWork
##################################
sync
source admin-openrc
openstack network create --external --provider-network-type flat --provider-physical-network provider external
openstack subnet create --subnet-range 192.168.0.0/22 --no-dhcp --gateway 192.168.0.1 --network external --dns-nameserver 8.8.8.8 --allocation-pool start=192.168.0.50,end=192.168.0.150 external-subnet
##################################
# Internal NetWork
##################################
sync
source admin-openrc
openstack network create internal
openstack subnet create --subnet-range 172.16.0.0/24 --dhcp --network internal --dns-nameserver 8.8.8.8 internal-subnet
##################################
# Router 
##################################
sync
source admin-openrc
openstack router create arm-router
openstack router add subnet arm-router internal-subnet
openstack router set --external-gateway external arm-router
openstack router list --fit-width
##################################
# Keypair 
##################################
sync
source admin-openrc
openstack keypair create arm-key > arm-key.pem
openstack keypair list --fit-width
chmod 400 arm-key.pem
##################################
# security 
##################################
sync
source admin-openrc
openstack security group create arm-secu
openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 22 --protocol tcp --ingress arm-secu
openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 80 --protocol tcp --ingress arm-secu
openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 8080 --protocol tcp --ingress arm-secu
openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 3306 --protocol tcp --ingress arm-secu
openstack security group rule create --remote-ip 0.0.0.0/0 --protocol icmp --ingress arm-secu
openstack security group show arm-secu --fit-width
##################################
# cloud-init
##################################
sync
source admin-openrc
sync
cat << EOF >init.sh
#cloud-config
password: stack
chpasswd: { expire: False }
ssh_pwauth: True
EOF