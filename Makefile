THEOS_PACKAGE_DIR_NAME = debs
TARGET =: clang
ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = Circlet
Circlet_FILES = $(wildcard *.xm) $(wildcard *.mm) $(wildcard *.m)
Circlet_FRAMEWORKS = Foundation UIKit QuartzCore CoreMotion CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += CRPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-after-install::
	install.exec "killall -9 backboardd"
