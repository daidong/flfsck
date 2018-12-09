#!/bin/sh
yum -y groupinstall "Development Tools"
cd ~
git clone https://github.com/daidong/flfsck.git
mv flfsck lustre-release
cd lustre-release
sh autogen.sh

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
cd ~/lustre-release/
yum -y localinstall {kmod-lustre-osd-ldiskfs,kmod-lustre,lustre,lustre-osd-ldiskfs-mount,lustre-iokit,lustre-tests,kmod-lustre-tests}-2.9.0-1.el7.centos.x86_64.rpm

echo 'options lnet networks=tcp0(eth0)' > /etc/modprobe.d/lustre.conf
depmod -a
modprobe lustre
lctl set_param debug=+lfsck
lctl set_param printk=+lfsck


rpm -e kmod-lustre-osd-ldiskfs-2.9.0-1.el7.centos.x86_64 lustre-osd-ldiskfs-mount-2.9.0-1.el7.centos.x86_64 kmod-lustre-2.9.0-1.el7.centos.x86_64 kmod-lustre-tests-2.9.0-1.el7.centos.x86_64 lustre-2.9.0-1.el7.centos.x86_64 lustre-tests-2.9.0-1.el7.centos.x86_64 lustre-iokit-2.9.0-1.el7.centos.x86_64

yum remove kmod-lustre kmod-lustre-osd-ldiskfs kmod-lustre-tests lustre lustre-iokit lustre-osd-ldiskfs-mount lustre-tests

Installing:
 kmod-lustre                    x86_64       2.9.0-1.el7.centos         /kmod-lustre-2.9.0-1.el7.centos.x86_64                     20 M
 kmod-lustre-osd-ldiskfs        x86_64       2.9.0-1.el7.centos         /kmod-lustre-osd-ldiskfs-2.9.0-1.el7.centos.x86_64        1.9 M
 kmod-lustre-tests              x86_64       2.9.0-1.el7.centos         /kmod-lustre-tests-2.9.0-1.el7.centos.x86_64              250 k
 lustre                         x86_64       2.9.0-1.el7.centos         /lustre-2.9.0-1.el7.centos.x86_64                         2.3 M
 lustre-iokit                   x86_64       2.9.0-1.el7.centos         /lustre-iokit-2.9.0-1.el7.centos.x86_64                   133 k
 lustre-osd-ldiskfs-mount       x86_64       2.9.0-1.el7.centos         /lustre-osd-ldiskfs-mount-2.9.0-1.el7.centos.x86_64        28 k
 lustre-tests                   x86_64       2.9.0-1.el7.centos         /lustre-tests-2.9.0-1.el7.centos.x86_64                    11 M

Transaction Summary


#
sudo su
mkfs.lustre --fsname=lustre --mgs --mdt --reformat /dev/sdb
mkdir -p /lustre
mount -t lustre /dev/sdb /lustre

//this should be the ID of your OST
sudo su
mkfs.lustre --fsname=lustre --mgsnode=10.211.55.10@tcp0 --ost --index=1 --reformat /dev/sdb
mkdir -p /lustre
mount -t lustre /dev/sdb /lustre

sudo su
mkdir -p /lustre
mount -t lustre 10.10.1.1@tcp0:/lustre /lustre
chown -R dirruncc:dirr-PG0 /lustre/
chmod -R 775 /lustre/
yum install mpich-3.0.i686

lctl lfsck_start -M lustre-MDT0000 -A -t all -r
lctl debug_kernel /tmp/debug-lfsck.log
lctl lfsck_query -M lustre-MDT0000


MDT: lctl get_param mdd.*.lfsck_speed_limit
OST: lctl get_param obdfilter.*.speed_limit


# to get network and I/O data
yum install sysstat