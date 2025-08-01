-- ============================================================================
-- Advanced C/C++ Compilation and Debugging System
-- Restored from original configuration with enhancements
-- ============================================================================

local M = {}

-- ============================================================================
-- CMake Project Detection and Management
-- ============================================================================

-- Function to check if current directory is a CMake project
local function is_cmake_project()
  return vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 1
end

-- Function to find CMake build directory
local function find_cmake_build_dir()
  local cwd = vim.fn.getcwd()
  local possible_dirs = {
    cwd .. "/build",
    cwd .. "/cmake-build-debug", 
    cwd .. "/cmake-build-release",
    cwd .. "/out/build"
  }
  for _, dir in ipairs(possible_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      return dir
    end
  end
  return nil
end

-- Function to find executables in CMake build directory
local function find_cmake_executables(build_dir)
  if not build_dir then return {} end
  local executables = {}
  local handle = io.popen("find " .. vim.fn.shellescape(build_dir) .. " -type f -executable -not -path '*/CMakeFiles/*' 2>/dev/null")
  if handle then
    for line in handle:lines() do
      if not line:match("%.so$") and not line:match("%.a$") and 
         not line:match("/cmake$") and not line:match("/cpack$") and not line:match("/ctest$") then
        table.insert(executables, line)
      end
    end
    handle:close()
  end
  return executables
end

-- ============================================================================
-- Compilation System
-- ============================================================================

-- Function to find or compile C/C++ executable
local function find_or_compile_cpp_executable()
  local cwd = vim.fn.getcwd()
  local current_file = vim.fn.expand('%:p')
  local file_stem = vim.fn.expand('%:t:r')  -- filename without extension

  -- CMake project detection
  if is_cmake_project() then
    vim.notify("🏗️  CMake project detected", vim.log.levels.INFO)
    
    local build_dir = find_cmake_build_dir()
    if not build_dir then
      local choice = vim.fn.confirm("No build dir found. Create?", "&Debug\n&Release\n&Cancel", 1)
      if choice == 1 or choice == 2 then
        build_dir = cwd .. "/build"
        vim.fn.mkdir(build_dir, "p")
        local build_type = choice == 1 and "Debug" or "Release"
        local result = vim.fn.system("cd " .. vim.fn.shellescape(build_dir) .. " && cmake -DCMAKE_BUILD_TYPE=" .. build_type .. " ..")
        if vim.v.shell_error ~= 0 then
          vim.notify("❌ CMake config failed: " .. result, vim.log.levels.ERROR)
          return nil
        end
      else
        return nil
      end
    end
    
    -- Build
    vim.notify("🔨 Building CMake project...", vim.log.levels.INFO)
    local build_result = vim.fn.system("cd " .. vim.fn.shellescape(build_dir) .. " && make -j$(nproc)")
    if vim.v.shell_error ~= 0 then
      vim.notify("❌ Build failed: " .. build_result, vim.log.levels.ERROR)
      return nil
    end
    
    -- Find executable
    local executables = find_cmake_executables(build_dir)
    if #executables == 1 then
      vim.notify("✅ Found: " .. executables[1], vim.log.levels.INFO)
      return executables[1]
    elseif #executables > 1 then
      -- Let user select
      vim.notify("Multiple executables found, using first one: " .. executables[1], vim.log.levels.INFO)
      return executables[1]
    else
      vim.notify("❌ No executables found in build directory", vim.log.levels.ERROR)
      return nil
    end
  end
  
  -- Non-CMake project: check for existing executable
  local possible_executables = {
    cwd .. "/" .. file_stem,          -- Same name as source file (hello.cpp -> hello)
    cwd .. "/a.out",                  -- Default gcc output
    cwd .. "/main",                   -- Common name
    cwd .. "/program",                -- Generic name
    cwd .. "/" .. file_stem .. ".out", -- filename.out
    cwd .. "/" .. file_stem .. ".exe"  -- filename.exe (some people use this)
  }
  
  for _, exec_path in ipairs(possible_executables) do
    if vim.fn.executable(exec_path) == 1 then
      vim.notify("✅ Found existing executable: " .. exec_path, vim.log.levels.INFO)
      return exec_path
    end
  end
  
  -- No executable found, offer to compile
  local choice = vim.fn.confirm(
    "No executable found. Compile " .. current_file .. "?",
    "&g++ (C++)\n&gcc (C)\n&Cancel",
    1
  )
  
  if choice == 1 then -- g++
    local output_name = cwd .. "/" .. file_stem
    local compile_cmd = string.format("g++ -g -O0 -Wall -std=c++17 -fno-omit-frame-pointer -DDEBUG -o %s %s", vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
    vim.notify("🔨 Compiling with debug info: " .. compile_cmd, vim.log.levels.INFO)
    
    local result = vim.fn.system(compile_cmd)
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ Compilation successful!", vim.log.levels.INFO)
      return output_name
    else
      vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
      return nil
    end
  elseif choice == 2 then -- gcc
    local output_name = cwd .. "/" .. file_stem
    local compile_cmd = string.format("gcc -g -O0 -Wall -fno-omit-frame-pointer -DDEBUG -o %s %s", vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
    vim.notify("🔨 Compiling with debug info: " .. compile_cmd, vim.log.levels.INFO)
    
    local result = vim.fn.system(compile_cmd)
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ Compilation successful!", vim.log.levels.INFO)
      return output_name
    else
      vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
      return nil
    end
  end
  
  return nil
end

-- ============================================================================
-- GDB Setup and Configuration
-- ============================================================================

-- Function to check if GDB is available
local function ensure_gdb_available()
  if vim.fn.executable("gdb") ~= 1 then
    vim.notify("❌ GDB not found. Please install gdb: sudo apt install gdb", vim.log.levels.ERROR)
    return false
  end
  return true
end

-- Function to configure DAP for C/C++ debugging
function M.configure_dap_cpp()
  if not ensure_gdb_available() then
    return false
  end
  
  local dap = require('dap')
  
  -- Clear existing C/C++ configurations to prevent duplication
  dap.configurations.c = {}
  dap.configurations.cpp = {}
  
  -- GDB adapter configuration with better error handling
  dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap", "--quiet", "--nx" },
    env = {
      TERM = "xterm-256color"  -- Ensure proper terminal support
    },
    options = {
      initialize_timeout_sec = 30,  -- Give GDB more time to start
      disconnect_timeout_sec = 10
    }
  }
  
  -- Alternative: cppdbg adapter (if gdb DAP doesn't work)
  dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = 'gdb',
    args = { '-i', 'dap' },
    options = {
      detached = false
    }
  }
  
  -- Comprehensive C/C++ configurations
  local cpp_config = {
    {
      name = "Launch (Simple/Reliable)",
      type = "gdb",
      request = "launch",
      program = function()
        local cwd = vim.fn.getcwd()
        local current_file = vim.fn.expand('%:p')
        local file_stem = vim.fn.expand('%:t:r')
        local output_name = cwd .. "/" .. file_stem
        
        -- Simple compilation
        local is_cpp = current_file:match("%.cpp$") or current_file:match("%.cxx$") or current_file:match("%.cc$")
        local compiler = is_cpp and "g++" or "gcc"
        local std_flag = is_cpp and "-std=c++17" or ""
        
        local compile_cmd = string.format("%s -g -O0 -Wall %s -o %s %s", 
          compiler, std_flag, vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
        
        vim.notify("🔨 Simple compile: " .. compile_cmd, vim.log.levels.INFO)
        local result = vim.fn.system(compile_cmd)
        
        if vim.v.shell_error == 0 then
          vim.notify("✅ Compilation successful!", vim.log.levels.INFO)
          return output_name
        else
          vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
          return nil
        end
      end,
      cwd = '${workspaceFolder}',
      stopAtEntry = false,
      args = {},
      runInTerminal = false,
      setupCommands = {
        {
          description = "Enable pretty-printing",
          text = "set print pretty on",
          ignoreFailures = true
        }
      }
    },
    {
      name = "Launch (Auto-detect/Compile)",
      type = "gdb",
      request = "launch",
      program = find_or_compile_cpp_executable,
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
      args = function()
        local args_str = vim.fn.input('Program arguments (press Enter if none needed): ')
        if args_str == "" then
          return {}
        end
        return vim.split(args_str, " ", {plain = true})
      end,
      runInTerminal = true,   -- Use external terminal for real-time output
      console = "integratedTerminal",
      setupCommands = {
        {
          description = "Enable pretty-printing for gdb",
          text = "set print pretty on",
          ignoreFailures = true
        },
        {
          description = "Set disassembly-flavor to intel",
          text = "set disassembly-flavor intel",
          ignoreFailures = true
        },
        {
          description = "Disable address space layout randomization",
          text = "set disable-randomization on",
          ignoreFailures = true
        },
        {
          description = "Set source directory search paths",
          text = "directory .",
          ignoreFailures = true
        },
        {
          description = "Enable auto-loading of debug info",
          text = "set auto-load safe-path /",
          ignoreFailures = true
        },
        {
          description = "Set substitute path for source files",
          text = "set substitute-path /usr/src /usr/src",
          ignoreFailures = true
        }
      },
      miDebuggerPath = "gdb",
      miMode = "gdb",
      preLaunchTask = "",  -- No pre-launch task needed
    },
    {
      name = "Launch (External Terminal)",
      type = "gdb",
      request = "launch",
      program = find_or_compile_cpp_executable,
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
      args = function()
        local args_str = vim.fn.input('Program arguments: ')
        if args_str == "" then
          return {}
        end
        return vim.split(args_str, " ", {plain = true})
      end,
      runInTerminal = true,   -- Use external terminal for input
      console = "externalTerminal",
    },
    {
      name = "Attach to Process",
      type = "gdb",
      request = "attach",
      pid = function()
        return tonumber(vim.fn.input('Process ID: '))
      end,
      cwd = '${workspaceFolder}',
    },
    {
      name = "Launch with Core Dump",
      type = "gdb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      coreFile = function()
        return vim.fn.input('Path to core dump: ', vim.fn.getcwd() .. '/', 'file')
      end,
    },
    {
      name = "Launch CMake (Force rebuild)",
      type = "gdb",
      request = "launch",
      program = function()
        if not is_cmake_project() then
          vim.notify("❌ Not a CMake project", vim.log.levels.ERROR)
          return nil
        end
        local build_dir = find_cmake_build_dir() or (vim.fn.getcwd() .. "/build")
        vim.notify("🔨 Force rebuilding...", vim.log.levels.INFO)
        vim.fn.system("cd " .. vim.fn.shellescape(build_dir) .. " && make clean && make -j$(nproc)")
        if vim.v.shell_error ~= 0 then
          vim.notify("❌ Rebuild failed", vim.log.levels.ERROR)
          return nil
        end
        local executables = find_cmake_executables(build_dir)
        return executables[1] or nil
      end,
      cwd = '${workspaceFolder}',
      args = function()
        local args_str = vim.fn.input('Program arguments: ')
        if args_str == "" then
          return {}
        end
        return vim.split(args_str, " ", {plain = true})
      end,
      runInTerminal = false,
    },
    {
      name = "Launch (Alternative - cppdbg)",
      type = "cppdbg",
      request = "launch",
      program = find_or_compile_cpp_executable,
      cwd = '${workspaceFolder}',
      stopAtEntry = false,
      args = function()
        local args_str = vim.fn.input('Program arguments (press Enter if none needed): ')
        if args_str == "" then
          return {}
        end
        return vim.split(args_str, " ", {plain = true})
      end,
      environment = {},
      externalConsole = false,
      MIMode = "gdb",
      miDebuggerPath = "gdb",
      setupCommands = {
        {
          description = "Enable pretty-printing for gdb",
          text = "-enable-pretty-printing",
          ignoreFailures = true
        }
      }
    }
  }
  
  dap.configurations.c = cpp_config
  dap.configurations.cpp = cpp_config
  
  -- vim.notify("✅ GDB debugging configured for C/C++", vim.log.levels.DEBUG)
  -- vim.notify("💡 Launch options:", vim.log.levels.DEBUG)
  -- vim.notify("  • 'Launch (Auto-detect/Compile)' - integrated terminal", vim.log.levels.DEBUG)
  -- vim.notify("  • 'Launch (External Terminal)' - for std::cin/getline input", vim.log.levels.DEBUG)
  -- vim.notify("  • 'Attach to Process' - debug running process", vim.log.levels.DEBUG)
  -- vim.notify("  • 'Launch with Core Dump' - analyze crash dumps", vim.log.levels.DEBUG)
  -- vim.notify("  • 'Launch CMake (Force rebuild)' - rebuild and debug", vim.log.levels.DEBUG)
  
  return true
end

-- ============================================================================
-- Interactive C/C++ Debugging Functions
-- ============================================================================

-- Quick launch function for interactive C/C++ programs (external terminal)
function M.debug_cpp_interactive()
  if vim.bo.filetype ~= "c" and vim.bo.filetype ~= "cpp" then
    vim.notify("❌ This function is for C/C++ files only", vim.log.levels.ERROR)
    return
  end
  
  if not M.configure_dap_cpp() then
    return
  end
  
  local dap = require('dap')
  -- Start debugging with external terminal configuration (2nd config)
  dap.run(dap.configurations.cpp[2])
end

-- Function to force recompile C/C++ with debug info
function M.force_recompile_cpp()
  local cwd = vim.fn.getcwd()
  local current_file = vim.fn.expand('%:p')
  local file_stem = vim.fn.expand('%:t:r')
  
  if vim.bo.filetype ~= "cpp" and vim.bo.filetype ~= "c" then
    vim.notify("❌ This function is for C/C++ files only", vim.log.levels.ERROR)
    return
  end
  
  local choice = vim.fn.confirm(
    "Force recompile " .. current_file .. " with debug info?",
    "&g++ (C++)\n&gcc (C)\n&Cancel",
    1
  )
  
  if choice == 1 then -- g++
    local output_name = cwd .. "/" .. file_stem
    local compile_cmd = string.format("g++ -g -Wall -std=c++17 -o %s %s", vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
    vim.notify("🔨 Force compiling: " .. compile_cmd, vim.log.levels.INFO)
    
    local result = vim.fn.system(compile_cmd)
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ Force compilation successful! Ready for debugging.", vim.log.levels.INFO)
      -- Automatically configure debugging after successful compilation
      M.configure_dap_cpp()
    else
      vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
    end
  elseif choice == 2 then -- gcc
    local output_name = cwd .. "/" .. file_stem
    local compile_cmd = string.format("gcc -g -Wall -o %s %s", vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
    vim.notify("🔨 Force compiling: " .. compile_cmd, vim.log.levels.INFO)
    
    local result = vim.fn.system(compile_cmd)
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ Force compilation successful! Ready for debugging.", vim.log.levels.INFO)
      -- Automatically configure debugging after successful compilation
      M.configure_dap_cpp()
    else
      vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
    end
  elseif choice == 3 then -- Quit
    vim.notify("❌ Compilation cancelled.", vim.log.levels.INFO)
  end
end

-- ============================================================================
-- Build System Integration
-- ============================================================================

-- Function to build current project (CMake or simple compilation)
function M.build_project()
  if is_cmake_project() then
    local build_dir = find_cmake_build_dir()
    if not build_dir then
      vim.notify("❌ No build directory found. Run CMake first.", vim.log.levels.ERROR)
      return false
    end
    
    vim.notify("🔨 Building CMake project...", vim.log.levels.INFO)
    local result = vim.fn.system("cd " .. vim.fn.shellescape(build_dir) .. " && make -j$(nproc)")
    if vim.v.shell_error == 0 then
      vim.notify("✅ Build successful!", vim.log.levels.INFO)
      return true
    else
      vim.notify("❌ Build failed: " .. result, vim.log.levels.ERROR)
      return false
    end
  else
    -- Single file compilation
    return M.force_recompile_cpp() and true or false
  end
end

-- Function to clean build
function M.clean_build()
  if is_cmake_project() then
    local build_dir = find_cmake_build_dir()
    if build_dir then
      vim.notify("🧹 Cleaning build directory...", vim.log.levels.INFO)
      vim.fn.system("cd " .. vim.fn.shellescape(build_dir) .. " && make clean")
      vim.notify("✅ Build cleaned!", vim.log.levels.INFO)
    else
      vim.notify("❌ No build directory found", vim.log.levels.ERROR)
    end
  else
    -- Remove compiled executables
    local cwd = vim.fn.getcwd()
    local file_stem = vim.fn.expand('%:t:r')
    local possible_files = {
      cwd .. "/" .. file_stem,
      cwd .. "/a.out",
      cwd .. "/" .. file_stem .. ".out",
      cwd .. "/" .. file_stem .. ".exe"
    }
    
    for _, file in ipairs(possible_files) do
      if vim.fn.filereadable(file) == 1 then
        vim.fn.delete(file)
        vim.notify("🗑️  Removed: " .. file, vim.log.levels.INFO)
      end
    end
  end
end

-- ============================================================================
-- User Commands and Keybindings
-- ============================================================================

-- Create user commands
vim.api.nvim_create_user_command('CppBuild', M.build_project, { desc = 'Build C/C++ project' })
vim.api.nvim_create_user_command('CppClean', M.clean_build, { desc = 'Clean C/C++ build' })
vim.api.nvim_create_user_command('CppDebugSetup', M.configure_dap_cpp, { desc = 'Configure GDB for C/C++ debugging' })
vim.api.nvim_create_user_command('CppForceRecompile', M.force_recompile_cpp, { desc = 'Force recompile C/C++ with debug info' })
vim.api.nvim_create_user_command('CppDebugInteractive', M.debug_cpp_interactive, { desc = 'Debug C/C++ with external terminal for input' })

-- Export the module
return M