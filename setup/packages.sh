#!/bin/bash

# 系统包安装脚本
# 配置 APT 国内镜像源并安装必要的系统包

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[PKG]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检测 Ubuntu 版本
get_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$VERSION_CODENAME"
    else
        error "无法检测 Ubuntu 版本"
        exit 1
    fi
}

# 配置 APT 国内镜像源（自动回退）
configure_apt_mirrors() {
    local ubuntu_version=$(get_ubuntu_version)
    local is_ubuntu_24_04=false

    # 检查是否为 Ubuntu 24.04+
    if [[ "$ubuntu_version" == "noble" ]]; then
        is_ubuntu_24_04=true
    fi

    log "检测到 Ubuntu $ubuntu_version，配置 APT 国内镜像源..."

    # 备份原始源文件
#    if $is_ubuntu_24_04; then
#        sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.backup.$(date +%Y%m%d_%H%M%S)
#    else
#        sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%Y%m%d_%H%M%S)
#    fi

    # 配置清华大学镜像源（优先尝试）
    if $is_ubuntu_24_04; then
        # Ubuntu 24.04+ 使用 DEB822 格式
        sudo tee /etc/apt/sources.list.d/ubuntu.sources > /dev/null << EOF
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: $ubuntu_version $ubuntu_version-updates $ubuntu_version-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: $ubuntu_version-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
    else
        # 旧版 Ubuntu 使用传统格式
        sudo tee /etc/apt/sources.list > /dev/null << EOF
# 清华大学镜像源
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $ubuntu_version main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $ubuntu_version-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $ubuntu_version-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $ubuntu_version-backports main restricted universe multiverse
EOF
    fi

    log "尝试使用清华大学镜像源..."
    if ! sudo apt update > /dev/null 2>&1; then
        log "清华大学镜像源访问失败，自动回退到官方源..."

        if $is_ubuntu_24_04; then
            # Ubuntu 24.04+ 回退到官方源
            sudo tee /etc/apt/sources.list.d/ubuntu.sources > /dev/null << EOF
Types: deb
URIs: http://archive.ubuntu.com/ubuntu
Suites: $ubuntu_version $ubuntu_version-updates $ubuntu_version-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://security.ubuntu.com/ubuntu
Suites: $ubuntu_version-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
        else
            # 旧版 Ubuntu 回退到官方源
            sudo tee /etc/apt/sources.list > /dev/null << EOF
# 官方默认源
deb http://archive.ubuntu.com/ubuntu/ $ubuntu_version main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ $ubuntu_version-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ $ubuntu_version-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ $ubuntu_version-backports main restricted universe multiverse
EOF
        fi

        log "已切换至官方源，正在更新软件包索引..."
        sudo apt update
    else
        log "清华大学镜像源配置成功！"
    fi
}

# 安装基础系统包
install_basic_packages() {
    log "更新包列表..."
    sudo apt update
    
    log "安装基础系统包..."
    sudo apt install -y \
        curl \
        wget \
        git \
        vim \
        zsh \
        tmux \
        htop \
        tree \
        unzip \
        zip \
        build-essential \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        jq \
        ripgrep \
        fd-find \
        bat \
        eza \
        fzf \
        silversearcher-ag \
        ncdu \
        duf \
        tldr \
        rsync
    
    log "installing neovim latesti version"
    install_latest_neovim

    log "基础包安装完成"
}

install_latest_neovim() {
    log "Installing latest Neovim from GitHub pre-built binaries..."

    # Download and extract
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz

    # Ensure the bin path is in PATH for this session
    export PATH="/opt/nvim-linux-x86_64/bin:$PATH"

    # Add it permanently for future shells
    SHELL_RC="$HOME/.zshrc"  # Change to .bashrc if using Bash
    if ! grep -q "/opt/nvim-linux-x86_64/bin" "$SHELL_RC"; then
      echo 'export PATH="/opt/nvim-linux-x86_64/bin:$PATH"' >> "$SHELL_RC"
      log "Updated $SHELL_RC to include Neovim path."
    fi

    log "Neovim version installed: $(nvim --version | head -n 1)"
}

# 配置一些工具的别名
setup_tool_aliases() {
    log "设置工具别名..."
    
    # 为 bat 创建别名 (Ubuntu 中叫 batcat)
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
    fi
    
    # 为 fd 创建别名 (Ubuntu 中叫 fdfind)
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
    fi
    
    log "工具别名设置完成"
}

# 安装一些有用的字体
install_fonts() {
    log "安装 Nerd Fonts..."

    mkdir -p ~/.local/share/fonts
    cd /tmp

    # 安装 FiraCode Nerd Font
    if [ ! -f ~/.local/share/fonts/FiraCodeNerdFont-Regular.ttf ]; then
        log "安装 FiraCode Nerd Font..."
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
        unzip -q FiraCode.zip -d FiraCode
        cp FiraCode/*.ttf ~/.local/share/fonts/
        rm -rf FiraCode FiraCode.zip
    fi

    # 刷新字体缓存
    fc-cache -fv

    log "Nerd Fonts 安装完成"
}

# 配置 Git 全局设置
configure_git() {
    log "配置 Git 全局设置..."
    
    # 如果还没有配置用户信息，提示用户输入
    if ! git config --global user.name &> /dev/null; then
        echo "请输入你的 Git 用户名:"
        read -r git_username
        git config --global user.name "$git_username"
    fi
    
    if ! git config --global user.email &> /dev/null; then
        echo "请输入你的 Git 邮箱:"
        read -r git_email
        git config --global user.email "$git_email"
    fi
    
    # 设置一些有用的 Git 配置
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor nvim
    git config --global color.ui auto
    git config --global push.default simple
    
    log "Git 配置完成"
}

# 主安装流程
main() {
    log "开始安装系统包..."
    
    configure_apt_mirrors
    install_basic_packages
    setup_tool_aliases
    install_fonts
    configure_git
    
    log "系统包安装和配置完成!"
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
