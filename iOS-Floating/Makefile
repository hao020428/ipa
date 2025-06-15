TARGET = FloatingMenu
INSTALL_PATH = /Applications/$(TARGET).app

CC = clang
CXX = clang++
LD = clang++

FRAMEWORKS = -framework UIKit -framework Foundation -framework QuartzCore -framework CoreGraphics -framework Metal -framework MetalKit -framework ModelIO

SYSROOT = $(THEOS)/sdks/iPhoneOS14.5.sdk

# 系统级头文件路径
SYSTEM_INCLUDES = -I$(SYSROOT)/usr/include -I/usr/local/opt/llvm/include/c++/v1

# 更完整的编译标志
COMMON_FLAGS = -fobjc-arc -miphoneos-version-min=14.0 -isysroot $(SYSROOT)
CFLAGS = $(COMMON_FLAGS)
OBJCFLAGS = $(COMMON_FLAGS)
CXXFLAGS = -std=c++11 $(COMMON_FLAGS) -stdlib=libc++ $(SYSTEM_INCLUDES)
LDFLAGS = $(COMMON_FLAGS) $(FRAMEWORKS) -stdlib=libc++ -L/usr/local/opt/llvm/lib

SRC_DIR = src
INCLUDE_DIR = include
OBJ_DIR = obj

# 获取所有源文件
SRCS = $(wildcard $(SRC_DIR)/*.mm) $(wildcard $(SRC_DIR)/Core/*.mm) $(wildcard $(SRC_DIR)/UI/*.mm) $(wildcard $(SRC_DIR)/AntiDetection/*.mm) $(wildcard $(SRC_DIR)/Utils/*.mm)

# 将源文件路径替换为对象文件路径
OBJS = $(patsubst $(SRC_DIR)/%.mm, $(OBJ_DIR)/%.o, $(SRCS))

# 创建对象文件的目录
$(shell mkdir -p $(OBJ_DIR) $(OBJ_DIR)/Core $(OBJ_DIR)/UI $(OBJ_DIR)/AntiDetection $(OBJ_DIR)/Utils)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.mm
	$(CXX) $(CXXFLAGS) -I$(INCLUDE_DIR) -c -o $@ $<

clean:
	rm -rf $(OBJ_DIR) $(TARGET)

# 创建IPA包
ipa: $(TARGET)
	mkdir -p build/Payload/$(TARGET).app
	cp $(TARGET) build/Payload/$(TARGET).app/
	cp Info.plist build/Payload/$(TARGET).app/
	cp -r Resources/* build/Payload/$(TARGET).app/ 2>/dev/null || :
	cd build && zip -r ../$(TARGET).ipa Payload
	rm -rf build

# 安装
install: ipa
	ideviceinstaller -i $(TARGET).ipa
