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
mkdir -p "${REGLINUX_BINARIES_DIR}/boot/extlinux" || exit 1

cp "${BINARIES_DIR}/zImage"             "${REGLINUX_BINARIES_DIR}/boot/boot/linux"              || exit 1
cp "${BINARIES_DIR}/rootfs.cpio.lz4"    "${REGLINUX_BINARIES_DIR}/boot/boot/initrd.lz4"         || exit 1
cp "${BINARIES_DIR}/rootfs.squashfs"    "${REGLINUX_BINARIES_DIR}/boot/boot/reglinux.update"    || exit 1
cp "${BINARIES_DIR}/modules"            "${REGLINUX_BINARIES_DIR}/boot/boot/modules.update"     || exit 1
cp "${BINARIES_DIR}/firmware"           "${REGLINUX_BINARIES_DIR}/boot/boot/firmware.update"    || exit 1
cp "${BINARIES_DIR}/rescue"             "${REGLINUX_BINARIES_DIR}/boot/boot/rescue.update"      || exit 1

cp "${BINARIES_DIR}/rk3128-ps7000.dtb"		"${REGLINUX_BINARIES_DIR}/boot/boot/"     || exit 1
cp "${BINARIES_DIR}/rk3128-ps7000.dtb"		"${REGLINUX_BINARIES_DIR}/boot/boot/"     || exit 1
cp "${BINARIES_DIR}/rk3128-xpi-3128.dtb"	"${REGLINUX_BINARIES_DIR}/boot/boot/"     || exit 1
cp "${BINARIES_DIR}/rk3128-evb.dtb"		"${REGLINUX_BINARIES_DIR}/boot/boot/"     || exit 1
cp "${BOARD_DIR}/boot/extlinux.conf"		"${REGLINUX_BINARIES_DIR}/boot/extlinux/" || exit 1

exit 0
