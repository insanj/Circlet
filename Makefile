THEOS_PACKAGE_DIR_NAME = debs
TARGET =: clang
ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = CellCircle
CellCircle_FILES = $(wildcard *.xm)
CellCircle_FRAMEWORKS = Foundation UIKit QuartzCore CoreMotion CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

internal-after-install::
	install.exec "killall -9 backboardd"