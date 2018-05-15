#!/bin/sh
yum -y groupinstall "Development Tools"
yum -y install xmlto asciidoc elfutils-libelf-devel zlib-devel binutils-devel newt-devel python-devel hmaccalc perl-ExtUtils-Embed bison elfutils-devel audit-libs-devel
yum -y install epel-release
yum -y install pesign numactl-devel pciutils-devel ncurses-devel libselinux-devel
cd ~
git clone https://github.com/daidong/flfsck.git
mv flfsck lustre-release
cd lustre-release
sh autogen.sh

mkdir -p ~/kernel/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cd ~/kernel
echo '%_topdir %(echo $HOME)/kernel/rpmbuild' > ~/.rpmmacros

rpm -ivh http://vault.centos.org/7.3.1611/updates/Source/SPackages/kernel-3.10.0-514.16.1.el7.src.rpm
cd ~/kernel/rpmbuild
rpmbuild -bp --target=`uname -m` ./SPECS/kernel.spec 
rm -f ~/lustre-kernel-x86_64-lustre.patch
cd ~/lustre-release/lustre/kernel_patches/series
for patch in $(<"3.10-rhel7.series"); do \
    patch_file="$HOME/lustre-release/lustre/kernel_patches/patches/${patch}";\
    cat "${patch_file}" >> $HOME/lustre-kernel-x86_64-lustre.patch; \
done
cp ~/lustre-kernel-x86_64-lustre.patch ~/kernel/rpmbuild/SOURCES/patch-3.10.0-lustre.patch
yes | cp -rf /proj/cloudincr-PG0/tools/myhpc/kernel.spec ~/kernel/rpmbuild/SPECS/kernel.spec

echo '# x86_64' > ~/kernel/rpmbuild/SOURCES/kernel-3.10.0-x86_64.config
cat ~/lustre-release/lustre/kernel_patches/kernel_configs/kernel-3.10.0-3.10-rhel7-x86_64.config >> ~/kernel/rpmbuild/SOURCES/kernel-3.10.0-x86_64.config
cd ~/kernel/rpmbuild
buildid="_lustre" # Note: change to any string that identify your work
rpmbuild -ba --with firmware --target x86_64 --with baseonly \
         --define "buildid ${buildid}" \
         ~/kernel/rpmbuild/SPECS/kernel.spec

yum localinstall -y ~/kernel/rpmbuild/RPMS/x86_64/{kernel,kernel-devel}-3.10.0-514.16.1.el7_lustre.x86_64.rpm
reboot