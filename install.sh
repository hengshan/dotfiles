#!/bin/bash

# Dotfiles 安装脚本
# 适用于 Ubuntu/Debian 系统

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# 检查是否为 Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    error "此脚本仅支持 Ubuntu/Debian 系统"
    exit 1
fi

# 获取脚本所在目录
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

log "Dotfiles 目录: $DOTFILES_DIR"
log "备份目录: $BACKUP_DIR"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份现有配置文件
backup_if_exists() {
    local file="$1"
    if [ -f "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
        log "备份现有文件: $file"
        mv "$HOME/$file" "$BACKUP_DIR/"
    fi
}

header "开始安装 Dotfiles"

# 确认安装
read -p "是否继续安装? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "取消安装"
    exit 0
fi

# 更新包管理器
header "更新系统包"
sudo apt update

# 运行各模块安装脚本
header "安装系统包"
if [ -f "$DOTFILES_DIR/setup/packages.sh" ]; then
    chmod +x "$DOTFILES_DIR/setup/packages.sh"
    "$DOTFILES_DIR/setup/packages.sh"
else
    warn "未找到 packages.sh，跳过系统包安装"
fi

header "配置 Zsh"
if [ -f "$DOTFILES_DIR/setup/zsh.sh" ]; then
    chmod +x "$DOTFILES_DIR/setup/zsh.sh"
    "$DOTFILES_DIR/setup/zsh.sh"
else
    warn "未找到 zsh.sh，跳过 Zsh 配置"
fi

header "安装开发环境"
if [ -f "$DOTFILES_DIR/setup/development.sh" ]; then
    chmod +x "$DOTFILES_DIR/setup/development.sh"
    "$DOTFILES_DIR/setup/development.sh"
else
    warn "未找到 development.sh，跳过开发环境安装"
fi

header "创建符号链接"
if [ -f "$DOTFILES_DIR/setup/links.sh" ]; then
    chmod +x "$DOTFILES_DIR/setup/links.sh"
    "$DOTFILES_DIR/setup/links.sh"
else
    warn "未找到 links.sh，跳过符号链接创建"
fi

# 设置权限
header "设置脚本权限"
find "$DOTFILES_DIR/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

header "安装完成!"
log "备份文件保存在: $BACKUP_DIR"
log "请运行以下命令使 Zsh 配置生效:"
log "  source ~/.zshrc"
log "或者重新打开终端"

# 可选：自动切换到 zsh
if command -v zsh &> /dev/null; then
    echo
    read -p "是否现在切换到 Zsh? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chsh -s $(which zsh)
        log "已切换默认 shell 为 Zsh，请重新登录或重启终端"
    fi
fi

log "享受你的新开发环境吧! 🎉"
