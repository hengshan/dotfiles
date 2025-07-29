# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for Ubuntu/Debian systems with comprehensive development environment setup. The repository contains configuration files, setup scripts, and automation for setting up a complete development workspace with Neovim, Zsh, Python, Rust, Node.js, Docker, and other development tools.

## Core Architecture

### Main Installation System
- **`install.sh`**: Master installation script that orchestrates the entire setup process
- **`setup/`** directory: Contains modular setup scripts for different components
  - `packages.sh`: System packages and APT mirror configuration  
  - `development.sh`: Development tools (Miniconda, Rust, UV, Node.js, Docker)
  - `zsh.sh`: Zsh, Oh My Zsh, plugins, and Powerlevel10k theme
  - `links.sh`: Symbolic link creation for configuration files

### Configuration Structure
- **`config/`**: Application-specific configuration files
  - `nvim/`: Neovim configuration with extensive plugin setup
  - `git/`: Git configuration files
  - `ssh/`: SSH client configuration
  - `docker/`: Docker daemon configuration
- **`shell/`**: Shell configuration files
  - `.zshrc`: Main Zsh configuration with plugins and aliases

## Key Setup Commands

### Full System Setup
```bash
# Complete dotfiles installation
./install.sh

# Individual component setup
./setup/packages.sh      # Install system packages
./setup/development.sh   # Install dev tools
./setup/zsh.sh          # Configure Zsh
./setup/links.sh        # Create symlinks
```

### Development Environment Management
```bash
# Check available Conda environments
conda env list

# Activate/deactivate environments
conda activate <env_name>
conda deactivate

# Python package management with UV
uv init                 # Initialize new project
uv add <package>        # Add dependency
uv run <script>         # Run with dependencies
```

## Neovim Configuration

### Architecture
The Neovim setup (`config/nvim/init.vim`) is comprehensive and includes:
- **Plugin Manager**: vim-plug with auto-installation
- **LSP Setup**: Mason for LSP management with Python (Pyright, Ruff), TypeScript (ts_ls), and other language servers
- **Completion**: nvim-cmp with LuaSnip for snippets
- **Debugging**: nvim-dap with intelligent Python environment detection
- **UI**: Telescope for fuzzy finding, nvim-tree for file exploration

### Key Neovim Features
- **Claude Code Integration**: Built-in claude-code.nvim plugin
- **Smart Python Debugging**: Automatic detection of Conda environments and virtual environments
- **Advanced Folding**: UFO plugin with LSP and TreeSitter integration
- **Refactoring**: Built-in refactoring tools with Telescope integration

### Important Neovim Keybindings
- `<leader><leader>`: Toggle Claude Code
- `<leader>ff`: Find files (Telescope)
- `<leader>fg`: Live grep
- `<leader>e`: Toggle file tree
- `<F5>`: Start/continue debugging
- `<leader>dq`: Quick debug setup for Python projects

## Development Tools Integration

### Python Environment Detection
The system intelligently detects and configures Python environments:
1. Project-specific Conda environments (from `environment.yml`)
2. Currently activated Conda environments  
3. UV virtual environments (`.venv/`)
4. Standard Python virtual environments (`venv/`)

### Debugging Setup
For Python projects, the system automatically:
- Detects the appropriate Python interpreter
- Checks for debugpy installation
- Offers to install debugpy or use remote debugging
- Configures nvim-dap accordingly

### Docker Configuration
- Custom daemon configuration with registry mirrors
- Docker Compose support in Zsh plugins

## Common Development Tasks

### Setting Up New Python Project
```bash
# Using UV (preferred)
uv init my-project
cd my-project
uv add requests pandas  # Add dependencies
uv run main.py         # Run script

# Using Conda
conda create -n myproject python=3.11
conda activate myproject
pip install -r requirements.txt
```

### Neovim Development Workflow
1. Open project: `nvim .`
2. Use `<leader>ff` to find files
3. Set breakpoints with `<leader>b`
4. Start debugging with `<F5>`
5. Use `<leader>dq` for quick debug setup if needed

### Git Workflow Integration
The setup includes optimized Git configuration with:
- Global `.gitignore` patterns
- Editor set to Neovim
- Useful aliases in Zsh (gs, ga, gc, gp, etc.)

## Special Notes

### APT Mirror Configuration
The `packages.sh` script automatically configures Chinese mirrors (Tsinghua) with fallback to official repositories for better download speeds in certain regions.

### Font Installation
The setup automatically installs FiraCode Nerd Font for proper icon display in terminal applications.

### Backup System
All configuration scripts create timestamped backups before making changes, stored in `~/.dotfiles_backup_*` or `~/.config_backup_*` directories.

### SSH and Security
SSH configuration is handled with proper permissions (600 for config file, 700 for .ssh directory).

## Environment Variables and Paths

The setup configures several important environment variables:
- `EDITOR=nvim`
- `VISUAL=nvim`
- Conda initialization paths
- Rust Cargo paths (`~/.cargo/env`)
- NVM paths for Node.js
- UV binary paths (`~/.local/bin`)

## Language-Specific Notes

### Python
- Uses UV as primary package manager for new projects
- Conda for data science and complex environments
- Pyright + Ruff for LSP (type checking + linting)
- Automatic debugpy configuration for debugging

### JavaScript/TypeScript  
- NVM for Node.js version management
- ts_ls (TypeScript Language Server) + ESLint
- React/JSX support configured

### Rust
- Full Rust toolchain with rustup
- Clippy and rustfmt components installed
- Cargo environment automatically sourced