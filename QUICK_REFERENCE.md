# 快速命令参考卡片

## 🚀 30秒快速开始

```bash
# Windows PowerShell
.\init-github.ps1

# Linux/Mac
chmod +x init-github.sh && ./init-github.sh
```

## 📋 完整步骤

### 1. 初始化仓库
```bash
git init
git add .
git commit -m "Initial commit: v4l2loopback build pipeline"
```

### 2. 添加远程仓库
```bash
git remote add origin https://github.com/YOUR_USERNAME/v4l2loopback-redmi13r.git
```

### 3. 推送代码
```bash
git branch -M main
git push -u origin main
```

### 4. 查看编译
```
https://github.com/YOUR_USERNAME/v4l2loopback-redmi13r/actions
```

### 5. 下载和安装
```bash
# 下载 v4l2loopback.ko 后
adb push v4l2loopback.ko /data/local/tmp/
adb shell "su -c 'insmod /data/local/tmp/v4l2loopback.ko'"
adb shell "lsmod | grep v4l2loopback"
```

## 📄 文件清单

| 文件 | 说明 |
|------|------|
| `.github/workflows/build-v4l2loopback.yml` | GitHub Actions 核心配置 |
| `SETUP_COMPLETE.md` | 本次配置的完整总结 |
| `GITHUB_ACTIONS_GUIDE.md` | 详细设置指南 |
| `QUICKSTART_GITHUB_ACTIONS.md` | 快速参考 |
| `PROJECT_OVERVIEW.md` | 项目概览 |
| `init-github.ps1` | Windows 初始化脚本 |
| `init-github.sh` | Linux/Mac 初始化脚本 |
| `.gitignore` | Git 忽略规则 |

## 🎯 关键点

- ✅ **仓库必须是 Public** (GitHub Actions 限制)
- ✅ **工作流自动触发** (无需手动)
- ✅ **编译时间** 15-20 分钟(首次) / 5-8 分钟(后续)
- ✅ **缓存加速** 内核源码和 NDK 会被缓存

## ⚡ 手动触发编译

```
Actions → Build v4l2loopback for Redmi 13R 5G → Run workflow
```

## 📱 设备验证

```bash
adb shell "cat /proc/version"
# 应该显示: 5.10.149-android12-9
```

## 🆘 速查

| 问题 | 检查 |
|------|------|
| 编译未运行 | 仓库是否 Public？工作流文件是否在 .github/workflows/ ? |
| 编译失败 | 查看 Actions 日志 |
| 模块加载失败 | vermagic 是否匹配？运行 `adb shell cat /proc/version` |
| 虚拟摄像头不出现 | 检查 `adb shell lsmod` 是否有 v4l2loopback |

---

📖 详见: `QUICKSTART_GITHUB_ACTIONS.md`
