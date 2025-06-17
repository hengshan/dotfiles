# Zsh 配置文件
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# 主题设置
ZSH_THEME="powerlevel10k/powerlevel10k"

# Powerlevel10k 即时提示模式
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 插件配置
plugins=(
    git
    docker
    docker-compose
    kubectl
    rust
    npm
    node
    python
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# 自动更新设置
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# 加载 Oh My Zsh
source $ZSH/oh-my-zsh.sh
# Powerlevel10k 配置
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===== 用户配置 =====

# 语言环境
# export LANG=en_US.UTF-8
# export LC_ALL=en_US.UTF-8

# 编辑器设置
export EDITOR='nvim'
export VISUAL='nvim'
set -o vi # Enable vi keybindings for Zsh
cd ~

# ===== 开发环境配置 =====

# Python/Conda
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
fi

# Rust
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Node.js/NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# UV (Python)
if [ -f "$HOME/.local/bin/uv" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Docker
if command -v docker &> /dev/null; then
    # Docker 补全
    fpath=($ZSH/completions $fpath)
#     if [ -f /usr/share/bash-completion/completions/docker ]; then
#         source /usr/share/bash-completion/completions/docker
#     fi
fi


# ===== 别名设置 =====

# 基础别名
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git 别名
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# 编辑器别名
alias v='nvim'
alias vim='nvim'

# 系统别名
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# 开发别名
alias py='python'
alias ipy='ipython'
alias jl='jupyter lab'
alias dc='docker compose'
alias k='kubectl'

# ===== 自定义函数 =====

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 快速查找文件
ff() {
    find . -name "*$1*" -type f
}

# 快速查找目录
fd() {
    find . -name "*$1*" -type d
}

# 快速 grep
ggg() {
    grep -r -i "$1" .
}

# Python 虚拟环境快速激活
activate() {
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
    elif [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
    elif [ -f "env/bin/activate" ]; then
        source env/bin/activate
    else
        echo "未找到虚拟环境"
    fi
}

# Git 快速提交
gac() {
    git add . && git commit -m "$1"
}

# 快速启动项目
dev() {
    if [ -f "package.json" ]; then
        npm run dev
    elif [ -f "Cargo.toml" ]; then
        cargo run
    elif [ -f "requirements.txt" ]; then
        python main.py
    else
        echo "未识别的项目类型"
    fi
}

# ===== 历史记录配置 =====
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ===== 自动补全增强 =====
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"


# ===== 加载自定义配置 =====
DOTFILES_DIR="$HOME/.dotfiles"

# 加载额外的 shell 配置
[ -f "$DOTFILES_DIR/shell/exports.sh" ] && source "$DOTFILES_DIR/shell/exports.sh"
[ -f "$DOTFILES_DIR/shell/functions.sh" ] && source "$DOTFILES_DIR/shell/functions.sh"
[ -f "$DOTFILES_DIR/shell/aliases.sh" ] && source "$DOTFILES_DIR/shell/aliases.sh"

# 加载本地配置（不纳入版本控制）
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# 让环境变量自动去重（zsh 特性）
typeset -U PATH LD_LIBRARY_PATH MANPATH FPATH

# 现在可以安全地添加路径，不用担心重复
export PATH="/snap/bin:$HOME/.local/bin:$PATH"
export PATH="/opt/nvim-linux-x86_64/bin:${PATH}"
export PATH="/usr/local/cuda/bin:${PATH}"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# MicroK8s
if command -v microk8s &> /dev/null; then
    alias mk='microk8s kubectl'
    alias k='kubectl'
    source <(microk8s kubectl completion zsh)  # 新增补全支持
fi
export PATH="$PATH:$HOME/.local/share/gem/ruby/3.2.0/bin"
