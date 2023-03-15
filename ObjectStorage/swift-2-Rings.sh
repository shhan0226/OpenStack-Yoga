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
swift-ring-builder /etc/swift/account.builder create 10 3 1
#swift-ring-builder /etc/swift/account.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6202 --device sdb --weight 100 
#swift-ring-builder /etc/swift/account.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6202 --device sdc --weight 100
swift-ring-builder /etc/swift/account.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6202 --device sdb --weight 100 
swift-ring-builder /etc/swift/account.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6202 --device sdc --weight 100 
swift-ring-builder /etc/swift/account.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6202 --device sdb --weight 100 
swift-ring-builder /etc/swift/account.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6202 --device sdc --weight 100 
swift-ring-builder /etc/swift/account.builder
swift-ring-builder /etc/swift/account.builder rebalance

# container
swift-ring-builder /etc/swift/container.builder create 10 3 1
#swift-ring-builder /etc/swift/container.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6201 --device sdb --weight 100
#swift-ring-builder /etc/swift/container.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6201 --device sdc --weight 100
swift-ring-builder /etc/swift/container.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6201 --device sdb --weight 100
swift-ring-builder /etc/swift/container.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6201 --device sdc --weight 100
swift-ring-builder /etc/swift/container.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6201 --device sdb --weight 100
swift-ring-builder /etc/swift/container.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6201 --device sdc --weight 100
swift-ring-builder /etc/swift/container.builder
swift-ring-builder /etc/swift/container.builder rebalance

# object
swift-ring-builder /etc/swift/object.builder create 10 3 1
#swift-ring-builder /etc/swift/object.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6200 --device sdb --weight 100
#swift-ring-builder /etc/swift/object.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6200 --device sdc --weight 100
swift-ring-builder /etc/swift/object.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6200 --device sdb --weight 100
swift-ring-builder /etc/swift/object.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6200 --device sdc --weight 100
swift-ring-builder /etc/swift/object.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6200 --device sdb --weight 100
swift-ring-builder /etc/swift/object.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6200 --device sdc --weight 100
swift-ring-builder /etc/swift/object.builder
swift-ring-builder /etc/swift/object.builder rebalance


chown swift. /etc/swift/*.gz
systemctl restart swift-proxy
service memcached restart
service swift-proxy restart

ls /etc/swift
echo "scp account.ring.gz, container.ring.gz, object.ring.gz"
echo "scp /etc/swift/*.gz 10.0.0.71:/etc/swift/"

echo "SWIFT RING INSTALLED ... END"
