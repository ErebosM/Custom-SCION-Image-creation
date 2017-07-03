#!/bin/bash
#Creating minimal Ubuntu 16.04 image for Odroid C1

set -e

# Tools:
# Basic set of tools that we will need to create our image.

sudo apt-get -y install debootstrap qemu-user-static

# Work folder
# Create a workspace

mkdir ubuntu
cd ubuntu
export ubuntu=`pwd`

# Empty image (4GB)
# Create a image with 4096 1Mbyte blocks (4Gbyte image)

dd if=/dev/zero of=./image.img bs=1M count=4096

# Image partitioning
# Create the two needed partitions, one fat32 for kernel+initramfs+boot script and another ext4 for the OS
#Source: https://superuser.com/a/984637

(
echo n
echo p
echo 1
echo 
echo +128M
echo t
echo c
echo n
echo p
echo 2
echo 
echo 
echo w
) | fdisk image.img

#If not set, there can be an error with fdisk not finished yet

sleep 20

# Setup loopback and format the partitions.
# Also change the UUID and disable journaling.

echo y | sudo losetup /dev/loop0 ./image.img
sudo partprobe /dev/loop0
sudo mkfs.vfat -n boot /dev/loop0p1
sudo mkfs.ext4 -L rootfs /dev/loop0p2
sudo tune2fs /dev/loop0p2 -U e139ce78-9841-40fe-8823-96a304a09859
sudo tune2fs -O ^has_journal /dev/loop0p2

# Bootloaders
# Download a pre-built version of U-Boot for C1 and fuse to our image.

wget https://raw.githubusercontent.com/mdrjr/c1_uboot_binaries/master/bl1.bin.hardkernel
wget https://raw.githubusercontent.com/mdrjr/c1_uboot_binaries/master/u-boot.bin
wget https://raw.githubusercontent.com/mdrjr/c1_uboot_binaries/master/sd_fusing.sh
chmod +x sd_fusing.sh
sudo ./sd_fusing.sh /dev/loop0

# Deboostrap
# Mount the partitions, copy qemu to enable chroot to arm and start debootstrap

mkdir -p target
sudo mount /dev/loop0p2 target
sudo mkdir -p target/media/boot
sudo mount /dev/loop0p1 target/media/boot
sudo mkdir -p target/usr/bin
sudo cp /usr/bin/qemu-arm-static target/usr/bin
sudo debootstrap --variant=buildd --arch armhf xenial target http://ports.ubuntu.com

# Preparations via chroot


AN_FRONTEND=noninteractive DEBIAN_FRONTEND=noninteractive echo "#!bin/bash
set -e
cat << EOF > /etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports/ xenial main universe restricted
deb-src http://ports.ubuntu.com/ubuntu-ports/ xenial main universe restricted

deb http://ports.ubuntu.com/ubuntu-ports/ xenial-updates main universe restricted
deb-src http://ports.ubuntu.com/ubuntu-ports/ xenial-updates main universe restricted

deb http://ports.ubuntu.com/ubuntu-ports/ xenial-backports main restricted
deb-src http://ports.ubuntu.com/ubuntu-ports/ xenial-backports main restricted

deb http://ports.ubuntu.com/ubuntu-ports/ xenial-security main restricted
deb-src http://ports.ubuntu.com/ubuntu-ports/ xenial-security main restricted
deb http://ports.ubuntu.com/ubuntu-ports/ xenial-security universe
deb-src http://ports.ubuntu.com/ubuntu-ports/ xenial-security universe
deb http://ports.ubuntu.com/ubuntu-ports/ xenial-security multiverse  
deb-src http://ports.ubuntu.com/ubuntu-ports/ xenial-security multiverse
EOF

apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confold" install software-properties-common u-boot-tools isc-dhcp-client ubuntu-minimal ssh

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D986B59D
echo "deb http://deb.odroid.in/c1/ xenial main" > /etc/apt/sources.list.d/odroid.list
apt-get -y update

DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confold" install linux-image-c1 bootini

# At this point.. You'll have several errors, That's fine.
# You can ignore it right now.

cp /boot/uImage* /media/boot/uImage

# Setup ethernet as DHCP and create the loopback interface

cat << EOF > /etc/network/interfaces.d/lo
auto lo
iface lo inet loopback
EOF

cat << EOF > /etc/network/interfaces.d/eth0
auto eth0
iface eth0 inet dhcp
EOF

# Setup fstab

echo "LABEL=boot /media/boot vfat defaults 0 0" >> /etc/fstab
echo "UUID=e139ce78-9841-40fe-8823-96a304a09859 / ext4 errors=remount-ro,noatime 0 1" >> /etc/fstab

# Setting a root password

echo "root:odroid" | chpasswd

#Creating scion user and update system before starting the setup
useradd scion
echo "scion:odroid" | chpasswd
sudo adduser scion sudo
mkhomedir_helper scion
cp setupdevice.sh /home/scion
chown -R scion: home/scion

DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confold" install u-boot
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confold" update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confold" upgrade


chage -d 0 root

exit" >> odroidrootscript.sh

#Install scion on the image (Until starting the webserver)

cd ..
sudo chmod +x setupdevice.sh
sudo cp setupdevice.sh ubuntu/target/
cd ubuntu

sudo chmod +x odroidrootscript.sh
sudo cp odroidrootscript.sh target/
sudo rm odroidrootscript.sh

#Mounting needed directories
sudo mount --bind /dev/pts target/dev/pts
sudo mount --bind /proc target/proc
sudo mount --bind /sys target/sys

#Take target as root directory and automatically run odroidrootscript.sh

sudo chroot target bash odroidrootscript.sh

#Clean up

sudo rm target/setupdevice.sh
sudo rm target/odroidrootscript.sh

sudo umount target/media/boot
sudo umount target/dev/pts
sudo umount target/proc
sudo umount target/sys
#If sleep not set, there is an error with umount target - target is busy
sleep 20
sudo umount target
sudo sync
sudo losetup -d /dev/loop0


