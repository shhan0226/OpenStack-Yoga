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
# Swift-Storage
##################################
echo "Swift Storage!!"

# Prerequisites
apt-get install -y xfsprogs rsync swift swift-account swift-container swift-object xfsprogs -y
 
# Format Disk
lsblk
read -p "Input no.1 /dev/sdX? {sdb|sdc|ENTER=sdb} :" SD1_
SD1_=${SD1_:-sdb}
echo ${SD1_}
read -p "Input no.2 /dev/sdX? {sdb|sdc|ENTER=sdc} :" SD2_
SD2_=${SD2_:-sdc}
echo ${SD2_}
mkfs.xfs /dev/${SD1_}
mkfs.xfs /dev/${SD2_}
mkdir -p /srv/node/${SD1_}
mkdir -p /srv/node/${SD2_}
SDB_=$(blkid | awk '{ if($1=="/dev/sdb:") print $2}')
SDC_=$(blkid | awk '{ if($1=="/dev/sdc:") print $2}')
echo "${SDB_} /srv/node/sdb xfs noatime 0 2" >> /etc/fstab
echo "${SDC_} /srv/node/sdc xfs noatime 0 2" >> /etc/fstab
mount /srv/node/${SD1_}
mount /srv/node/${SD2_}
chown -R swift. /srv/node
lsblk

