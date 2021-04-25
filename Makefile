export ARCHS = arm64 arm64e
export TARGET = iphone:clang:13.5:13.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS13.5.sdk/
export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

INSTALL_TARGET_PROCESSES = SpringBoard
SUBPROJECTS += Tweak Prefs

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
