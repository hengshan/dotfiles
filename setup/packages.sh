#!/bin/bash

# 系统包安装脚本
# 配置 APT 镜像源并安装必要的系统包
# 支持中国/国外镜像源切换

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[PKG]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# 配置目录
CONFIG_DIR="$HOME/.config/apt-mirrors"
BACKUP_DIR="$CONFIG_DIR/backups"

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

# 检测是否为 Ubuntu 24.04+
is_ubuntu_24_04_or_later() {
    local ubuntu_version=$(get_ubuntu_version)
    [[ "$ubuntu_version" == "noble" ]] || [[ "$ubuntu_version" > "noble" ]]
}

# 获取地理位置（通过 IP）
detect_location() {
    local location=""

    # 尝试多个 IP 定位服务
    for service in "ipinfo.io/country" "ifconfig.co/country" "ip-api.com/line?fields=countryCode"; do
        location=$(curl -s --max-time 5 "$service" 2>/dev/null | tr -d '\n' | tr '[:lower:]' '[:upper:]')
        if [[ -n "$location" ]] && [[ ${#location} -eq 2 ]]; then
            echo "$location"
            return 0
        fi
    done

    warn "无法自动检测地理位置"
    return 1
}

# 创建配置目录
setup_directories() {
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$BACKUP_DIR"
}

# 备份当前源配置
backup_sources() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="${1:-auto_$timestamp}"

    log "备份当前源配置为: $backup_name"

    if is_ubuntu_24_04_or_later; then
        if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
            sudo cp /etc/apt/sources.list.d/ubuntu.sources "$BACKUP_DIR/ubuntu.sources.$backup_name"
            info "备份保存到: $BACKUP_DIR/ubuntu.sources.$backup_name"
        fi
    else
        if [ -f /etc/apt/sources.list ]; then
            sudo cp /etc/apt/sources.list "$BACKUP_DIR/sources.list.$backup_name"
            info "备份保存到: $BACKUP_DIR/sources.list.$backup_name"
        fi
    fi
}

# 恢复源配置
restore_sources() {
    local backup_name="$1"

    if [[ -z "$backup_name" ]]; then
        log "可用的备份:"
        ls -la "$BACKUP_DIR" 2>/dev/null | grep -E "sources\.list\.|ubuntu\.sources\." || echo "没有找到备份"
        return 1
    fi

    if is_ubuntu_24_04_or_later; then
        local backup_file="$BACKUP_DIR/ubuntu.sources.$backup_name"
        if [ -f "$backup_file" ]; then
            log "恢复备份: $backup_name"
            sudo cp "$backup_file" /etc/apt/sources.list.d/ubuntu.sources
            sudo apt update
            log "恢复成功"
        else
            error "备份文件不存在: $backup_file"
            return 1
        fi
    else
        local backup_file="$BACKUP_DIR/sources.list.$backup_name"
        if [ -f "$backup_file" ]; then
            log "恢复备份: $backup_name"
            sudo cp "$backup_file" /etc/apt/sources.list
            sudo apt update
            log "恢复成功"
        else
            error "备份文件不存在: $backup_file"
            return 1
        fi
    fi
}

# 配置官方源（国外使用）
configure_official_sources() {
    local ubuntu_version=$(get_ubuntu_version)

    log "配置官方 Ubuntu 源..."

    if is_ubuntu_24_04_or_later; then
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
        sudo tee /etc/apt/sources.list > /dev/null << EOF
# Ubuntu Official Sources
deb http://archive.ubuntu.com/ubuntu/ $ubuntu_version main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ $ubuntu_version-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ $ubuntu_version-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ $ubuntu_version-backports main restricted universe multiverse
EOF
    fi
}

# 配置清华大学源（中国）
configure_tsinghua_sources() {
    local ubuntu_version=$(get_ubuntu_version)

    log "配置清华大学镜像源..."

    if is_ubuntu_24_04_or_later; then
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
        sudo tee /etc/apt/sources.list > /dev/null << EOF
# Tsinghua University Mirror (China)
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $ubuntu_version main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $ubuntu_version-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $ubuntu_version-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $ubuntu_version-backports main restricted universe multiverse
EOF
    fi
}

# 配置阿里云源（中国备选）
configure_aliyun_sources() {
    local ubuntu_version=$(get_ubuntu_version)

    log "配置阿里云镜像源..."

    if is_ubuntu_24_04_or_later; then
        sudo tee /etc/apt/sources.list.d/ubuntu.sources > /dev/null << EOF
Types: deb
URIs: http://mirrors.aliyun.com/ubuntu
Suites: $ubuntu_version $ubuntu_version-updates $ubuntu_version-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://mirrors.aliyun.com/ubuntu
Suites: $ubuntu_version-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
    else
        sudo tee /etc/apt/sources.list > /dev/null << EOF
# Aliyun Mirror (China)
deb http://mirrors.aliyun.com/ubuntu/ $ubuntu_version main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ $ubuntu_version-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ $ubuntu_version-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ $ubuntu_version-backports main restricted universe multiverse
EOF
    fi
}

# 测试源的可用性
test_mirror() {
    log "测试镜像源连接..."
    if sudo apt update > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 自动配置最佳源
configure_best_mirror() {
    local location="${1:-$(detect_location)}"
    local fallback_to_official=true

    if [[ -n "$location" ]]; then
        info "检测到地理位置: $location"

        if [[ "$location" == "CN" ]]; then
            log "检测到中国，配置国内镜像源..."
            # 先尝试清华源
            configure_tsinghua_sources
            if test_mirror; then
                log "清华大学镜像源配置成功！"
                fallback_to_official=false
            else
                log "清华源不可用，尝试阿里云源..."
                configure_aliyun_sources
                if test_mirror; then
                    log "阿里云镜像源配置成功！"
                    fallback_to_official=false
                fi
            fi
        else
            log "检测到国外地区，使用官方源..."
        fi
    fi

    if $fallback_to_official; then
        configure_official_sources
        if test_mirror; then
            log "官方源配置成功！"
        else
            error "所有镜像源都不可用，请检查网络连接"
            return 1
        fi
    fi
}

# 配置 APT 镜像源（主函数）
configure_apt_mirrors() {
    local mode="${1:-auto}"

    # 备份当前配置
    backup_sources "auto_config_$(date +%Y%m%d_%H%M%S)"

    case "$mode" in
        china|cn)
            log "配置中国镜像源..."
            configure_tsinghua_sources
            if ! test_mirror; then
                log "清华源不可用，切换到阿里云源..."
                configure_aliyun_sources
                if ! test_mirror; then
                    warn "中国镜像源都不可用，尝试官方源..."
                    configure_official_sources
                    test_mirror || error "所有源都不可用"
                fi
            fi
            ;;
        abroad|overseas|official)
            log "配置官方源（国外）..."
            configure_official_sources
            test_mirror || error "官方源不可用"
            ;;
        auto)
            log "自动检测地理位置并配置..."
            configure_best_mirror
            ;;
        *)
            error "未知的镜像模式: $mode"
            echo "支持的模式: china, abroad, auto"
            return 1
            ;;
    esac

    log "镜像源配置完成！"
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
        rsync \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        pipx \
        libssl-dev libffi-dev libncurses-dev libreadline-dev libbz2-dev liblzma-dev libgdbm-dev tk-dev libzstd-dev \
        libsqlite3-dev libgdbm-dev

    log "installing neovim latest version"
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

