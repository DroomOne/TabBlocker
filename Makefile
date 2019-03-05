include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TabBlocker
TabBlocker_FILES = Tweak.xm CustomMenu.m Settings.m
TabBlocker_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += tabblockerpreferencebundle
include $(THEOS_MAKE_PATH)/aggregate.mk
