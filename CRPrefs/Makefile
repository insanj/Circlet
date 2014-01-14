TARGET=:clang
ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = CRPrefs
CRPrefs_FILES = $(wildcard *.xm)
CRPrefs_INSTALL_PATH = /Library/PreferenceBundles
CRPrefs_FRAMEWORKS = UIKit Twitter CoreGraphics
CRPrefs_PRIVATE_FRAMEWORKS = Preferences BulletinBoard

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CRPrefs.plist$(ECHO_END)
