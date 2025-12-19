# v4l2loopback for Redmi 13R 5G

[![Build v4l2loopback](https://github.com/YOUR_USERNAME/v4l2loopback-redmi13r/actions/workflows/build-v4l2loopback.yml/badge.svg)](https://github.com/YOUR_USERNAME/v4l2loopback-redmi13r/actions/workflows/build-v4l2loopback.yml)

使用 **GitHub Actions** 自动编译 v4l2loopback 虚拟摄像头内核模块。

## 📱 设备信息

| 项目 | 值 |
|------|-----|
| 设备 | Redmi 13R 5G (Xiaomi air-t) |
| 内核版本 | 5.10.149-android12-9 |
| 架构 | ARM64 (aarch64) |

## 🚀 快速开始

### 下载预编译模块

从 [Releases](../../releases) 页面下载最新的 `v4l2loopback.ko`。

### 安装到设备

```bash
# 推送模块到设备
adb push v4l2loopback.ko /data/local/tmp/

# 以 root 权限加载模块
adb shell "su -c 'insmod /data/local/tmp/v4l2loopback.ko'"

# 验证加载成功
adb shell "lsmod | grep v4l2loopback"

# 查看虚拟摄像头设备
adb shell "ls -la /dev/video*"
```

### 指定虚拟摄像头编号

```bash
adb shell "su -c 'insmod /data/local/tmp/v4l2loopback.ko video_nr=10 card_label=\"VirtualCam\"'"
```

## ⏱️ 编译时间

| 情况 | 时间 |
|------|------|
| 首次编译（无缓存） | 15-20 分钟 |
| 后续编译（有缓存） | 5-8 分钟 |

## 📖 详细文档

- [START_HERE.md](START_HERE.md) - 完整配置总结
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - 快速命令参考
- [GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md) - 详细设置指南

## 🔧 自定义编译

如需修改编译配置，编辑 `.github/workflows/build-v4l2loopback.yml`：

```yaml
env:
  KERNEL_VERSION: 5.10.149
  KERNEL_TAG: android12-5.10.149_r00
```

## ❌ 故障排除

### version magic 不匹配

```bash
# 检查设备内核版本
adb shell "cat /proc/version"
# 应该显示: 5.10.149-android12-9
```

### 模块加载失败

确保设备已 root，并使用正确的权限运行 insmod。

## 📄 许可证

- **v4l2loopback**: GPLv2
- **本项目配置**: MIT License

## 🔗 参考

- [v4l2loopback 官方](https://github.com/umlaeute/v4l2loopback)
- [Android GKI](https://source.android.com/docs/setup/download/downloading)
