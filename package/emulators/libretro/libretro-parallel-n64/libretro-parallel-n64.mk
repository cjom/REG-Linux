################################################################################
#
# libretro-parallel-n64
#
################################################################################
# Version.: Commits on Mar 2, 2025
LIBRETRO_PARALLEL_N64_VERSION = f8605345e13c018a30c8f4ed03c05d8fc8f70be8
LIBRETRO_PARALLEL_N64_SITE = $(call github,libretro,parallel-n64,$(LIBRETRO_PARALLEL_N64_VERSION))
LIBRETRO_PARALLEL_N64_LICENSE = GPLv2

LIBRETRO_PARALLEL_N64_EXTRA_ARGS=
LIBRETRO_PARALLEL_N64_BOARD=

# Select dynarec depending on architecture
ifeq ($(BR2_aarch64),y)
LIBRETRO_PARALLEL_N64_EXTRA_ARGS += WITH_DYNAREC=aarch64 CPUFLAGS=-DARM_FIX
else ifeq ($(BR2_arm),y)
LIBRETRO_PARALLEL_N64_EXTRA_ARGS += WITH_DYNAREC=arm CPUFLAGS=-DARM_FIX
else ifeq ($(BR2_x86_64),y)
LIBRETRO_PARALLEL_N64_EXTRA_ARGS += WITH_DYNAREC=x86_64
endif

# OpenGL backend
ifeq ($(BR2_PACKAGE_HAS_LIBGL),y)
LIBRETRO_PARALLEL_N64_EXTRA_ARGS += FORCE_GLES=0
LIBRETRO_PARALLEL_N64_DEPENDENCIES += libgl
else
LIBRETRO_PARALLEL_N64_EXTRA_ARGS += FORCE_GLES=1
LIBRETRO_PARALLEL_N64_DEPENDENCIES += libgles
endif

# Vulkan backend
ifeq ($(BR2_PACKAGE_REGLINUX_VULKAN),y)
    LIBRETRO_PARALLEL_N64_EXTRA_ARGS += HAVE_PARALLEL=1
	ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_X86_64_ANY),y)
	    LIBRETRO_PARALLEL_N64_EXTRA_ARGS += HAVE_PARALLEL_RSP=1
    endif
endif

#ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_ASAHI),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=rpi5_64
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2711),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=rpi4_64
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2712),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=rpi5_64
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_S812),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=odroid
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_ORANGEPI_PC),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=classic_armv7_a7
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2836),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=rpi2
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_XU4),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=odroid
#LIBRETRO_PARALLEL_N64_BOARD=ODROID-XU4
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_RK3588),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=rk3588
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_MT8395),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=rk3588
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_S905),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=h5
## unoptimized yet
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_S905GEN2),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=h5
## unoptimized yet
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_S905GEN3),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=h5
# unoptimized yet
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_RK3568),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=h5
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_X86),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=unix
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_X86_64_ANY),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=unix
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_RK3399),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=rockpro64
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_LIBRETECH_H5),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=h5
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_S922X)$(BR2_PACKAGE_SYSTEM_TARGET_A3GEN2),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=n2
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_RK3326),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=odroid
#LIBRETRO_PARALLEL_N64_BOARD=ODROIDGOA
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_RK3288),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=imx6
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_RK3128),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=classic_armv7_a7
#else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_SM8250),y)
#LIBRETRO_PARALLEL_N64_PLATFORM=sm8250
#else
#endif

LIBRETRO_PARALLEL_N64_PLATFORM=$(LIBRETRO_PLATFORM)

define LIBRETRO_PARALLEL_N64_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" -C $(@D)/ -f Makefile platform="$(LIBRETRO_PARALLEL_N64_PLATFORM)" \
		BOARD="$(LIBRETRO_PARALLEL_N64_BOARD)" $(LIBRETRO_PARALLEL_N64_EXTRA_ARGS)
endef

define LIBRETRO_PARALLEL_N64_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/parallel_n64_libretro.so \
	$(TARGET_DIR)/usr/lib/libretro/parallel_n64_libretro.so
endef

define PARALLEL_N64_CROSS_FIXUP
	$(SED) 's|/opt/vc/include|$(STAGING_DIR)/usr/include|g' $(@D)/Makefile
	$(SED) 's|/opt/vc/lib|$(STAGING_DIR)/usr/lib|g' $(@D)/Makefile
endef

PARALLEL_N64_PRE_CONFIGURE_HOOKS += PARALLEL_N64_FIXUP

$(eval $(generic-package))
