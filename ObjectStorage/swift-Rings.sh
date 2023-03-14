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
# Rings
##################################
## Controller node:
# account
swift-ring-builder /etc/swift/account.builder create 10 1 1
swift-ring-builder /etc/swift/account.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6202 --device sdb --weight 100 
swift-ring-builder /etc/swift/account.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6202 --device sdc --weight 100
swift-ring-builder /etc/swift/account.builder
swift-ring-builder /etc/swift/account.builder rebalance
# container
swift-ring-builder /etc/swift/container.builder create 10 1 1
swift-ring-builder /etc/swift/container.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6201 --device sdb --weight 100
swift-ring-builder /etc/swift/container.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6201 --device sdc --weight 100
swift-ring-builder /etc/swift/container.builder
swift-ring-builder /etc/swift/container.builder rebalance
# object
swift-ring-builder /etc/swift/object.builder create 10 1 1
swift-ring-builder /etc/swift/object.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6200 --device sdb --weight 100
swift-ring-builder /etc/swift/object.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6200 --device sdc --weight 100
swift-ring-builder /etc/swift/object.builder
swift-ring-builder /etc/swift/object.builder rebalance



##################################
# Finalize installation
##################################

## Controller node:
# /etc/swift/internal-client.conf
curl -o /etc/swift/internal-client.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/internal-client.conf-sample
# /etc/swift/swift.conf
curl -o /etc/swift/swift.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/swift.conf-sample
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_suffix hash_swift_
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_prefix hash_swift_
chown -R root:swift /etc/swift
service memcached restart
service swift-proxy restart
# scp /etc/swift/swift.conf {스토리지 노드}:/etc/swift
# chown -R root:swift /etc/swift

#swift-init all restart
. ../admin-openrc
swift stat
echo "SWIFT STORAGE INSTALLED ... END"