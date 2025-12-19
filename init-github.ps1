# GitHub Actions CI/CD 初始化脚本 (PowerShell)
# 用于快速设置和推送到 GitHub

param(
    [string]$GitHubUser = "",
    [string]$RepoName = "v4l2loopback-redmi13r",
    [string]$CommitMsg = "Initial commit: v4l2loopback build pipeline for Redmi 13R 5G"
)

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
}

function Write-Status {
    param([string]$Message, [string]$Type = "info")
    
    switch ($Type) {
        "success" { Write-Host "✓ $Message" -ForegroundColor Green }
        "error" { Write-Host "✗ $Message" -ForegroundColor Red }
        "warning" { Write-Host "⚠ $Message" -ForegroundColor Yellow }
        default { Write-Host "ℹ $Message" -ForegroundColor Cyan }
    }
}

Write-Header "GitHub 仓库初始化工具"

# 检查 Git 安装
Write-Host ""
Write-Status "检查 Git 安装..."

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Status "Git 未安装！请先安装 Git" "error"
    Write-Host ""
    Write-Host "下载地址: https://git-scm.com/download/win"
    exit 1
}

Write-Status "Git 已安装" "success"

# 检查 Git 配置
Write-Status "检查 Git 配置..."

$gitEmail = git config --global user.email 2>$null
$gitName = git config --global user.name 2>$null

if (-not $gitEmail -or -not $gitName) {
    Write-Status "Git 用户信息未配置" "warning"
    Write-Host ""
    Write-Host "请运行以下命令配置："
    Write-Host "  git config --global user.email 'your-email@example.com'"
    Write-Host "  git config --global user.name 'Your Name'"
    Write-Host ""
    
    $config = Read-Host "现在配置? (y/n)"
    if ($config -eq "y") {
        $email = Read-Host "邮箱"
        $name = Read-Host "名称"
        git config --global user.email $email
        git config --global user.name $name
        Write-Status "配置已保存" "success"
    }
} else {
    Write-Status "Git 配置完整: $gitName <$gitEmail>" "success"
}

# 获取 GitHub 用户名
if (-not $GitHubUser) {
    Write-Host ""
    Write-Host "输入 GitHub 用户信息："
    $GitHubUser = Read-Host "GitHub 用户名"
}

if (-not $GitHubUser) {
    Write-Status "未输入用户名" "error"
    exit 1
}

# 构建仓库 URL
$RepoUrl = "https://github.com/$GitHubUser/$RepoName.git"

Write-Host ""
Write-Host "仓库配置:"
Write-Host "  用户名: $GitHubUser" -ForegroundColor Gray
Write-Host "  仓库名: $RepoName" -ForegroundColor Gray
Write-Host "  URL:    $RepoUrl" -ForegroundColor Gray

# 初始化 Git 仓库
Write-Host ""
Write-Status "初始化 Git 仓库..."

if (-not (Test-Path ".git")) {
    git init
    git config user.email $gitEmail
    git config user.name $gitName
    Write-Status "本地仓库已初始化" "success"
} else {
    Write-Status "仓库已初始化" "success"
}

# 配置远程
if (-not (git remote -v | Select-String "origin")) {
    Write-Status "配置远程仓库..."
    git remote add origin $RepoUrl
    Write-Status "远程仓库已配置" "success"
} else {
    Write-Status "远程仓库已配置" "success"
}

# 检查是否有需要提交的文件
Write-Host ""
Write-Status "检查文件状态..."

$status = git status --porcelain

if (-not $status) {
    Write-Status "没有需要提交的文件" "warning"
    
    $addFiles = Read-Host "是否添加所有文件? (y/n)"
    if ($addFiles -eq "y") {
        git add .
        Write-Status "文件已添加" "success"
    } else {
        Write-Status "已取消" "warning"
        exit 0
    }
} else {
    Write-Status "发现需要提交的文件:" "success"
    Write-Host $status -ForegroundColor Gray
    Write-Host ""
    
    $confirm = Read-Host "添加并提交这些文件? (y/n)"
    if ($confirm -eq "y") {
        git add .
    } else {
        exit 0
    }
}

# 提交代码
Write-Host ""
Write-Host "提交消息: $CommitMsg" -ForegroundColor Gray

$userMsg = Read-Host "自定义提交消息? (默认回车使用默认消息)"
if ($userMsg) {
    $CommitMsg = $userMsg
}

git commit -m $CommitMsg
Write-Status "代码已提交" "success"

# 显示后续步骤
Write-Header "GitHub 仓库设置"

Write-Host ""
Write-Host "⚠️  需要手动操作:"
Write-Host ""
Write-Host "1. 访问 GitHub 创建新仓库:"
Write-Host "   https://github.com/new"
Write-Host ""
Write-Host "2. 填写以下信息:"
Write-Host "   - Repository name: $RepoName"
Write-Host "   - Description: v4l2loopback kernel module for Redmi 13R 5G"
Write-Host "   - Visibility: Public (GitHub Actions 需要 Public)"
Write-Host "   - 取消勾选 'Initialize this repository with a README'"
Write-Host ""
Write-Host "3. 创建仓库后，执行下面的命令推送代码:"
Write-Host ""
Write-Host "   git branch -M main"
Write-Host "   git push -u origin main"
Write-Host ""

$continue = Read-Host "已在 GitHub 创建仓库? (y/n)"

if ($continue -eq "y") {
    Write-Host ""
    Write-Status "推送代码到 GitHub..."
    
    git branch -M main
    git push -u origin main
    
    Write-Status "推送成功！" "success"
    Write-Host ""
    Write-Host "GitHub Actions 已自动启动编译！"
    Write-Host ""
    Write-Host "查看编译进度:"
    Write-Host "  https://github.com/$GitHubUser/$RepoName/actions"
    Write-Host ""
    Write-Host "编译完成后，下载 v4l2loopback.ko:"
    Write-Host "  https://github.com/$GitHubUser/$RepoName/releases"
    Write-Host ""
} else {
    Write-Host ""
    Write-Status "请手动运行上面的命令来推送代码" "warning"
    Write-Host ""
}

Write-Header "后续步骤"

Write-Host ""
Write-Host "1. 等待 GitHub Actions 编译完成"
Write-Host "   预期时间："
Write-Host "   - 首次编译（无缓存）: 15-20 分钟"
Write-Host "   - 后续编译（有缓存）: 5-8 分钟"
Write-Host ""
Write-Host "2. 下载编译结果 (Releases 页面)"
Write-Host ""
Write-Host "3. 推送到设备:"
Write-Host "   adb push v4l2loopback.ko /data/local/tmp/"
Write-Host ""
Write-Host "4. 加载模块:"
Write-Host "   adb shell 'su -c \"insmod /data/local/tmp/v4l2loopback.ko\"'"
Write-Host ""
Write-Host "详见: GITHUB_ACTIONS_GUIDE.md"
Write-Host ""
