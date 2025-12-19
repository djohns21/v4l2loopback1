# 快速参考：v4l2loopback GitHub Actions CI/CD

## 工作流程概览

```
代码 Push → GitHub → 自动编译 → 生成 .ko → 下载安装
```

## 快速命令

### 1️⃣ 初始化 GitHub 仓库

**Windows PowerShell:**
```powershell
cd D:\ccs\pcsj
.\init-github.ps1
```

**Linux/Mac:**
```bash
cd /path/to/pcsj
chmod +x init-github.sh
./init-github.sh
```

### 2️⃣ 手动推送代码

```bash
# 配置 Git（第一次只需执行一次）
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"

# 进入项目目录
cd /path/to/pcsj

# 初始化并提交
git init
git add .
git commit -m "Initial commit: v4l2loopback build pipeline"

# 添加远程仓库（将 USERNAME 替换为实际用户名）
git remote add origin https://github.com/USERNAME/v4l2loopback-redmi13r.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

### 3️⃣ 监控编译

1. 打开: https://github.com/YOUR_USERNAME/v4l2loopback-redmi13r
2. 点击 "Actions" 标签
3. 查看最新工作流的运行状态

### 4️⃣ 下载编译结果

**方法 A - 从 Releases（推荐）:**
```
https://github.com/YOUR_USERNAME/v4l2loopback-redmi13r/releases
```

**方法 B - 从 Artifacts:**
```
Actions → 最新工作流 → Artifacts → v4l2loopback-ko-5.10.149
```

### 5️⃣ 安装到设备

```bash
# 推送模块
adb push v4l2loopback.ko /data/local/tmp/

# 加载模块
adb shell "su -c 'insmod /data/local/tmp/v4l2loopback.ko'"

# 验证加载
adb shell "lsmod | grep v4l2loopback"

# 查看虚拟摄像头
adb shell "ls -la /dev/video*"
```

## 文件清单

| 文件 | 用途 |
|------|------|
| `.github/workflows/build-v4l2loopback.yml` | GitHub Actions 工作流配置 |
| `GITHUB_ACTIONS_GUIDE.md` | 详细设置指南 |
| `init-github.ps1` | Windows 初始化脚本 |
| `init-github.sh` | Linux/Mac 初始化脚本 |
| `V4L2LOOPBACK_BUILD_GUIDE.md` | 本地编译指南（备选） |

## 编译时间估计

| 情景 | 时间 |
|------|------|
| 首次编译（无缓存） | 15-20 分钟 |
| 后续编译（有缓存） | 5-8 分钟 |
| 只修改 v4l2loopback 代码 | 3-5 分钟 |

## GitHub 仓库创建步骤

1. 访问: https://github.com/new
2. Repository name: `v4l2loopback-redmi13r`
3. Description: `v4l2loopback kernel module for Redmi 13R 5G`
4. Visibility: **Public** ✓
5. 不勾选 "Initialize this repository with a README"
6. 点击 "Create repository"

## 故障排除速查

| 问题 | 解决方案 |
|------|---------|
| "Git 未找到" | 安装 Git: https://git-scm.com/download |
| "没有 main 分支" | 运行: `git branch -M main` |
| "Remote origin exists" | 运行: `git remote set-url origin <URL>` |
| "仓库已存在" | 在 GitHub 上删除重建或使用新名称 |
| 编译失败 | 检查 Actions 日志，查看 GITHUB_ACTIONS_GUIDE.md 故障排除部分 |
| "version magic" 错误 | 设备内核版本不匹配，检查 vermagic 配置 |

## 设备信息验证

```bash
# 检查设备内核版本
adb shell "cat /proc/version"

# 应该显示（Redmi 13R 5G）：
# Linux version 5.10.149-android12-9-g588a99c08993 ...

# 列出所有视频设备
adb shell "ls -la /dev/video*"
```

## 编译配置修改

如需修改编译参数，编辑 `.github/workflows/build-v4l2loopback.yml`:

### 修改内核版本
```yaml
env:
  KERNEL_VERSION: 5.10.149
  KERNEL_TAG: android12-5.10.149_r00
```

### 修改 vermagic
在 "Prepare kernel for compilation" 步骤修改:
```yaml
echo 'CONFIG_LOCALVERSION="-android12-9"' >> .config
```

### 修改虚拟设备编号
在设备上加载时指定:
```bash
adb shell "su -c 'insmod /data/local/tmp/v4l2loopback.ko video_nr=10'"
```

## 实用链接

- GitHub: https://github.com
- v4l2loopback 项目: https://github.com/umlaeute/v4l2loopback
- Android GKI: https://source.android.com/docs/setup/download/downloading
- 本项目完整指南: GITHUB_ACTIONS_GUIDE.md

## 重要提示

⚠️ **关键点:**
- 仓库必须是 **Public**（GitHub Actions 限制）
- 首次编译需要下载 ~180 MB 内核 + ~1.5 GB NDK
- 后续编译使用缓存，速度快很多
- 仓库包含大文件时，GitHub 有 100 MB 单文件限制
- .ko 文件很小（通常 <1 MB）

## 更新工作流

```bash
# 修改工作流文件后，提交并推送
git add .github/workflows/build-v4l2loopback.yml
git commit -m "Update: improve build configuration"
git push

# GitHub Actions 会自动使用新配置重新编译
```

## 手动触发编译

在 GitHub 仓库页面 Actions 标签：
1. 选择 "Build v4l2loopback for Redmi 13R 5G"
2. 点击 "Run workflow"
3. 选择分支（main）
4. 点击 "Run workflow"

---

**版本**: 2.0  
**最后更新**: 2025-12-19  
**设备**: Redmi 13R 5G (5.10.149-android12-9)  
**编译时间**: ~15-20 分钟（首次）
