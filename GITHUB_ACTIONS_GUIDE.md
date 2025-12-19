# GitHub Actions CI/CD 设置指南

本文档说明如何使用 GitHub Actions 自动编译 v4l2loopback 内核模块。

## 项目目标

- ✅ 自动化内核模块编译（无需本地 Linux 环境）
- ✅ 使用 GitHub 免费 CI/CD 服务
- ✅ 每次 Push 自动编译，生成可下载的 .ko 文件
- ✅ 详细的编译日志和错误报告

## 前置要求

### 本地要求
- Git（Windows/Mac/Linux）
- 有效的 GitHub 账户
- 互联网连接

### 不需要
- ❌ 本地 Linux/WSL 环境
- ❌ 本地编译工具链
- ❌ 大量本地磁盘空间

## 快速开始（3 步）

### 步骤 1：在 GitHub 创建仓库

1. 访问 https://github.com/new
2. 填写：
   - **Repository name**: `v4l2loopback-redmi13r`
   - **Description**: `v4l2loopback kernel module for Redmi 13R 5G (5.10.149)`
   - **Visibility**: `Public`（GitHub Actions 在私有仓库需要付费）
   - **不勾选** "Initialize this repository with a README"

3. 点击 "Create repository"

### 步骤 2：推送代码到 GitHub

```bash
# 进入项目目录
cd /path/to/pcsj

# 初始化 git 仓库（如果还没有）
git init

# 配置用户信息
git config user.email "your-email@example.com"
git config user.name "Your Name"

# 添加所有文件
git add .

# 创建初始提交
git commit -m "Initial commit: v4l2loopback build pipeline for Redmi 13R 5G"

# 添加远程仓库（将 YOUR_USERNAME 替换为实际用户名）
git remote add origin https://github.com/YOUR_USERNAME/v4l2loopback-redmi13r.git

# 推送到 main 分支
git branch -M main
git push -u origin main
```

### 步骤 3：查看自动编译过程

1. 打开仓库页面：https://github.com/YOUR_USERNAME/v4l2loopback-redmi13r
2. 点击顶部 "Actions" 标签
3. 查看编译进度和日志

## 工作流程说明

### 触发条件

GitHub Actions 自动运行（无需手动触发）：

- ✅ `git push` 到 `main` 分支
- ✅ Pull Request 到 `main` 分支
- ✅ 修改 `.github/workflows/build-v4l2loopback.yml` 文件
- ✅ 手动点击 "Run workflow" 按钮

### 编译步骤

1. **下载 Google ACK 内核源码** (5.10.149)
   - 从 Android 官方源下载
   - 缓存以加速后续编译

2. **下载 Android NDK** (r25c)
   - ARM64 交叉编译工具链
   - 缓存以加速后续编译

3. **准备内核配置**
   - 启用 V4L2 支持
   - 配置 MODULE 支持
   - 设置 vermagic 匹配设备

4. **下载 v4l2loopback 源码**
   - 从 GitHub 获取最新版本
   - 解压到编译目录

5. **编译 v4l2loopback.ko**
   - 使用交叉编译器编译 ARM64 模块
   - 输出 .ko 文件

6. **上传产物**
   - 保存 .ko 文件作为 Artifact（30 天）
   - 如果推送到 main，自动创建 Release

## 下载编译结果

### 方法 1：从 Releases 下载（推荐）

1. 打开仓库主页
2. 右侧 "Releases" 部分
3. 点击最新的 Release
4. 下载 `v4l2loopback.ko`

### 方法 2：从 Artifacts 下载

1. 点击 "Actions" 标签
2. 选择最新的工作流运行
3. 下载 `v4l2loopback-ko-5.10.149` artifact

## 安装编译结果到设备

