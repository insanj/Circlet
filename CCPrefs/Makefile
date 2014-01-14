TARGET=:clang
ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = ORPreferences
ORPreferences_FILES = ORPreferences.xm ../ORProvider.xm $(wildcard ../*.m)
ORPreferences_INSTALL_PATH = /Library/PreferenceBundles
ORPreferences_FRAMEWORKS = UIKit Twitter CoreGraphics AudioToolbox
ORPreferences_PRIVATE_FRAMEWORKS = Preferences BulletinBoard
ORPreferences_CFLAGS = -fobjc-arc
ORPreferences_LDFLAGS = -Wlactivator -L../theos/lib

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ORPreferences.plist$(ECHO_END)
