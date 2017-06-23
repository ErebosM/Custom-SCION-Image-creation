#!/bin/bash
#System emulation for ARM device

set -e

wget --continue https://releases.linaro.org/ubuntu/boards/lsk-vexpress/15.07/lsk-vexpress-vivid_nano_20150725-725.img.gz
gunzip lsk-vexpress-vivid_nano_20150725-725.img.gz

mkdir temp
sudo mount -t auto -o loop,offset=$((63*512)) lsk-vexpress-vivid_nano_20150725-725.img temp

dd if=temp/uImage of=kernel bs=64 skip=1
dd if=temp/uInitrd of=initrd bs=64 skip=1
cp temp/v2p-ca15-tc1.dtb .

sudo umount temp
rmdir temp

qemu-system-arm -M vexpress-a15 -cpu cortex-a15 -m 512 -nographic \
	-kernel kernel -initrd initrd -dtb v2p-ca15-tc1.dtb -sd image.img \
-append "root=/dev/mmcblk0p2 rw mem=512M raid=noautodetect console=ttyAMA0 rootwait devtmpfs.mount=0"