```bash
# 1. 推送模块到设备
adb push v4l2loopback.ko /data/local/tmp/

# 2. 以 root 权限加载
adb shell "su -c 'insmod /data/local/tmp/v4l2loopback.ko'"

# 3. 验证加载
adb shell "lsmod | grep v4l2loopback"

# 4. 查看虚拟摄像头设备
adb shell "ls -la /dev/video*"

# 5. 指定虚拟摄像头编号（可选）
adb shell "su -c 'insmod /data/local/tmp/v4l2loopback.ko video_nr=10 card_label=\"VirtualCam\"'"
```

## 故障排除

### 编译失败 - Kernel source download failed

**原因**: 网络问题或 Google 服务器不可达

**解决方案**:
1. 等待 5-10 分钟后重试
2. 点击 "Re-run failed jobs"
3. 检查网络连接

### 编译失败 - Compilation error

**原因**: 内核配置不匹配或编译器问题

**检查方式**:
1. 点击工作流运行
2. 展开 "Build v4l2loopback module" 步骤
3. 查看完整的编译错误信息

**常见错误**:
- "CONFIG_VIDEO_V4L2 not enabled" → 编辑 workflow，添加配置
- "version magic mismatch" → 检查 vermagic，调整 CONFIG_LOCALVERSION

### 模块加载失败 - version magic mismatch

**原因**: 内核配置不匹配

**诊断**:
```bash
# 查看设备 vermagic
adb shell "cat /proc/version"

# 应该显示：
# Linux version 5.10.149-android12-9-g588a99c08993
```

**解决**:
1. 在 workflow 文件中检查 CONFIG_LOCALVERSION 设置
2. 确保与设备输出一致
3. 提交并推送以重新编译

### GitHub Actions 不运行

**检查清单**:
1. ✓ 工作流文件在 `.github/workflows/build-v4l2loopback.yml`
2. ✓ 仓库是 Public（或已启用 Actions）
3. ✓ 代码已推送到 `main` 分支
4. ✓ 检查 "Actions" 标签页是否有工作流列表

## 自定义编译配置

编辑 `.github/workflows/build-v4l2loopback.yml`：

### 修改内核版本

```yaml
env:
  KERNEL_VERSION: 5.10.149
  KERNEL_TAG: android12-5.10.149_r00
```

### 修改虚拟摄像头默认设置

在 workflow 中的 "Build v4l2loopback module" 步骤修改 CFLAGS。

### 修改 NDK 版本

```yaml
env:
  NDK_VERSION: r26  # 改为其他版本
```

## 安全性考虑

### 敏感信息

⚠️ **不要在代码中提交**：
- API 密钥
- 个人 Token
- 密码

✓ **使用 GitHub Secrets** 处理敏感信息

### 仓库权限

- 如果仓库是 Private，GitHub Actions 需要付费
- 建议保持为 Public

## 进阶：触发手动编译

1. 打开仓库主页
2. 点击 "Actions" 标签
3. 左侧选择 "Build v4l2loopback for Redmi 13R 5G"
4. 点击 "Run workflow"
5. 选择分支（main）
6. 点击 "Run workflow" 按钮

## 性能指标

典型编译时间：
- 首次编译（无缓存）：15-20 分钟
- 后续编译（有缓存）：5-8 分钟

缓存大小：
- 内核源码：~180 MB
- NDK 工具链：~1.5 GB

## 下一步

编译成功后，可以：

1. ✓ 下载 .ko 文件到本地
2. ✓ 使用 `adb push` 推送到设备
3. ✓ 使用 `insmod` 加载模块
4. ✓ 创建用户空间程序推送视频帧

参考: [安装和使用指南](README.md)

## 参考资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [v4l2loopback 项目](https://github.com/umlaeute/v4l2loopback)
- [Android Kernel 开发](https://source.android.com/docs/setup/download/downloading)
- [Android NDK](https://developer.android.com/ndk/)

---

**最后更新**: 2025-12-19
**工作流版本**: 2.0
**测试设备**: Redmi 13R 5G (5.10.149-android12-9)
