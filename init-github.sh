#!/bin/bash
# GitHub Actions CI/CD 设置脚本
# 用于将项目推送到 GitHub 仓库

set -e

echo "=========================================="
echo "v4l2loopback GitHub 仓库初始化"
echo "=========================================="
echo ""

# 检查必要工具
if ! command -v git &> /dev/null; then
    echo "❌ git 未安装，请先安装 git"
    exit 1
fi

# 检查 GitHub 凭证
echo "验证 GitHub 配置..."
if ! git config --global user.email &> /dev/null; then
    echo "❌ 未配置 GitHub 用户邮箱"
    echo "请运行："
    echo "  git config --global user.email 'your-email@example.com'"
    echo "  git config --global user.name 'Your Name'"
    exit 1
fi

echo "✓ GitHub 配置已验证"
echo ""

# 获取仓库信息
echo "请输入以下信息："
read -p "GitHub 用户名: " GITHUB_USER
read -p "仓库名称 (默认: v4l2loopback-redmi13r): " REPO_NAME
REPO_NAME=${REPO_NAME:-v4l2loopback-redmi13r}

REPO_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

echo ""
echo "仓库信息："
echo "  URL: $REPO_URL"
echo ""

# 初始化 git 仓库（如果还没有）
if [ ! -d .git ]; then
    echo "初始化本地 Git 仓库..."
    git init
    git config user.email "$(git config --global user.email)"
    git config user.name "$(git config --global user.name)"
    
    # 添加 remote
    git remote add origin "$REPO_URL"
else
    echo "Git 仓库已存在"
    
    # 检查是否已有 origin
    if ! git remote | grep -q origin; then
        git remote add origin "$REPO_URL"
        echo "✓ 添加 remote: origin"
    fi
fi

echo ""
echo "准备提交..."

# 添加文件
git add .

# 提交
if git diff --cached --quiet; then
    echo "❌ 没有文件需要提交"
    exit 1
fi

echo ""
echo "输入提交信息 (默认: 'Initial commit with v4l2loopback build pipeline')："
read -p "提交信息: " COMMIT_MSG
COMMIT_MSG=${COMMIT_MSG:-"Initial commit with v4l2loopback build pipeline"}

git commit -m "$COMMIT_MSG"

echo ""
echo "=========================================="
echo "现在需要手动操作："
echo "=========================================="
echo ""
echo "1. 在 GitHub 上创建新的私有仓库:"
echo "   https://github.com/new"
echo "   - Repository name: $REPO_NAME"
echo "   - 不勾选 'Initialize this repository with a README'"
echo ""
echo "2. 创建完成后，执行以下命令推送："
echo ""
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. GitHub Actions 会自动触发编译！"
echo ""
echo "=========================================="
echo ""

read -p "已创建仓库? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "推送到 GitHub..."
    git branch -M main
    git push -u origin main
    
    echo ""
    echo "✓ 推送成功！"
    echo ""
    echo "查看编译进度："
    echo "  https://github.com/${GITHUB_USER}/${REPO_NAME}/actions"
    echo ""
else
    echo "请手动执行上面的命令来推送代码"
fi
