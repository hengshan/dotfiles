#!/bin/bash

# 开发环境安装脚本
# 安装 Python, Rust, Node.js, Docker 等开发工具

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[DEV]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 安装 Miniconda
install_miniconda() {
    if command_exists conda; then
        log "Miniconda 已安装，跳过"
        return
    fi
    if [ -d "$HOME/miniconda3" ] || [ -d "$HOME/anaconda3" ]; then
        log "Miniconda/Anaconda 已安装"
	return
    fi
    log "安装 Miniconda..."
    cd /tmp
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p "$HOME/miniconda3"
    rm miniconda.sh

    # 添加到 PATH
    echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/miniconda3/bin:$PATH"

    # 初始化 conda
    conda init bash
    conda init zsh 2>/dev/null || true

    log "Miniconda 安装完成"
}

# 安装 Rust first. Before UV.
install_rust() {
    if command_exists rustc; then
        log "Rust 已安装，跳过"
        return
    fi

    # 检查 .cargo 目录是否存在
    if [ -d "$HOME/.cargo" ]; then
        log "Rust 目录已存在, 跳过"
	return
    fi

    log "安装 Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"

    # 安装常用组件
    rustup component add clippy rustfmt

    log "Rust 安装完成"
}

# 安装 UV (Python 包管理器)
install_uv() {
    # 检查 UV 是否已安装在常见位置
    if [ -f "$HOME/.cargo/bin/uv" ] || [ -f "$HOME/.local/bin/uv" ]; then
        log "UV 目录已存在, 跳过"
	return
    fi

    if command_exists uv; then
        log "UV 已安装，跳过"
        return
    fi

    log "安装 UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source "$HOME/.cargo/env"
    log "UV 安装完成"
}

# 安装 Python 开发工具 (ruff, debugpy)
install_python_dev_tools() {
    log "安装 Python 开发工具 (ruff, debugpy)..."

    # 确保 pipx 可用
    if ! command_exists pipx; then
        error "pipx 未安装，请先运行 packages.sh"
        return 1
    fi

    # 使用 pipx 安装全局 Python 工具
    log "使用 pipx 安装开发工具..."
    pipx install ruff 2>/dev/null || log "ruff 可能已存在"
    pipx install debugpy 2>/dev/null || log "debugpy 可能已存在"
    pipx install poetry 2>/dev/null || log "poetry 可能已存在"
    pipx install black 2>/dev/null || log "black 可能已存在"
    pipx install mypy 2>/dev/null || log "mypy 可能已存在"
    pipx install cmake-init 2>/dev/null || log "mypy 可能已存在"
    pipx install conan 2>/dev/null || log "mypy 可能已存在"
    pipx install cookiecutter 2>/dev/null || log "cookiecutter 可能已存在"

    log "Python 开发工具安装完成"
}

# 安装 NVM 和 Node.js
install_node() {
    if [ -d "$HOME/.nvm" ]; then
        log "NVM 已安装，跳过"
        return
    fi

    log "安装 NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    # 加载 NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # 安装最新 LTS Node.js
    log "安装 Node.js LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*

    # 安装常用全局包
    npm install -g typescript @types/node prettier eslint

    log "Node.js 安装完成"
}

# 安装 Docker
install_docker() {
    if command_exists docker; then
        log "Docker 已安装，跳过"
        return
    fi

    log "安装 Docker..."

# 安装必要包
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl

# 添加 Docker 官方 GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 添加仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 添加用户到 docker 组
sudo usermod -aG docker $USER

echo "Docker 安装完成，请重新登录以使用 Docker"
}


# 主安装流程
main() {
    log "开始安装开发环境..."

    # 按顺序安装各个工具
    install_miniconda
    install_rust
    install_uv
    install_python_dev_tools
    install_node
    install_docker

    log "所有开发工具安装完成!"
    log "请运行以下命令重新加载环境:"
    log "  source ~/.bashrc"
    log "或重新打开终端"
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
