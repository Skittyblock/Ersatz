include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Ersatz

Ersatz_FILES = $(wildcard *.m)
Ersatz_INSTALL_PATH = /Library/PreferenceBundles
Ersatz_FRAMEWORKS = UIKit
Ersatz_PRIVATE_FRAMEWORKS = Preferences
Ersatz_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Ersatz.plist$(ECHO_END)
