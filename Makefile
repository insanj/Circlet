THEOS_PACKAGE_DIR_NAME = debs
TARGET =: clang
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = Circlet
Circlet_FILES = Circlet.xm UIImage+Circlet.m
Circlet_FRAMEWORKS = Foundation UIKit QuartzCore CoreGraphics CoreImage

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += CRPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk

before-stage::
	find . -name ".DS_Store" -delete
internal-after-install::
	install.exec "killall -9 backboardd"
