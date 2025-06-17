#!/bin/bash

# Zsh 和 Oh My Zsh 安装配置脚本

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[ZSH]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# 安装 Zsh
install_zsh() {
    if command -v zsh &> /dev/null; then
        log "Zsh 已安装，跳过"
        return
    fi
    
    log "安装 Zsh..."
    sudo apt install -y zsh
    log "Zsh 安装完成"
}

# 安装 Oh My Zsh
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log "Oh My Zsh 已安装，跳过"
        return
    fi
    
    log "安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log "Oh My Zsh 安装完成"
}

# 安装 Zsh 插件
install_zsh_plugins() {
    local ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    
    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        log "安装 zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        log "安装 zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi
    
    # zsh-completions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
        log "安装 zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    fi
    
    log "Zsh 插件安装完成"
}

# 安装 Powerlevel10k 主题
install_powerlevel10k() {
    local ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    
    if [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        log "Powerlevel10k 已安装，跳过"
        return
    fi
    
    log "安装 Powerlevel10k 主题..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    log "Powerlevel10k 安装完成"
}

# 主安装流程
main() {
    log "开始配置 Zsh..."
    
    install_zsh
    install_oh_my_zsh
    install_zsh_plugins
    install_powerlevel10k
    
    log "Zsh 配置完成!"
    log "配置文件位置: ~/.zshrc"
    log "运行 'p10k configure' 来配置 Powerlevel10k 主题"
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
