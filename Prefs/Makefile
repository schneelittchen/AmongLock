BUNDLE_NAME = AmongLockPrefs
$(BUNDLE_NAME)_FILES = $(wildcard *.m)
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
ADDITIONAL_CFLAGS += -DTHEOS_LEAN_AND_MEAN

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AmongLockPreferences.plist$(ECHO_END)
