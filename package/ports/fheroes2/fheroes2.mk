################################################################################
#
# Free Heroes (of Might and Magic) 2 engine
#
################################################################################

FHEROES2_VERSION = 1.1.8
FHEROES2_SITE = $(call github,ihhub,fheroes2,$(FHEROES2_VERSION))
FHEROES2_DEPENDENCIES = sdl2 sdl2_image sdl2_mixer

$(eval $(cmake-package))
