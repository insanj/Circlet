TARGET =: clang
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = CRPrefs
CRPrefs_FILES = CRPrefsListController.xm $(wildcard *.m) ../UIImage+Circlet.m
CRPrefs_INSTALL_PATH = /Library/PreferenceBundles
CRPrefs_FRAMEWORKS = UIKit MessageUI Twitter CoreGraphics CoreImage
CRPrefs_PRIVATE_FRAMEWORKS = Preferences
NKOColorPickerView.m_CFLAGS = -fobjc-arc
UIDiscreteSlider.m_CFLAGS = -fobjc-arc
CRPrefs_LIBRARIES = cephei cepheiprefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CRPrefs.plist$(ECHO_END)
