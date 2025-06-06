################################################################################
#
# cemu
#
################################################################################

# Unstable because of WIP aarch64 upstreamed support
CEMU_VERSION = c8045f7f04d8558930dd2c144b75b6a46185ceee
CEMU_SITE = https://github.com/cemu-project/Cemu
CEMU_LICENSE = GPLv2
CEMU_SITE_METHOD=git
CEMU_GIT_SUBMODULES=YES
CEMU_DEPENDENCIES = sdl2 host-pugixml pugixml rapidjson boost libpng libcurl \
                    libzip host-glslang glslang zlib zstd wxwidgets fmt glm upower \
                    host-nasm host-zstd host-libusb libusb bluez5_utils

CEMU_SUPPORTS_IN_SOURCE_BUILD = NO

CEMU_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release
CEMU_CONF_OPTS += -DBUILD_SHARED_LIBS=OFF
CEMU_CONF_OPTS += -DENABLE_DISCORD_RPC=OFF
CEMU_CONF_OPTS += -DENABLE_VCPKG=OFF
CEMU_CONF_OPTS += -DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -I$(STAGING_DIR)/usr/include/glslang"

# REG configure OpenGL
ifeq ($(BR2_PACKAGE_HAS_LIBGL),y)
    CEMU_DEPENDENCIES += libgl
    CEMU_CONF_OPTS += -DENABLE_OPENGL=ON
else
    CEMU_CONF_OPTS += -DENABLE_OPENGL=OFF
endif

# REG enable gamemode
ifeq ($(BR2_PACKAGE_GAMEMODE),y)
    CEMU_DEPENDENCIES += gamemode
    CEMU_CONF_OPTS += -DENABLE_FERAL_GAMEMODE=ON
else
    CEMU_CONF_OPTS += -DENABLE_FERAL_GAMEMODE=OFF
endif

# REG enable HIDAPI
ifeq ($(BR2_PACKAGE_HIDAPI),y)
    CEMU_DEPENDENCIES += hidapi
    CEMU_CONF_OPTS += -DENABLE_HIDAPI=ON
else
    CEMU_CONF_OPTS += -DENABLE_HIDAPI=OFF
endif

ifeq ($(BR2_PACKAGE_WAYLAND),y)
    CEMU_CONF_OPTS += -DENABLE_WAYLAND=ON
    CEMU_DEPENDENCIES += wayland wayland-protocols
else
    CEMU_CONF_OPTS += -DENABLE_WAYLAND=OFF
endif

define CEMU_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin/cemu/
	mv -f $(@D)/bin/Cemu_release $(@D)/bin/cemu
	cp -pr $(@D)/bin/{cemu,gameProfiles,resources} $(TARGET_DIR)/usr/bin/cemu/
	$(INSTALL) -m 0755 -D \
	    $(BR2_EXTERNAL_REGLINUX_PATH)/package/emulators/cemu/get-audio-device \
	    $(TARGET_DIR)/usr/bin/cemu/
	# keys.txt
	mkdir -p $(TARGET_DIR)/usr/share/reglinux/datainit/bios/cemu
	touch $(TARGET_DIR)/usr/share/reglinux/datainit/bios/cemu/keys.txt
	#evmap config
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp -pr $(BR2_EXTERNAL_REGLINUX_PATH)/package/emulators/cemu/wiiu.keys \
	    $(TARGET_DIR)/usr/share/evmapy
endef

#define EXTRACT_CEMU_AARCH64_DEPS
#	cd $(@D)/dependencies/ && tar xzvf $(BR2_EXTERNAL_REGLINUX_PATH)/package/emulators/cemu/aarch64_deps.tar.gz
#endef
#
#CEMU_PRE_CONFIGURE_HOOKS += EXTRACT_CEMU_AARCH64_DEPS

$(eval $(cmake-package))
