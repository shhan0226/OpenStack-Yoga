
##################################
# Finalize installation
##################################

## Controller node:
# /etc/swift/internal-client.conf
curl -o /etc/swift/internal-client.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/internal-client.conf-sample

# /etc/swift/swift.conf
curl -o /etc/swift/swift.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/swift.conf-sample
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_suffix hash_suf_
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_prefix hash_prf_
chown -R root:swift /etc/swift
service memcached restart
service swift-proxy restart
# scp /etc/swift/swift.conf {스토리지 노드}:/etc/swift
# chown -R root:swift /etc/swift

#swift-init all restart
. ../admin-openrc
swift stat
echo "SWIFT STORAGE INSTALLED ... END"