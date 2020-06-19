
INSTALL_TARGET_PROCESSES = MobileSafari

THEOS_PACKAGE_DIR_NAME = debs
TARGET=iphone:clang
ARCHS= armv7 arm64 arm64e
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = TabBlocker
TabBlocker_FILES = Tweak.xm CustomMenu.m Settings.m
TabBlocker_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
after-install::
	install.exec "killall -9 MobileSafari"
SUBPROJECTS += tabblockerpreferencebundle
include $(THEOS_MAKE_PATH)/aggregate.mk