# 显示当前源状态
show_current_mirror() {
    info "当前 APT 源配置:"
    echo "-------------------"

    if is_ubuntu_24_04_or_later; then
        if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
            grep -E "^URIs:" /etc/apt/sources.list.d/ubuntu.sources | head -2
        fi
    else
        if [ -f /etc/apt/sources.list ]; then
            grep -E "^deb " /etc/apt/sources.list | head -1
        fi
    fi

    echo "-------------------"

    # 识别当前源
    local source_type="未知"
    if is_ubuntu_24_04_or_later; then
        if grep -q "tsinghua\|tuna" /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null; then
            source_type="清华大学源 (中国)"
        elif grep -q "aliyun" /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null; then
            source_type="阿里云源 (中国)"
        elif grep -q "archive.ubuntu.com\|security.ubuntu.com" /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null; then
            source_type="官方源 (国外)"
        fi
    else
        if grep -q "tsinghua\|tuna" /etc/apt/sources.list 2>/dev/null; then
            source_type="清华大学源 (中国)"
        elif grep -q "aliyun" /etc/apt/sources.list 2>/dev/null; then
            source_type="阿里云源 (中国)"
        elif grep -q "archive.ubuntu.com\|security.ubuntu.com" /etc/apt/sources.list 2>/dev/null; then
            source_type="官方源 (国外)"
        fi
    fi

    info "当前使用: $source_type"
}

# 显示帮助信息
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help              显示此帮助信息
    -m, --mirror MODE       设置镜像源模式
                           MODE 可以是:
                           auto       - 自动选择 (默认)
                           china/cn   - 使用中国镜像源
                           abroad     - 使用官方源（国外）
    -b, --backup NAME       备份当前源配置
    -r, --restore NAME      恢复指定的备份
    -l, --list-backups      列出所有备份
    -s, --status            显示当前源状态
    --only-mirror           仅配置镜像源，不安装软件包

常用命令:
    $0                      # 自动配置并安装软件包
    $0 -m china --only-mirror   # 切换到中国源（不安装软件）
    $0 -m abroad --only-mirror  # 切换到国外源（不安装软件）
    $0 -s                   # 查看当前源状态
    $0 -b my_backup         # 备份当前配置
    $0 -r my_backup         # 恢复备份

快速切换镜像源:
    在中国: $0 -m china --only-mirror
    在国外: $0 -m abroad --only-mirror
EOF
}

# 主函数
main() {
    local only_mirror=false
    local mirror_mode=""

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -m|--mirror)
                mirror_mode="$2"
                shift 2
                ;;
            -b|--backup)
                setup_directories
                backup_sources "$2"
                exit 0
                ;;
            -r|--restore)
                setup_directories
                restore_sources "$2"
                exit 0
                ;;
            -l|--list-backups)
                setup_directories
                log "可用的备份:"
                ls -la "$BACKUP_DIR" 2>/dev/null | grep -E "sources\.list\.|ubuntu\.sources\." || echo "没有找到备份"
                exit 0
                ;;
            -s|--status)
                show_current_mirror
                exit 0
                ;;
            --only-mirror)
                only_mirror=true
                shift
                ;;
            *)
                error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # 开始执行
    log "开始配置系统..."

    # 设置目录
    setup_directories

    # 配置镜像源
    if [[ -n "$mirror_mode" ]]; then
        configure_apt_mirrors "$mirror_mode"
    else
        # 如果没有指定，使用自动模式
        configure_apt_mirrors "auto"
    fi

    # 如果不是仅配置镜像源，则安装软件包
    if ! $only_mirror; then
        install_basic_packages
        setup_tool_aliases
        install_fonts
        configure_git
        log "系统包安装和配置完成!"
    else
        log "镜像源配置完成!"
    fi
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
