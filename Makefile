THEOS_PACKAGE_DIR_NAME = packages

include theos/makefiles/common.mk

TWEAK_NAME = Pinnacle
Pinnacle_FILES = Tweak.x PNCNavigationItemPicker.m
Pinnacle_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
