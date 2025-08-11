# Modern C++ Development Setup for Neovim

This document describes the enhanced C++ development environment with CMake Tools, Overseer, and ToggleTerm.

## 🚀 New Features Added

### 1. CMake Tools (`cmake-tools.nvim`)
- **Auto-detect CMake projects** when opening `CMakeLists.txt`
- **Intelligent build management** with target selection
- **Integrated debugging** with DAP auto-configuration
- **Compile commands database** management

### 2. Overseer (`overseer.nvim`) 
- **Task runner** with visual feedback
- **Custom build templates** for C/C++ projects
- **Quickfix integration** for error navigation
- **Background task management**

### 3. ToggleTerm (`toggleterm.nvim`)
- **Multiple persistent terminals**
- **Floating terminal** support
- **Language-specific REPLs** (Python, Node.js)
- **Enhanced terminal workflow**

## 🎯 Key Mappings

### CMake Operations
| Key | Description |
|-----|-------------|
| `<leader>cg` | CMake Generate |
| `<leader>cb` | CMake Build |
| `<leader>cr` | CMake Run |
| `<leader>cd` | CMake Debug |
| `<leader>cs` | Select Build Type (Debug/Release) |
| `<leader>ct` | Select Build Target |
| `<leader>cc` | CMake Clean |

### Terminal Management
| Key | Description |
|-----|-------------|
| `<C-\>` | Toggle Terminal |
| `<leader>tf` | Toggle Float Terminal |
| `<leader>th` | Toggle Horizontal Terminal |
| `<leader>tv` | Toggle Vertical Terminal |
| `<leader>t1/2/3` | Toggle Specific Terminal |
| `<leader>gg` | Toggle Lazygit |
| `<leader>tp` | Toggle Python REPL |
| `<leader>tn` | Toggle Node.js REPL |

### Task Management
| Key | Description |
|-----|-------------|
| `<leader>or` | Overseer Run Task |
| `<leader>ot` | Overseer Toggle |
| `<leader>oi` | Overseer Info |

### Debugging (Simplified)
| Key | Description |
|-----|-------------|
| `<leader>db` | Toggle Breakpoint |
| `<F5>` | Start/Continue Debug |
| `<F10>` | Step Over |
| `<F11>` | Step Into |
| `<F12>` | Step Out |

## 🏗️ Workflow Examples

### Quick C++ Project Setup
```bash
# 1. Create new project
mkdir my_cpp_project && cd my_cpp_project

# 2. Open in Neovim  
nvim .

# 3. Initialize CMake project
:CMakeInit

# 4. Generate build files
<leader>cg

# 5. Build project
<leader>cb

# 6. Run project
<leader>cr
```

### Debugging Workflow
```bash
# 1. Open C++ file
nvim main.cpp

# 2. Set breakpoints
<leader>db  # on desired lines

# 3. Start debugging (auto-compiles if needed)
<F5>

# 4. Debug navigation
<F10>  # Step over
<F11>  # Step into  
<F12>  # Step out
```

### Terminal Workflow
```bash
# 1. Quick terminal access
<C-\>  # Toggle terminal

# 2. Floating terminal for quick commands
<leader>tf

# 3. Multiple terminals for different tasks
<leader>t1  # Terminal 1 (build)
<leader>t2  # Terminal 2 (run)
<leader>t3  # Terminal 3 (git)

# 4. Language-specific REPLs
<leader>tp  # Python REPL
<leader>tn  # Node.js REPL
```

## 🛠️ Available Commands

### CMake Commands
- `:CMakeGenerate` - Generate build files
- `:CMakeBuild` - Build project
- `:CMakeRun` - Run project
- `:CMakeDebug` - Debug project
- `:CMakeClean` - Clean build files
- `:CMakeInit` - Initialize new CMake project
- `:CMakeStatus` - Show project status

### Overseer Commands  
- `:OverseerRun` - Run task
- `:OverseerToggle` - Toggle task window
- `:OverseerInfo` - Show task info
- `:OverseerQuickRun` - Quick build current file
- `:OverseerStatus` - Show task status

### ToggleTerm Commands
- `:ToggleTerm` - Toggle terminal
- `:TermBuild [cmd]` - Run build command in terminal
- `:TermCompile` - Compile and run current file
- `:TermSend <id> <cmd>` - Send command to terminal

## 🔧 Configuration Details

### Debug Configurations (Simplified)
1. **🚀 Quick Launch (LLDB)** - Modern C++ debugging
2. **🔧 Quick Launch (GDB)** - Traditional debugging  
3. **🎯 Launch with Arguments** - Debug with program arguments

### Build Integration
- **Auto-compilation** before debugging
- **Compile commands database** for LSP
- **Error navigation** with quickfix
- **Background builds** with visual feedback

## 🆚 Compared to Previous Setup

### Before
- Manual CMake commands
- Single terminal workflow
- Complex debug configurations (8 options)
- Manual compilation management

### After  
- Integrated CMake workflow
- Multiple persistent terminals
- Simplified debug configurations (3 options)
- Automatic compilation and database management
- Enhanced task management
- Better error handling and feedback

## 🏃‍♂️ Getting Started

1. **Restart Neovim** to load new plugins
2. **Open a C++ project** or create one with `:CMakeInit`
3. **Try the key mappings** listed above
4. **Check the test project** at `/tmp/test_cmake_project/`

The setup automatically detects CMake projects and provides helpful notifications for available commands.

---
*Modern C++ Development Environment - Enhanced with cmake-tools.nvim, overseer.nvim, and toggleterm.nvim*