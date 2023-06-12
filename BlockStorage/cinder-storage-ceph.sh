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
# auth
##################################
source ../set.conf
echo "... set!!"

##################################
# Format Disk
##################################
apt install lvm2 thin-provisioning-tools

#fdisk -l
#read -p "Inpute the sdX ?? {sdb|sdc|ENTER=sdb} :" SDX_
#SDX_=${SDX_:-sdb}
#echo ${SDX_}
lsblk

# fdisk setting
#fdisk /dev/${SDX_} <<EOF
#n
#p
#1


#t
#8e
#w
#EOF


# creative LVM
#pvcreate /dev/${SDX_}1
#pvdisplay
#vgcreate cinder-volumes /dev/${SDX_}1
#vgdisplay
#partprobe -s
#partprobe /dev/${SDX_}1    
#lsblk

# lvm.conf
#sed -i'' -r -e "/devices \{/a\        filter = [ \"a/${SDX_}/\", \"r/.*/\"]" /etc/lvm/lvm.conf


##################################
# Cinder-Storage
##################################
echo "Cinder Storage!!"

# 패키지 설치
apt install -y cinder-volume tgt

# 설정
#crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:${STACK_PASSWD}@${SET_IP}/cinder
#crudini --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:${STACK_PASSWD}@${SET_IP}
#crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
#crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://${SET_IP}:5000
#crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://${SET_IP}:5000
#crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers ${SET_IP}:11211
#crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
#crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
#crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
#crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
#crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
#crudini --set /etc/cinder/cinder.conf keystone_authtoken password ${STACK_PASSWD}
#crudini --set /etc/cinder/cinder.conf DEFAULT my_ip ${SET_IP2}
#crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
#crudini --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes
#crudini --set /etc/cinder/cinder.conf lvm target_protocol iscsi
#crudini --set /etc/cinder/cinder.conf lvm target_helper tgtadm
#crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm
#crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://${SET_IP}:9292
#crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

sudo crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends ceph
sudo crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_version 2
sudo crudini --set /etc/cinder/cinder.conf ceph volume_driver cinder.volume.drivers.rbd.RBDDriver
sudo crudini --set /etc/cinder/cinder.conf ceph volume_backend_name ceph
sudo crudini --set /etc/cinder/cinder.conf ceph rbd_pool volumes
sudo crudini --set /etc/cinder/cinder.conf ceph rbd_user cinder
sudo crudini --set /etc/cinder/cinder.conf ceph rbd_ceph_conf /etc/ceph/ceph.conf
sudo crudini --set /etc/cinder/cinder.conf ceph rbd_flatten_volume_from_snapshot false
sudo crudini --set /etc/cinder/cinder.conf ceph rbd_max_clone_depth 5
sudo crudini --set /etc/cinder/cinder.conf ceph rbd_store_chunk_size 4
sudo crudini --set /etc/cinder/cinder.conf ceph rados_connect_timeout -1

##################
# Verify Cinder operation
##################
service tgt restart
service cinder-volume restart
sudo systemctl restart cinder-scheduler cinder-volume

##################
# backup service
##################
#apt install cinder-backup
#crudini --set /etc/cinder/cinder.conf DEFAULT backup_driver cinder.backup.drivers.swift.SwiftBackupDriver
#crudini --set /etc/cinder/cinder.conf DEFAULT backup_swift_url http://${SET_IP}:8080/v1/AUTH_
#systemctl restart iscsid
#echo 'include /var/lib/cinder/volumes/*' >> /etc/tgt/conf.d/cinder.conf
#service cinder-backup restart
#service cinder-volume restart
lsblk

echo "CINDER STORAGE INSTALLED ... END"
