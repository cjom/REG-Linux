################################################################################
#
# libretro-mame2003-plus
#
################################################################################
# Version: Commits on Jun 28, 2025
LIBRETRO_MAME2003_PLUS_VERSION = 04fb75e4f1291a490574168f3a04f9455e4a008d
LIBRETRO_MAME2003_PLUS_SITE = $(call github,libretro,mame2003-plus-libretro,$(LIBRETRO_MAME2003_PLUS_VERSION))
LIBRETRO_MAME2003_PLUS_LICENSE = MAME

LIBRETRO_MAME2003_PLUS_PLATFORM = $(LIBRETRO_PLATFORM)

ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2835),y)
LIBRETRO_MAME2003_PLUS_PLATFORM = rpi1

else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2836),y)
LIBRETRO_MAME2003_PLUS_PLATFORM = rpi2

else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2837),y)
LIBRETRO_MAME2003_PLUS_PLATFORM = rpi3_64

else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2711),y)
LIBRETRO_MAME2003_PLUS_PLATFORM = rpi4_64

else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_BCM2712),y)
LIBRETRO_MAME2003_PLUS_PLATFORM = rpi5_64

else ifeq ($(BR2_aarch64),y)
LIBRETRO_MAME2003_PLUS_PLATFORM = unix

else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_S812),y)
LIBRETRO_MAME2003_PLUS_PLATFORM = s812
LIBRETRO_MAME2003_PLUS_EXTRA_ARGS = HAS_CYCLONE=1 HAS_DRZ80=1

else ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_H3)$(BR2_PACKAGE_SYSTEM_TARGET_CHA)$(BR2_PACKAGE_SYSTEM_TARGET_RK3128),y)
LIBRETRO_MAME2003_PLUS_PLATFORM = rpi2
LIBRETRO_MAME2003_PLUS_EXTRA_ARGS = HAS_CYCLONE=1 HAS_DRZ80=1
endif

define LIBRETRO_MAME2003_PLUS_BUILD_CMDS
	mkdir -p $(@D)/obj/mame/cpu/ccpu
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" -C $(@D)/ \
	    -f Makefile platform="$(LIBRETRO_MAME2003_PLUS_PLATFORM)" \
        GIT_VERSION=" $(shell echo $(LIBRETRO_MAME2003_PLUS_VERSION) | cut -c 1-7)"
        rsync -a --exclude mame2003-plus.xml $(@D)/metadata/ $(@D)/metadata-install/
        gzip -9c $(@D)/metadata/mame2003-plus.xml > $(@D)/metadata-install/mame2003-plus.xml.gz
endef

define LIBRETRO_MAME2003_PLUS_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/mame2003_plus_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/mame078plus_libretro.so

	# Bios
	# Need to think of another way to use these files.
	# They take up a lot of space on tmpfs.
	mkdir -p $(TARGET_DIR)/usr/share/reglinux/datainit/bios/mame2003-plus/samples
	cp -r $(@D)/metadata-install/* \
		$(TARGET_DIR)/usr/share/reglinux/datainit/bios/mame2003-plus
endef

define LIBRETRO_MAME2003_PLUS_NAMCO_QUICK_FIX
	$(SED) 's|O3|O2|g' $(@D)/Makefile
	$(SED) 's|to continue|on Keyboard, or Left, Right on Joystick to continue|g' $(@D)/src/ui_text.c
endef

LIBRETRO_MAME2003_PLUS_PRE_BUILD_HOOKS += LIBRETRO_MAME2003_PLUS_NAMCO_QUICK_FIX

$(eval $(generic-package))
