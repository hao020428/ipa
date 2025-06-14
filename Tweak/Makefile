TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1
ZSIGN_PATCH_IPA = 0
TWEAK_SCHEME = rootless

ifeq ($(ZSIGN_PATCH_IPA), 1)
    THEOS_PACKAGE_DIR = ./packages/jailed
else
    THEOS_PACKAGE_SCHEME = $(TWEAK_SCHEME)
    THEOS_PACKAGE_DIR = ./packages/$(THEOS_PACKAGE_SCHEME)
endif

include $(THEOS)/makefiles/common.mk

# --- Project Configuration ---
TWEAK_NAME = UEDumper
RPM_USE_MEMCPY = 1

# --- Source Files ---
# Define paths
DEPS_PATH = ../deps
KITTYMEMORY_PATH = $(DEPS_PATH)/KittyMemory

# Gather source files from dependencies
KITTYMEMORY_SRC = $(wildcard $(KITTYMEMORY_PATH)/*.cpp)
MINIZIP_SRC = $(wildcard $(DEPS_PATH)/SSZipArchive/minizip/*.c)
DEPS_SRC = $(KITTYMEMORY_SRC) $(DEPS_PATH)/fmt/format.cc $(DEPS_PATH)/SSZipArchive/SSZipArchive.m $(MINIZIP_SRC)

# Gather Tweak source files
TWEAK_SRC = src/Tweak.mm src/Dumper.cpp src/UPackageGenerator.cpp \
            src/Utils/AlertUtils.mm src/Utils/KittyAlertView.mm src/Utils/BufferFmt.cpp \
            $(wildcard src/UE/*.cpp)

# Combine all source files
$(TWEAK_NAME)_FILES = $(TWEAK_SRC) $(DEPS_SRC)

# --- Compiler Flags ---
# Common include paths for all source types
COMMON_INCLUDES = -I$(DEPS_PATH) -I$(KITTYMEMORY_PATH)

# Common compiler flags
COMMON_FLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-function

# C Flags (for .c files like minizip)
ZIP_ARCHIVE_DEFINES = -DHAVE_INTTYPES_H -DHAVE_PKCRYPT -DHAVE_STDINT_H -DHAVE_WZAES -DHAVE_ZLIB
$(TWEAK_NAME)_CFLAGS = $(COMMON_FLAGS) $(ZIP_ARCHIVE_DEFINES) $(COMMON_INCLUDES) -I$(DEPS_PATH)/SSZipArchive

# Objective-C Flags (for .m files like SSZipArchive.m)
$(TWEAK_NAME)_OBJCFLAGS = $(COMMON_FLAGS) $(ZIP_ARCHIVE_DEFINES) $(COMMON_INCLUDES) -I$(DEPS_PATH)/SSZipArchive

# C++ Flags (for .cpp files)
$(TWEAK_NAME)_CXXFLAGS = -std=c++17 -O2 $(COMMON_FLAGS) $(COMMON_INCLUDES) -DkNO_KEYSTONE -DkNO_SUBSTRATE

# Objective-C++ Flags (for .mm files). THIS IS THE KEY FIX.
$(TWEAK_NAME)_OBJCXXFLAGS = $($(TWEAK_NAME)_CXXFLAGS)

# Conditional flags
ifeq ($(RPM_USE_MEMCPY), 1)
	$(TWEAK_NAME)_CXXFLAGS += -DRPM_USE_MEMCPY
	$(TWEAK_NAME)_OBJCXXFLAGS += -DRPM_USE_MEMCPY
endif

# --- Linker Flags ---
$(TWEAK_NAME)_LDFLAGS = -lz -liconv -ldl
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security Network QuartzCore

# --- Final include ---
include $(THEOS_MAKE_PATH)/tweak.mk

# --- Post-build steps (optional) ---
ifeq ($(ZSIGN_PATCH_IPA), 1)
after-package::
		@echo "running zsign to resign and install IPA..."
		@$(ZSIGN_PATH) "$(IPA_IN_PATH)" -k "$(CERT_PATH)" -p "$(CERT_PASS)" -m "$(PROV_PATH)" -z 1 -l "$(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib" -o "$(IPA_OUT_PATH)" --install
endif
