THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang::6.0
ARCHS = armv7 arm64
# DEBUG = 1

include theos/makefiles/common.mk

TWEAK_NAME = Circlet
Circlet_FILES = Circlet.xm UIImage+Circlet.m
Circlet_FRAMEWORKS = Foundation UIKit QuartzCore CoreGraphics CoreImage CoreTelephony CoreText

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += CRPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk

before-stage::
	find . -name ".DS_Store" -delete
internal-after-install::
	install.exec "killall -9 backboardd"
