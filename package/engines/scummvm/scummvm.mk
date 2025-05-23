################################################################################
#
# scummvm
#
################################################################################
# Version: 2.9.1 - Unreleased yet so no codename yet
SCUMMVM_VERSION = v2.9.1
SCUMMVM_SITE = $(call github,scummvm,scummvm,$(SCUMMVM_VERSION))
SCUMMVM_LICENSE = GPLv2
SCUMMVM_DEPENDENCIES += sdl2 zlib libpng freetype libjpeg-bato
SCUMMVM_DEPENDENCIES += libogg flac libmad faad2
SCUMMVM_DEPENDENCIES += libmpeg2 libtheora

SCUMMVM_ADDITIONAL_FLAGS += -I$(STAGING_DIR)/usr/include -lpthread -lm
SCUMMVM_ADDITIONAL_FLAGS += -L$(STAGING_DIR)/usr/lib -lGLESv2 -lEGL

# Select host architecture
ifeq ($(BR2_aarch64)$(BR2_arm),y)
    SCUMMVM_CONF_OPTS += --host=arm-linux
else ifeq ($(BR2_riscv),y)
    SCUMMVM_CONF_OPTS += --host=riscv64-linux
else ifeq ($(BR2_mipsel),y)
    SCUMMVM_CONF_OPTS += --host=mipsel-linux
endif

SCUMMVM_CONF_ENV += RANLIB="$(TARGET_RANLIB)" STRIP="$(TARGET_STRIP)"
SCUMMVM_CONF_ENV += AR="$(TARGET_AR) cru" AS="$(TARGET_AS)"

# Common options
SCUMMVM_CONF_OPTS += --opengl-mode=auto \
    --enable-flac --enable-mad --disable-taskbar \
    --disable-timidity --disable-alsa --enable-vkeybd \
    --enable-release --enable-optimizations --disable-debug \
    --disable-eventrecorder --prefix=/usr \
    --with-sdl-prefix="$(STAGING_DIR)/usr/bin"

# ScummVM Engines options
SCUMMVM_CONF_OPTS += --enable-all-engines --disable-all-unstable-engines

# Build plugins + everything as dynamic
ifneq ($(BR2_x86_64),y)
SCUMMVM_CONF_OPTS += --enable-plugins --default-dynamic
endif

# Vorbis/Tremor options
ifeq ($(BR2_mipsel)$(BR2_arm),y)
SCUMMVM_CONF_OPTS += --enable-tremor --disable-vorbis
SCUMMVM_DEPENDENCIES += tremor
else
SCUMMVM_CONF_OPTS += --enable-vorbis --disable-tremor
SCUMMVM_DEPENDENCIES += libvorbis
endif

# Architecture-specific optimizations
ifeq ($(BR2_arm)$(BR2_ARM_CPU_HAS_NEON),yy)
SCUMMVM_CONF_OPTS += --enable-ext-neon
# Needed to avoid errors when inlining NEON code on AArch32
SCUMMVM_CONF_ENV  += CXXFLAGS="$(TARGET_CXXFLAGS) -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0"
# AArch64 mandates NEON
else ifeq ($(BR2_aarch64),y)
SCUMMVM_CONF_OPTS += --enable-ext-neon
# x86_64_v3 mandates SSE2 + AVX2
else ifeq ($(BR2_x86_x86_64_v3),y)
SCUMMVM_CONF_OPTS += --enable-ext-sse2
SCUMMVM_CONF_OPTS += --enable-ext-avx2
# x86_64 mandates SSE2
else ifeq ($(BR2_x86_64),y)
SCUMMVM_CONF_OPTS += --enable-ext-sse2
endif

# Disable scalers on MIPS32/ARMv6
# Disable high-res engines on MIPS32/ARMv6
ifeq ($(BR2_mipsel)$(BR2_arm1176jzf_s),y)
SCUMMVM_CONF_OPTS += --disable-scalers
SCUMMVM_CONF_OPTS += --disable-highres
endif

# Munt (MT32-Emulator) options, CPU-hungry
ifeq ($(BR2_aarch64)$(BR2_x86_64),y)
SCUMMVM_CONF_OPTS += --enable-mt32emu
else
SCUMMVM_CONF_OPTS += --disable-mt32emu
endif

# FluidSynth (MIDI rendering) options
ifeq ($(BR2_PACKAGE_FLUIDSYNTH),y)
    SCUMMVM_DEPENDENCIES += fluidsynth
    SCUMMVM_CONF_OPTS += --enable-fluidsynth
else
    SCUMMVM_CONF_OPTS += --disable-fluidsynth
endif

# libvpx
ifeq ($(BR2_PACKAGE_LIBVPX),y)
    SCUMMVM_DEPENDENCIES += libvpx
else
    SCUMMVM_CONF_OPTS += --disable-vpx
endif

# libopenmpt
ifeq ($(BR2_PACKAGE_LIBOPENMPT),y)
    SCUMMVM_DEPENDENCIES += libopenmpt
    SCUMMVM_CONF_OPTS += --enable-openmpt
endif

# libmpeg2
ifeq ($(BR2_PACKAGE_LIBMPEG2),y)
    SCUMMVM_CONF_OPTS += --enable-mpeg2 --with-mpeg2-prefix="$(STAGING_DIR)/usr/lib"
endif

SCUMMVM_MAKE_OPTS += RANLIB="$(TARGET_RANLIB)" STRIP="$(TARGET_STRIP)"
SCUMMVM_MAKE_OPTS += AR="$(TARGET_AR) cru" AS="$(TARGET_AS)" LD="$(TARGET_CXX)"

define SCUMMVM_CONFIGURE_CMDS
    (cd $(@D) && rm -rf config.cache && \
	$(TARGET_CONFIGURE_OPTS) \
	$(TARGET_CONFIGURE_ARGS) \
	$(SCUMMVM_CONF_ENV) \
	./configure \
		--prefix=/usr \
		--exec-prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--program-prefix="" \
        $(SCUMMVM_CONF_OPTS) \
	)
endef

define SCUMMVM_ADD_VIRTUAL_KEYBOARD
    cp -f $(@D)/backends/vkeybd/packs/vkeybd_default.zip \
        $(TARGET_DIR)/usr/share/scummvm
    cp -f $(@D)/backends/vkeybd/packs/vkeybd_small.zip \
        $(TARGET_DIR)/usr/share/scummvm
    mkdir -p $(TARGET_DIR)/usr/share/evmapy/
    cp -f $(BR2_EXTERNAL_REGLINUX_PATH)/package/engines/scummvm/scummvm.keys \
        $(TARGET_DIR)/usr/share/evmapy/
endef

SCUMMVM_POST_INSTALL_TARGET_HOOKS += SCUMMVM_ADD_VIRTUAL_KEYBOARD

$(eval $(autotools-package))
