################################################################################
#
# vita3k
#
################################################################################
# Version: Commits on Jul 24, 2025
VITA3K_VERSION = 4e526f0c8057e4eae0e00a323d7d4c58cdee8813
VITA3K_SITE = https://github.com/vita3k/vita3k
VITA3K_SITE_METHOD=git
VITA3K_GIT_SUBMODULES=YES
VITA3K_LICENSE = GPLv3
VITA3K_DEPENDENCIES = sdl2 sdl2_image sdl2_ttf zlib libogg libvorbis
VITA3K_DEPENDENCIES += boost python-ruamel-yaml libgtk3 fmt libcurl
VITA3K_EXTRACT_DEPENDENCIES = host-libcurl

VITA3K_SUPPORTS_IN_SOURCE_BUILD = NO

VITA3K_CONF_OPTS = -DCMAKE_BUILD_TYPE=Release \
                   -DBUILD_SHARED_LIBS=OFF \
                   -DUSE_DISCORD_RICH_PRESENCE=OFF \
                   -DUSE_VITA3K_UPDATE=OFF \
                   -DBUILD_EXTERNAL=OFF

ifeq ($(BR2_PACKAGE_SYSTEM_TARGET_X86_64_V3),y)
    VITA3K_CONF_OPTS += -DXXH_X86DISPATCH_ALLOW_AVX=ON
else
    VITA3K_CONF_OPTS += -DXXH_X86DISPATCH_ALLOW_AVX=OFF
endif

#define VITA3K_GET_SUBMODULE
#    mkdir -p $(@D)/external
#    cd $(@D)/external && rm -Rf nativefiledialog-cmake && git clone https://github.com/Vita3K/nativefiledialog-cmake
#endef

define VITA3K_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/bin/vita3k/
	$(TARGET_STRIP) $(@D)/buildroot-build/bin/Vita3K
	cp -R $(@D)/buildroot-build/bin/* $(TARGET_DIR)/usr/bin/vita3k/
endef

define VITA3K_INSTALL_EVMAPY
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp $(BR2_EXTERNAL_REGLINUX_PATH)/package/emulators/vita3k/psvita.vita3k.keys \
        $(TARGET_DIR)/usr/share/evmapy
endef

#VITA3K_POST_EXTRACT_HOOKS = VITA3K_GET_SUBMODULE
VITA3K_POST_INSTALL_TARGET_HOOKS = VITA3K_INSTALL_EVMAPY

$(eval $(cmake-package))
