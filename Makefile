THEOS_PACKAGE_DIR_NAME = packages
TARGET = :clang
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = Pinnacle
Pinnacle_FILES = Tweak.x PNCNavigationItemPicker.m
Pinnacle_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete
internal-after-install::
	install.exec "killall -9 backboardd"
