# Dolphins - Theos Tweak
# Build fixes by Synzo (@synzo)
# GitHub: https://github.com/synzo

export THEOS ?= $(HOME)/theos

ARCHS = arm64

DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

# Build type: JB (jailbreak) or NONJB (non-jailbreak)
# Usage: 
#   make package         = JB build (.deb)
#   make package NONJB=1 = Non-JB build (.dylib)

include $(THEOS)/makefiles/common.mk

ifeq ($(NONJB),1)
    LIBRARY_NAME = Dolphins
    Dolphins_LDFLAGS = -dynamiclib -install_name /Library/MobileSubstrate/DynamicLibraries/Dolphins.dylib
    Dolphins_FILES = Dolphins.mm MenuWindow.mm $(wildcard View/*.mm) $(wildcard View/*.m) $(wildcard View/*.cpp) $(wildcard imgui/*.mm) $(wildcard imgui/*.cpp) $(wildcard SCLAlertView/*.m) $(wildcard GWMProgressHUD/*.m) $(wildcard FCUUID/*.m) $(wildcard Internet/*.m)
    include $(THEOS_MAKE_PATH)/library.mk
else
    TWEAK_NAME = Dolphins
    Dolphins_FILES = Dolphins.mm MenuWindow.mm $(wildcard View/*.mm) $(wildcard View/*.m) $(wildcard View/*.cpp) $(wildcard imgui/*.mm) $(wildcard imgui/*.cpp) $(wildcard SCLAlertView/*.m) $(wildcard GWMProgressHUD/*.m) $(wildcard FCUUID/*.m) $(wildcard Internet/*.m)
    include $(THEOS_MAKE_PATH)/tweak.mk
endif

Dolphins_EXTRA_FRAMEWORKS += 
Dolphins_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG

Dolphins_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value
