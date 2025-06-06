#!/bin/bash

HOST_DIR=$1
BOARD_DIR=$2
IMAGES_DIR=$3

# Download U-Boot mainline
wget "https://ftp.denx.de/pub/u-boot/u-boot-2025.01.tar.bz2"
tar xf u-boot-2025.01.tar.bz2
cd u-boot-2025.01

# Apply patches
PATCHES="${BR2_EXTERNAL_REGLINUX_PATH}/board/amlogic/s905/patches/uboot/*.patch"
for patch in $PATCHES
do
echo "Applying patch: $patch"
patch -p1 < $patch
done

# Make config
make odroid-c2_defconfig

# Build it
ARCH=aarch64 CROSS_COMPILE="${HOST_DIR}/bin/aarch64-buildroot-linux-gnu-" make -j$(nproc)
mkdir -p ../../uboot-odroidc2

# Clone LibreElec Amlogic FIP
git clone --depth 1 https://github.com/LibreELEC/amlogic-boot-fip

# Build and put to appropriate place
cd amlogic-boot-fip && ./build-fip.sh odroid-c2 ../u-boot.bin ../../../uboot-odroidc2/
