################################################################################
#
# tremor
#
################################################################################
# reglinux - Xiph.org official repo not maintained for 7 years, does not build fine.
TREMOR_VERSION = 91decb5f1b11a84a2157a6326d9135b22627024b
TREMOR_SITE = https://github.com/sezero/tremor.git
TREMOR_SITE_METHOD = git
TREMOR_LICENSE = BSD-3-Clause
TREMOR_LICENSE_FILES = COPYING

TREMOR_AUTORECONF = YES
TREMOR_INSTALL_STAGING = YES
TREMOR_DEPENDENCIES = libogg

# tremor has ARM assembly code that cannot be compiled in Thumb2 mode,
# so we must force the traditional ARM mode.
# However, some ARM architectures like ARNv7-M only supports Thumb
# instructions, but the tremor build configuration enables ARM assembly
# code unconditionally for all arm triplets by defining _ARM_ASSEM_.
# We are overriding this by undefining this macro for the ARM
# architectures not supporting ARM instructions.
ifeq ($(BR2_arm),y)
ifeq ($(BR2_ARM_CPU_HAS_ARM),y)
TREMOR_CONF_ENV = CFLAGS="$(TARGET_CFLAGS) -marm"
else
TREMOR_CONF_ENV = CFLAGS="$(TARGET_CFLAGS) -U_ARM_ASSEM_"
endif
endif

$(eval $(autotools-package))
