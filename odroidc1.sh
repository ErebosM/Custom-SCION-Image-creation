#!/bin/bash
#Getting minimal Ubuntu 16.04 image for Odroid C1 from Hardkernel

set -e

IMAGE="ubuntu-16.04.2-minimal-odroid-c1-20170221.img.xz"
REPO="https://dn.odroid.com/S805/Ubuntu"

mkdir ubuntu
cd ubuntu

wget --no-check-certificate --continue ${REPO}/${IMAGE}
7za e ${IMAGE}

rm ${IMAGE}

./systememulation.sh $(basename ${IMAGE} .xz)


