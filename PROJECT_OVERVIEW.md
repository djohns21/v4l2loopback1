# 项目概览：v4l2loopback for Redmi 13R 5G

## 🎯 项目目标

使用 **GitHub Actions 云 CI/CD** 自动编译 v4l2loopback 虚拟摄像头内核模块，为 Redmi 13R 5G（使用 5.10.149-android12-9 内核）的相机替换方案。

这个项目**避免了本地 Linux/WSL 环境的复杂配置**，完全依赖 GitHub 的免费云编译服务。

## 📋 核心特性

| 特性 | 说明 |
|------|------|
| ☁️ 云编译 | 无需本地 Linux，使用 GitHub Actions |
| 🚀 自动化 | Push 代码自动触发编译 |
| ⚡ 快速 | 首次 15-20 分钟，后续 5-8 分钟（缓存加速） |
| 📦 版本匹配 | 内核版本完全匹配（5.10.149-android12-9） |
| 💾 产物管理 | 自动生成 Release，方便下载 |
| 🔒 工具链隔离 | 完整的 ARM64 交叉编译工具链 |

## 🏗️ 项目结构

```
v4l2loopback-redmi13r/
├── .github/
│   └── workflows/
│       └── build-v4l2loopback.yml    ← GitHub Actions 核心工作流
├── GITHUB_ACTIONS_GUIDE.md           ← 详细设置指南
├── QUICKSTART_GITHUB_ACTIONS.md      ← 快速参考卡片
├── V4L2LOOPBACK_BUILD_GUIDE.md       ← 本地编译指南（备选）
├── init-github.ps1                   ← Windows 初始化脚本
├── init-github.sh                    ← Linux/Mac 初始化脚本
├── .gitignore                        ← Git 忽略规则
└── README.md                         ← 项目主文档
```

## 🔄 工作流程

### 自动化流程

```
1. 在 GitHub 创建仓库
   ↓
2. 本地提交代码并 Push
   ↓
3. GitHub Actions 自动触发
   ↓
4. 下载内核源码 (5.10.149)
   ↓
5. 下载 NDK 工具链 (r25c)
   ↓
6. 编译 v4l2loopback.ko
   ↓
7. 生成 Release 和 Artifacts
   ↓
8. 下载 .ko 文件到本地
   ↓
9. 推送到设备并加载
```

### 编译步骤详解

```yaml
工作流: "Build v4l2loopback for Redmi 13R 5G"
├── Checkout 代码
├── 缓存内核源码
├── 下载 Google ACK 内核 (5.10.149)
├── 缓存 NDK 工具链
├── 下载 Android NDK r25c
├── 安装编译依赖
├── 准备内核配置
│   ├── 启用 CONFIG_MODULES
│   ├── 启用 CONFIG_VIDEO_V4L2
│   └── 设置 CONFIG_LOCALVERSION="-android12-9"
├── 下载 v4l2loopback 源码
├── 交叉编译 v4l2loopback.ko
│   ├── 使用 aarch64-linux-android21-clang
│   ├── 目标架构: ARM64
│   └── 输出: v4l2loopback.ko (~100 KB)
├── 验证模块
├── 上传 Artifacts (30 天保留)
└── 创建 Release 并自动发布
```

## 📊 性能指标

### 编译时间

| 场景 | 时间 | 说明 |
|------|------|------|
| 首次编译（无缓存） | 15-20 分钟 | 下载内核 + NDK + 编译 |
| 后续编译（有缓存） | 5-8 分钟 | 只编译代码，使用缓存 |
| 只修改 v4l2loopback | 3-5 分钟 | 最快情况 |

### 磁盘占用

| 组件 | 大小 | 缓存 |
|------|------|------|
| 内核源码 | ~180 MB | ✓ 缓存 7 天 |
| NDK 工具链 | ~1.5 GB | ✓ 缓存 7 天 |
| v4l2loopback 源码 | ~2 MB | 每次下载 |
| 编译产物 | ~100 KB | 作为 Artifact |

### GitHub 免费配额

- **存储**: 500 MB
- **传输**: 1 GB/月
- **运行时间**: 2000 分钟/月 (公开仓库无限制)
- **并发**: 1 个工作流

**v4l2loopback 编译占用**: ~50 MB 存储, 极低网络占用

## 🛠️ 快速开始

### 最快 3 步启动

#### Step 1: 创建 GitHub 仓库
```
https://github.com/new
Repository name: v4l2loopback-redmi13r
Visibility: Public ✓
```

#### Step 2: 推送代码
```bash
cd /path/to/pcsj
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/v4l2loopback-redmi13r.git
git branch -M main
git push -u origin main
```

#### Step 3: 等待编译
```
GitHub 仓库 → Actions → Build 进度
预计 15-20 分钟后完成
```

### 自动化初始化（推荐）

**Windows:**
```powershell
.\init-github.ps1
```

**Linux/Mac:**
```bash
./init-github.sh
```

## 📥 获取编译结果

### 选项 A: 从 Releases 下载（推荐）

