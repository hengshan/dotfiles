-- ============================================================================
-- Simplified C/C++ Debugging Configuration - Only Essential Options
-- ============================================================================

local M = {}

-- Load DAP safely
local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
  vim.notify("❌ nvim-dap not available", vim.log.levels.ERROR)
  return M
end

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Force recompile function - always compiles regardless of existing files
local function force_recompile_cpp()
  local current_file = vim.fn.expand('%:p')
  local cwd = vim.fn.getcwd()
  local file_stem = vim.fn.expand('%:t:r')
  local file_ext = vim.fn.expand('%:e')
  
  -- Check if it's a C/C++ file
  if not (file_ext == 'c' or file_ext == 'cpp' or file_ext == 'cxx' or file_ext == 'cc' or file_ext == 'C') then
    vim.notify("❌ Not a C/C++ source file", vim.log.levels.ERROR)
    return nil
  end
  
  -- Auto-detect compiler
  local is_cpp = file_ext == 'cpp' or file_ext == 'cxx' or file_ext == 'cc' or file_ext == 'C'
  local compiler = is_cpp and "g++" or "gcc"
  local std_flag = is_cpp and "-std=c++17" or ""
  
  -- Clean up existing files first
  local files_to_clean = {
    cwd .. "/" .. file_stem,
    cwd .. "/" .. file_stem .. ".exe",
    cwd .. "/" .. file_stem .. ".o",
    cwd .. "/a.out"
  }
  
  local cleaned = 0
  for _, file in ipairs(files_to_clean) do
    if vim.fn.filereadable(file) == 1 then
      vim.fn.delete(file)
      cleaned = cleaned + 1
    end
  end
  
  if cleaned > 0 then
    vim.notify("🧹 Cleaned " .. cleaned .. " old file(s)", vim.log.levels.DEBUG)
  end
  
  -- Compile with debug info
  local output_name = cwd .. "/" .. file_stem
  local compile_cmd = string.format("%s -g -O0 -Wall %s -o %s %s", 
    compiler, std_flag, vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
  
  vim.notify("🔨 Force recompiling: " .. compile_cmd, vim.log.levels.DEBUG)
  local result = vim.fn.system(compile_cmd)
  
  if vim.v.shell_error == 0 then
    vim.notify("✅ Force recompilation successful!", vim.log.levels.DEBUG)
    return output_name
  else
    vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
    return nil
  end
end


-- Find CMake executable
local function find_cmake_executable()
  local build_dir = vim.fn.getcwd() .. "/build"
  
  -- Check if we have a CMake build directory
  if vim.fn.isdirectory(build_dir) == 0 then
    vim.notify("❌ No build directory found. Run <leader>cc first", vim.log.levels.ERROR)
    return nil
  end
  
  -- Look for executables in build directory
  local executables = {}
  local files = vim.fn.glob(build_dir .. "/*", false, true)
  
  for _, file in ipairs(files) do
    if vim.fn.executable(file) == 1 then
      table.insert(executables, file)
    end
  end
  
  if #executables == 0 then
    vim.notify("❌ No executables found in build/. Run <leader>cb first", vim.log.levels.ERROR)
    return nil
  elseif #executables == 1 then
    return executables[1]
  else
    -- Multiple executables, let user choose
    local choices = {}
    for i, exe in ipairs(executables) do
      table.insert(choices, string.format("&%d. %s", i, vim.fn.fnamemodify(exe, ":t")))
    end
    
    local choice = vim.fn.confirm("Select executable:", table.concat(choices, "\n"), 1)
    if choice > 0 then
      return executables[choice]
    end
  end
  
  return nil
end

-- Simple function to find or compile C/C++ executable
local function find_or_compile_cpp_executable()
  local cwd = vim.fn.getcwd()
  local current_file = vim.fn.expand('%:p')
  local file_stem = vim.fn.expand('%:t:r')
  
  -- Check for existing executables
  local possible_files = {
    cwd .. "/" .. file_stem,
    cwd .. "/a.out", 
    cwd .. "/" .. file_stem .. ".exe"
  }
  
  for _, file in ipairs(possible_files) do
    if vim.fn.filereadable(file) == 1 then
      return file
    end
  end
  
  -- Auto-detect compiler and compile
  local file_ext = vim.fn.expand('%:e')
  local is_cpp = file_ext == 'cpp' or file_ext == 'cxx' or file_ext == 'cc' or file_ext == 'C'
  local compiler = is_cpp and "g++" or "gcc"
  local std_flag = is_cpp and "-std=c++17" or ""
  
  local choice = vim.fn.confirm(
    "No executable found. Compile " .. current_file .. " with " .. compiler .. "?",
    "&Yes\n&Cancel",
    1
  )
  
  if choice == 1 then
    local output_name = cwd .. "/" .. file_stem
    local compile_cmd = string.format("%s -g -O0 -Wall %s -o %s %s", 
      compiler, std_flag, vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
    
    vim.notify("🔨 Compiling: " .. compile_cmd, vim.log.levels.DEBUG)
    local result = vim.fn.system(compile_cmd)
    
    if vim.v.shell_error == 0 then
      vim.notify("✅ Compilation successful!", vim.log.levels.DEBUG)
      return output_name
    else
      vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
    end
  end
  
  return nil
end

-- ============================================================================
-- DAP Configuration
-- ============================================================================

function M.configure_dap_cpp()
  -- Clear existing configurations
  dap.configurations.c = {}
  dap.configurations.cpp = {}
  
  -- LLDB adapter (preferred)
  local lldb_dap_cmd = "lldb-dap"
  if vim.fn.executable("lldb-dap") == 0 then
    if vim.fn.executable("lldb-dap-18") == 1 then
      lldb_dap_cmd = "lldb-dap-18"
    end
  end
  
  dap.adapters.lldb = {
    type = 'executable',
    command = lldb_dap_cmd,
    name = 'lldb'
  }
  
  -- GDB adapter (fallback)
  dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--quiet", "--interpreter=mi" }
  }
  
  -- Configuration options for both CMake and single files
  local cpp_config = {
    {
      name = "🏗️ CMake Debug (LLDB)",
      type = "lldb",
      request = "launch",
      program = find_cmake_executable,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
      console = "integratedTerminal"
    },
    {
      name = "🚀 Single File Debug (LLDB)",
      type = "lldb",
      request = "launch",
      program = find_or_compile_cpp_executable,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
      console = "integratedTerminal"
    },
    {
      name = "🔧 Quick Launch (GDB)",
      type = "gdb",
      request = "launch",
      program = find_or_compile_cpp_executable,
      cwd = "${workspaceFolder}",
      stopAtEntry = false,
      args = {},
      console = "integratedTerminal",
      setupCommands = {
        {
          description = "Enable pretty-printing",
          text = "set print pretty on",
          ignoreFailures = true
        }
      }
    },
    {
      name = "🎯 Launch with Arguments",
      type = "gdb",
      request = "launch", 
      program = find_or_compile_cpp_executable,
      cwd = "${workspaceFolder}",
      args = function()
        local args_str = vim.fn.input('Program arguments: ')
        return args_str == "" and {} or vim.split(args_str, " ", {plain = true})
      end,
      console = "integratedTerminal",
      setupCommands = {
        {
          description = "Enable pretty-printing",
          text = "set print pretty on",
          ignoreFailures = true
        }
      }
    },
    {
      name = "🦀 CodeLLDB Launch",
      type = "codelldb",
      request = "launch",
      program = find_or_compile_cpp_executable,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
      runInTerminal = false,
      console = "integratedTerminal",
    }
  }
  
  -- Apply configurations
  dap.configurations.c = cpp_config
  dap.configurations.cpp = cpp_config
  
  -- vim.notify("✅ Simplified C/C++ debugging configured (4 options including CodeLLDB)", vim.log.levels.DEBUG)
  return true
end

-- Export functions for external use
M.force_recompile_cpp = force_recompile_cpp

-- Auto-configure when opening C/C++ files (prevent multiple executions)
local configured_buffers = {}

vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = {"c", "cpp"},
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    
    -- Prevent multiple configurations for the same buffer
    if configured_buffers[bufnr] then
      return
    end
    
    -- Configure DAP
    M.configure_dap_cpp()
    
    -- Set F6 keymap
    vim.keymap.set('n', '<F6>', force_recompile_cpp, 
      { buffer = bufnr, desc = 'Force compile C/C++' })
    
    -- Mark this buffer as configured
    configured_buffers[bufnr] = true
    
    -- Clean up when buffer is deleted
    vim.api.nvim_create_autocmd("BufDelete", {
      buffer = bufnr,
      callback = function()
        configured_buffers[bufnr] = nil
      end,
      once = true
    })
  end,
  desc = "Auto-configure C/C++ debugging and F6 keymap"
})

-- Create user command for C/C++ compilation
vim.api.nvim_create_user_command('CppRecompile', force_recompile_cpp, { desc = 'Force recompile current C/C++ file' })


return M