##################################
# server config
##################################
sudo mv /home/vraptor/* /etc/swift/
chown swift. /etc/swift/*.gz
sudo mv /home/vraptor/swift.conf /etc/swift/
chown swift. /etc/swift/swift.conf

# /etc/swift/internal-client.conf
#curl -o /etc/swift/internal-client.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/internal-client.conf-sample
curl -o /etc/swift/internal-client.conf https://opendev.org/openstack/swift/raw/branch/master/etc/internal-client.conf-sample

#curl -o /etc/swift/account-server.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/account-server.conf-sample
#curl -o /etc/swift/container-server.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/container-server.conf-sample
#curl -o /etc/swift/object-server.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/object-server.conf-sample

curl -o /etc/swift/account-server.conf https://opendev.org/openstack/swift/raw/branch/master/etc/account-server.conf-sample
curl -o /etc/swift/container-server.conf https://opendev.org/openstack/swift/raw/branch/master/etc/container-server.conf-sample
curl -o /etc/swift/object-server.conf https://opendev.org/openstack/swift/raw/branch/master/etc/object-server.conf-sample

##/etc/swift/account-server.conf
# 추가
crudini --set /etc/swift/account-server.conf DEFAULT bind_ip 0.0.0.0
#crudini --set /etc/swift/account-server.conf DEFAULT bind_port 6002

#crudini --set /etc/swift/account-server.conf DEFAULT bind_ip ${SET_IP}
crudini --set /etc/swift/account-server.conf DEFAULT bind_port 6202
crudini --set /etc/swift/account-server.conf DEFAULT user swift
crudini --set /etc/swift/account-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/account-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/account-server.conf DEFAULT mount_check True
crudini --set /etc/swift/account-server.conf pipeline:main pipeline "healthcheck recon account-server"
crudini --set /etc/swift/account-server.conf filter:recon use egg:swift#recon
crudini --set /etc/swift/account-server.conf filter:recon recon_cache_path /var/cache/swift

## /etc/swift/container-server.conf
# 추가
crudini --set /etc/swift/container-server.conf DEFAULT bind_ip 0.0.0.0
#crudini --set /etc/swift/container-server.conf DEFAULT bind_port 6001

#crudini --set /etc/swift/container-server.conf DEFAULT bind_ip ${SET_IP}
crudini --set /etc/swift/container-server.conf DEFAULT bind_port 6201
crudini --set /etc/swift/container-server.conf DEFAULT user swift
crudini --set /etc/swift/container-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/container-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/container-server.conf DEFAULT mount_check True
crudini --set /etc/swift/container-server.conf pipeline:main pipeline "healthcheck recon container-server"
crudini --set /etc/swift/container-server.conf filter:recon use egg:swift#recon
crudini --set /etc/swift/container-server.conf filter:recon recon_cache_path /var/cache/swift

## /etc/swift/object-server.conf
# 추가
crudini --set /etc/swift/object-server.conf DEFAULT bind_ip 0.0.0.0
#crudini --set /etc/swift/object-server.conf DEFAULT bind_port 6000

#crudini --set /etc/swift/object-server.conf DEFAULT bind_ip ${SET_IP}
crudini --set /etc/swift/object-server.conf DEFAULT bind_port 6200
crudini --set /etc/swift/object-server.conf DEFAULT user swift
crudini --set /etc/swift/object-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/object-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/object-server.conf DEFAULT mount_check True
crudini --set /etc/swift/object-server.conf pipeline:main pipeline "healthcheck recon object-server"
crudini --set /etc/swift/object-server.conf filter:recon use egg:swift#recon
crudini --set /etc/swift/object-server.conf filter:recon recon_cache_path /var/cache/swift
crudini --set /etc/swift/object-server.conf filter:recon recon_lock_path /var/lock


##################################
# rsync
##################################
curl -o /etc/rsyncd.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/rsyncd.conf-sample

crudini --set /etc/rsyncd.conf "" uid swift
crudini --set /etc/rsyncd.conf "" gid swift
crudini --set /etc/rsyncd.conf "" "log file" /var/log/rsyncd.log
crudini --set /etc/rsyncd.conf "" "pid file" /var/run/rsyncd.pid
crudini --set /etc/rsyncd.conf "" address ${SET_IP}

## account
crudini --set /etc/rsyncd.conf account "max connections" 25
crudini --set /etc/rsyncd.conf account path /srv/node/
crudini --set /etc/rsyncd.conf account "read only" false
crudini --set /etc/rsyncd.conf account "lock file" /var/lock/account.lock
# 추가
#crudini --set /etc/rsyncd.conf account "write only" no
#crudini --set /etc/rsyncd.conf account list yes
#crudini --set /etc/rsyncd.conf account incoming chmod  = 0644
#crudini --set /etc/rsyncd.conf account outgoing chmod  = 0644

## container
crudini --set /etc/rsyncd.conf container "max connections" 25
crudini --set /etc/rsyncd.conf container path /srv/node/
crudini --set /etc/rsyncd.conf container "read only" false
crudini --set /etc/rsyncd.conf container "lock file" /var/lock/account.lock
# 추가
#crudini --set /etc/rsyncd.conf container "write only" no
#crudini --set /etc/rsyncd.conf container list yes
#crudini --set /etc/rsyncd.conf container incoming chmod  = 0644
#crudini --set /etc/rsyncd.conf container outgoing chmod  = 0644

## object
crudini --set /etc/rsyncd.conf object "max connections" 25
crudini --set /etc/rsyncd.conf object path /srv/node/
crudini --set /etc/rsyncd.conf object "read only" false
crudini --set /etc/rsyncd.conf object "lock file" /var/lock/account.lock
# 추가
#crudini --set /etc/rsyncd.conf object "write only" no
#crudini --set /etc/rsyncd.conf object list yes
#crudini --set /etc/rsyncd.conf object incoming chmod  = 0644
#crudini --set /etc/rsyncd.conf object outgoing chmod  = 0644

# 추가
## swift_server
#crudini --set /etc/rsyncd.conf swift_server path /etc/swift
#crudini --set /etc/rsyncd.conf swift_server "read only" true
#crudini --set /etc/rsyncd.conf swift_server "write only" no
#crudini --set /etc/rsyncd.conf swift_server list yes
#crudini --set /etc/rsyncd.conf swift_server "incoming chmod" 0644
#crudini --set /etc/rsyncd.conf swift_server "outgoing chmod" 0644
#crudini --set /etc/rsyncd.conf swift_server "max connections" 25
#crudini --set /etc/rsyncd.conf swift_server "lock file" /var/lock/account.lock

# /etc/default/rsync
crudini --set /etc/default/rsync "" RSYNC_ENABLE true
service rsync start

###############
#end
###############

# ownership
chown -R swift:swift /srv/node
# recon
mkdir -p /var/cache/swift
chown -R root:swift /var/cache/swift
chmod -R 775 /var/cache/swift

# Storage node에서 아래 실행 :
swift-init all restart

# systemctl enable rsync swift-account-auditor \
# swift-account-replicator \
# swift-account \
# swift-container-auditor \
# swift-container-replicator \
# swift-container-updater \
# swift-container \
# swift-object-auditor \
# swift-object-replicator \
# swift-object-updater \
# swift-object

# systemctl restart rsync swift-account-auditor \
# swift-account-replicator \
# swift-account \
# swift-container-auditor \
# swift-container-replicator \
# swift-container-updater \
# swift-container \
# swift-object-auditor \
# swift-object-replicator \
# swift-object-updater \
# swift-object


echo "SWIFT STORAGE INSTALLED ... END"