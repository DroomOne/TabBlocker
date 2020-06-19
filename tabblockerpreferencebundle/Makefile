include $(THEOS)/makefiles/common.mk
ARCHS= armv7 arm64 arm64e

BUNDLE_NAME = TabBlockerPreferenceBundle
TabBlockerPreferenceBundle_FILES = XXXRootListController.m
TabBlockerPreferenceBundle_INSTALL_PATH = /Library/PreferenceBundles
TabBlockerPreferenceBundle_FRAMEWORKS = UIKit
TabBlockerPreferenceBundle_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TabBlockerPreferenceBundle.plist$(ECHO_END)
