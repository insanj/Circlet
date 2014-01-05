THEOS_PACKAGE_DIR_NAME = debs
TARGET =: clang
ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = Orangered
Orangered_FILES = Orangered.xm ORProvider.xm $(wildcard *.m)
Orangered_FRAMEWORKS = Foundation UIKit AudioToolbox
Orangered_PRIVATE_FRAMEWORKS = AppSupport BulletinBoard
Orangered_CFLAGS = -fobjc-arc
Orangered_LDFLAGS = -Wlactivator -Ltheos/lib

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += ORPreferences
SUBPROJECTS += ORListener
include $(THEOS_MAKE_PATH)/aggregate.mk