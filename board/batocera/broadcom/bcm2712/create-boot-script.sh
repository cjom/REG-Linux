#!/bin/bash

# HOST_DIR = host dir
# BOARD_DIR = board specific dir
# BUILD_DIR = base dir/build
# BINARIES_DIR = images dir
# TARGET_DIR = target dir
# REGLINUX_BINARIES_DIR = reglinux binaries sub directory

HOST_DIR=$1
BOARD_DIR=$2
BUILD_DIR=$3
BINARIES_DIR=$4
TARGET_DIR=$5
REGLINUX_BINARIES_DIR=$6

mkdir -p "${REGLINUX_BINARIES_DIR}/boot/boot"     || exit 1
mkdir -p "${REGLINUX_BINARIES_DIR}/boot/overlays" || exit 1

cp -pr "${BINARIES_DIR}/rpi-firmware/"*     "${REGLINUX_BINARIES_DIR}/boot/" || exit 1
cp -f  "${BINARIES_DIR}/"*.dtb              "${REGLINUX_BINARIES_DIR}/boot/" || exit 1
cp     "${BOARD_DIR}/boot/config.txt"       "${REGLINUX_BINARIES_DIR}/boot/" || exit 1
cp     "${BOARD_DIR}/boot/cmdline.txt"      "${REGLINUX_BINARIES_DIR}/boot/" || exit 1

# Pironman5 case overlay
cp "${BINARIES_DIR}/pironman5/sunfounder-pironman5.dtbo" "${REGLINUX_BINARIES_DIR}/boot/overlays/" || exit 1

cp "${BINARIES_DIR}/Image"              "${REGLINUX_BINARIES_DIR}/boot/boot/linux"              || exit 1
cp "${BINARIES_DIR}/modules"            "${REGLINUX_BINARIES_DIR}/boot/boot/modules.update"     || exit 1
cp "${BINARIES_DIR}/firmware"           "${REGLINUX_BINARIES_DIR}/boot/boot/firmware.update"    || exit 1
cp "${BINARIES_DIR}/rootfs.cpio.lz4"    "${REGLINUX_BINARIES_DIR}/boot/boot/initrd.lz4"         || exit 1
cp "${BINARIES_DIR}/rootfs.squashfs"    "${REGLINUX_BINARIES_DIR}/boot/boot/reglinux.update"    || exit 1
cp "${BINARIES_DIR}/rescue"             "${REGLINUX_BINARIES_DIR}/boot/boot/rescue.update"      || exit 1

exit 0
