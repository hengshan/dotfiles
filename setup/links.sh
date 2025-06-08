#!/bin/bash

# 创建符号链接脚本
# 将 dotfiles 中的配置文件链接到用户目录

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[LINK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 获取 dotfiles 目录
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

log "Dotfiles 目录: $DOTFILES_DIR"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份并创建符号链接的函数
link_file() {
    local src="$1"
    local dest="$2"
    local dest_dir=$(dirname "$dest")
    
    # 创建目标目录
    mkdir -p "$dest_dir"
    
    # 如果目标文件已存在，先备份
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        log "备份现有文件: $dest"
        mv "$dest" "$BACKUP_DIR/"
    fi
    
    # 创建符号链接
    ln -sf "$src" "$dest"
    log "链接: $src -> $dest"
}

# 主要配置文件链接
link_config_files() {
    log "创建配置文件符号链接..."
    
    # Shell 配置
    if [ -f "$DOTFILES_DIR/shell/.zshrc" ]; then
        link_file "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
    fi
    
    if [ -f "$DOTFILES_DIR/shell/.bashrc" ]; then
        link_file "$DOTFILES_DIR/shell/.bashrc" "$HOME/.bashrc"
    fi
    
    # Git 配置
    if [ -f "$DOTFILES_DIR/config/git/.gitconfig" ]; then
        link_file "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
    fi
    
    if [ -f "$DOTFILES_DIR/config/git/.gitignore_global" ]; then
        link_file "$DOTFILES_DIR/config/git/.gitignore_global" "$HOME/.gitignore_global"
    fi
    
    # Neovim 配置
    if [ -d "$DOTFILES_DIR/config/nvim" ]; then
        link_file "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
    fi
    
    # Tmux 配置
    if [ -f "$DOTFILES_DIR/config/.tmux.conf" ]; then
        link_file "$DOTFILES_DIR/config/.tmux.conf" "$HOME/.tmux.conf"
    fi
    
    log "配置文件链接完成"
}

# 创建脚本目录链接
link_scripts() {
    if [ -d "$DOTFILES_DIR/scripts" ]; then
        log "创建脚本目录链接..."
        link_file "$DOTFILES_DIR/scripts" "$HOME/.local/bin/dotfiles-scripts"
        
        # 确保脚本可执行
        chmod +x "$DOTFILES_DIR/scripts"/*.sh 2>/dev/null || true
        
        log "脚本链接完成"
    fi
}

# 设置环境变量
setup_environment() {
    log "设置环境变量..."
    
    # 确保 ~/.local/bin 在 PATH 中
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null || true
    fi
    
    log "环境变量设置完成"
}

# 主执行函数
main() {
    log "开始创建符号链接..."
    
    link_config_files
    link_scripts
    setup_environment
    
    log "符号链接创建完成!"
    log "备份文件保存在: $BACKUP_DIR"
    
    if [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
        log "发现备份文件，如果新配置工作正常，可以删除备份目录"
    else
        rmdir "$BACKUP_DIR" 2>/dev/null || true
    fi
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
