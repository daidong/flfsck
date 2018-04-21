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

#For resolving Conflict with lustre-client-2.9.0-1.el7.x86_64 error
# rpm -qa|grep ‘client’
rpm -e lustre-client-2.9.0-1.el7.x86_64
yum -y localinstall {kmod-lustre-osd-ldiskfs,kmod-lustre,lustre,lustre-osd-ldiskfs-mount,lustre-iokit,lustre-tests,kmod-lustre-tests}-2.9.0-1.el7.centos.x86_64.rpm
echo 'options lnet networks=tcp0(p2p2)' > /etc/modprobe.d/lustre.conf
depmod -a
modprobe lustre
lctl set_param debug=+lfsck
lctl set_param printk=+lfsck


rpm -e kmod-lustre-osd-ldiskfs-2.9.0-1.el7.centos.x86_64 lustre-osd-ldiskfs-mount-2.9.0-1.el7.centos.x86_64 kmod-lustre-2.9.0-1.el7.centos.x86_64 kmod-lustre-tests-2.9.0-1.el7.centos.x86_64 lustre-2.9.0-1.el7.centos.x86_64 lustre-tests-2.9.0-1.el7.centos.x86_64 lustre-iokit-2.9.0-1.el7.centos.x86_64
