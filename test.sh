#!/usr/bin/expect

cd ubuntu

qemu-system-arm -M vexpress-a15 -cpu cortex-a15 -m 512 -nographic -kernel kernel -initrd initrd -dtb v2p-ca15-tc1.dtb -sd ubuntu-16.04.2-minimal-odroid-c1-20170221.img -append "root=/dev/mmcblk0p2 rw mem=512M raid=noautodetect console=ttyAMA0 rootwait devtmpfs.mount=0"


expect "(or press Control-D to continue):" {send "odroid\r"}
#expect "root@odroid:~#" {send "sudo su - scion; ./setupdevice.sh\r"}




