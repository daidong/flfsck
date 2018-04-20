#!/bin/sh
cd ~/lustre-release/
./configure
make rpms

# Edit /etc/yum.conf and change the value of gpgcheck from 1 to 0.
cat << EOF >> /etc/yum.repos.d/e2fsprogs.repo
[e2fsprogs-el7-x86_64]
name=e2fsprogs-el7-x86_64
baseurl=https://downloads.hpdd.intel.com/public/e2fsprogs/latest/el7/
enabled=1
priority=1
EOF
yum update -y e2fsprogs


yum -y localinstall {kmod-lustre-osd-ldiskfs,kmod-lustre,lustre,lustre-osd-ldiskfs-mount,lustre-iokit,lustre-tests,kmod-lustre-tests}-2.9.0_dirty-1.el7.centos.x86_64.rpm

#For resolving Conflict with lustre-client-2.9.0-1.el7.x86_64 error
# rpm -qa|grep ‘client’
# rpm -e lustre-client-2.9.0-1.el7.x86_64
