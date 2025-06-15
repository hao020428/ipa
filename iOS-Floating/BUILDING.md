# 编译说明

本项目是一个iOS应用，需要macOS系统和Xcode进行编译，或者使用theos工具链进行越狱开发环境下的编译。

## 环境需求

### 使用Xcode编译
- macOS 11.0+
- Xcode 12.0+ 
- iOS SDK 14.0+
- 有效的Apple开发者账号（用于签名）

### 使用theos编译
- macOS/Linux/Windows WSL
- theos开发环境
- iOS SDK 14.0+
- ldid（用于伪造签名）

## Xcode编译步骤

1. 打开Terminal (终端)
2. 克隆仓库：`git clone <仓库地址> && cd iOS-Floating`
3. 创建Xcode项目：
   ```bash
   mkdir -p xcode
   cd xcode
   touch project.pbxproj
   ```
4. 将项目文件导入Xcode:
   - 打开Xcode
   - 选择File -> Open...
   - 导航到项目目录并选择xcode文件夹
   - 添加所有源文件到项目中
   
5. 配置签名和证书:
   - 点击项目名称
   - 在"Signing & Capabilities"中配置Team和Bundle Identifier

6. 构建项目:
   - 选择目标设备（模拟器或真机）
   - 点击Run按钮编译运行

## theos编译步骤 (TrollStore)

1. 安装theos:
   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
   ```

2. 打开Terminal并导航到项目目录:
   ```bash
   cd iOS-Floating
   ```

3. 使用Makefile编译项目:
   ```bash
   make
   ```

4. 创建IPA文件:
   ```bash
   make ipa
   ```

5. 生成的IPA文件可以通过TrollStore安装到设备上。

## 特殊编译配置

### 针对TrollStore的配置
确保Info.plist文件中包含以下关键设置:
```xml
<key>platform-application</key>
<true/>
<key>com.apple.private.security.no-container</key>
<true/>
<key>com.apple.private.security.container-required</key>
<false/>
```

### 针对防录屏技术的配置
Metal框架的着色器文件需要特别注意：
1. .metal文件应放在Resources/Shaders目录
2. 编译时需要正确设置Metal库路径

## 常见问题

1. **编译错误："xxx.h file not found"**
   解决方案: 确保include路径正确，并且所有引用的头文件都存在。

2. **签名错误**
   解决方案: 检查证书配置，或使用ldid进行伪签名。

3. **iOS版本兼容性问题**
   解决方案: 在Makefile或Xcode项目中调整目标iOS版本。

4. **Metal着色器编译失败**
   解决方案: 确保Metal库正确设置，并检查着色器代码语法。

## 联系与支持

如有任何编译问题，请提交Issue或联系开发者。 