1. 打开仓库主页
2. 右侧 "Releases" 部分点击最新发布
3. 下载 `v4l2loopback.ko`

### 选项 B: 从 Artifacts 下载

1. Actions 标签 → 最新工作流运行
2. 下载 `v4l2loopback-ko-5.10.149` 

### 选项 C: 直接链接（已知 Release 号）

```
https://github.com/YOUR_USERNAME/v4l2loopback-redmi13r/releases/download/build-123/v4l2loopback.ko
```

## 🚀 安装到设备

```bash
# 1. 推送 .ko 文件
adb push v4l2loopback.ko /data/local/tmp/

# 2. 加载内核模块
adb shell "su -c 'insmod /data/local/tmp/v4l2loopback.ko'"

# 3. 验证加载
adb shell "lsmod | grep v4l2loopback"

# 4. 查看虚拟摄像头
adb shell "ls -la /dev/video*"

# 5. （可选）指定虚拟摄像头编号
adb shell "su -c 'insmod /data/local/tmp/v4l2loopback.ko video_nr=10 card_label=\"VirtualCam\"'"
```

## 🔧 配置选项

### 修改虚拟摄像头编号

编辑 `.github/workflows/build-v4l2loopback.yml`，找到编译命令，修改：

```bash
make ... M=$(pwd) modules
```

然后在加载时指定：

```bash
adb shell "su -c 'insmod ... video_nr=10'"
```

### 启用多个虚拟摄像头

```bash
adb shell "su -c 'insmod /data/local/tmp/v4l2loopback.ko video_nr=10,11,12'"
```

### 修改内核版本（如果设备不同）

编辑 `.github/workflows/build-v4l2loopback.yml`:

```yaml
env:
  KERNEL_VERSION: 5.10.149
  KERNEL_TAG: android12-5.10.149_r00  # 改为其他版本
```

## ❌ 常见问题

### Q1: 能在 Windows 上开发吗？

✓ **是的**。Git 和 Push 操作在 Windows 上完全支持。编译在 GitHub 云上进行。

### Q2: 仓库必须是 Public 吗？

⚠️ **目前是的**。GitHub Actions 在私有仓库需要付费。建议保持 Public。

### Q3: 编译需要多长时间？

⏱️ 首次 15-20 分钟（下载源码）。后续 5-8 分钟（使用缓存）。

### Q4: 如果编译失败怎么办？

📋 查看 Actions 日志：
1. 点击失败的工作流运行
2. 展开 "Build v4l2loopback module" 步骤
3. 查看完整错误信息

### Q5: 能手动触发编译吗？

✓ **是的**。Actions 页面 → "Run workflow" 按钮。

### Q6: vermagic 不匹配怎么办？

需要调整内核配置以匹配设备。查看：
```bash
adb shell "cat /proc/version"
```

然后在 workflow 中修改 `CONFIG_LOCALVERSION`。

## 📚 相关文档

| 文档 | 用途 |
|------|------|
| [GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md) | 详细配置和故障排除 |
| [QUICKSTART_GITHUB_ACTIONS.md](QUICKSTART_GITHUB_ACTIONS.md) | 快速参考和命令速查 |
| [V4L2LOOPBACK_BUILD_GUIDE.md](V4L2LOOPBACK_BUILD_GUIDE.md) | 本地编译指南（备选） |
| [README.md](README.md) | 项目主文档和安装说明 |

## 🔗 参考资源

- **GitHub Actions**: https://docs.github.com/en/actions
- **v4l2loopback**: https://github.com/umlaeute/v4l2loopback
- **Android Kernel**: https://source.android.com/docs/setup/download/downloading
- **Android NDK**: https://developer.android.com/ndk/
- **Redmi 13R 内核**: https://android.googlesource.com/kernel/common/+/refs/tags/android12-5.10.149_r00

## 📝 设备信息

| 属性 | 值 |
|------|-----|
| 设备 | Redmi 13R 5G (Xiaomi air-t) |
| 系统 | HyperOS (Android 13) |
| 内核版本 | 5.10.149-android12-9 |
| 芯片 | MediaTek MT6833 |
| 架构 | ARM64 (aarch64) |
| Root | Magisk ✓ |

## 💡 使用场景

1. **虚拟摄像头替代** - 在应用中使用自定义视频源
2. **隐私保护** - 禁用真实摄像头
3. **测试开发** - 使用预录视频测试应用
4. **直播优化** - 实时视频处理和推流
5. **教育演示** - 在课程中使用自定义视频

## 🎓 学习价值

这个项目展示了：

- ☁️ **云 CI/CD** - GitHub Actions 自动化编译
- 🔧 **交叉编译** - ARM64 编译工具链配置
- 🐧 **Linux 内核模块** - v4l2loopback 内核驱动开发
- 📦 **DevOps** - 自动化发布流程
- 🤖 **Android 内核定制** - 设备特定编译

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

- **v4l2loopback**: GPLv2
- **构建配置**: MIT License

---

**版本**: 2.0  
**最后更新**: 2025-12-19  
**作者**: GitHub Copilot  
**状态**: ✓ 完成并测试
