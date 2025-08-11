-- ============================================================================
-- Advanced Assembly Language Auto-detection and Debugging
-- Restored from original configuration with enhancements
-- ============================================================================

local M = {}

-- ============================================================================
-- Assembly Type Detection and Compilation System
-- ============================================================================

-- Function to detect assembly type and assemble
local function detect_asm_type_and_assemble()
  local current_file = vim.fn.expand('%:p')
  local file_stem = vim.fn.expand('%:t:r')
  local file_ext = vim.fn.expand('%:e'):lower()
  local cwd = vim.fn.getcwd()
  
  -- Read file content for analysis
  local content = vim.fn.readfile(current_file)
  local content_str = table.concat(content, '\n'):lower()
  
  local assembler = "nasm"  -- Default to NASM
  local format = "elf64"    -- Default 64-bit format
  local linker = "ld"       -- Default linker
  
  -- Detect assembler type
  if content_str:match("%.intel_syntax") then
    assembler = "gas"
    format = ""
  elseif content_str:match("%%include") or content_str:match("section%s+%.data") then
    assembler = "nasm"
    format = "elf64"
  end
  
  -- Detect architecture
  if content_str:match("eax") or content_str:match("ebx") or 
     content_str:match("ecx") or content_str:match("edx") then
    if assembler == "nasm" then
      format = "elf32"
    end
  end
  
  vim.notify("🔍 Detected: " .. assembler .. " assembler", vim.log.levels.DEBUG)
  
  -- Prepare file names
  local obj_file = cwd .. "/" .. file_stem .. ".o"
  local exe_file = cwd .. "/" .. file_stem
  
  local assemble_cmd, link_cmd
  
  if assembler == "nasm" then
    assemble_cmd = string.format("nasm -f %s -g -F dwarf -o %s %s", 
      format, vim.fn.shellescape(obj_file), vim.fn.shellescape(current_file))
  elseif assembler == "gas" then
    if format == "elf32" then
      assemble_cmd = string.format("as --32 -o %s %s", 
        vim.fn.shellescape(obj_file), vim.fn.shellescape(current_file))
      link_cmd = string.format("ld -m elf_i386 -o %s %s", 
        vim.fn.shellescape(exe_file), vim.fn.shellescape(obj_file))
    else
      assemble_cmd = string.format("as --64 -o %s %s", 
        vim.fn.shellescape(obj_file), vim.fn.shellescape(current_file))
      link_cmd = string.format("ld -o %s %s", 
        vim.fn.shellescape(exe_file), vim.fn.shellescape(obj_file))
    end
  end
  
  -- Set link command for NASM
  if assembler == "nasm" then
    if format == "elf32" then
      link_cmd = string.format("ld -m elf_i386 -o %s %s", 
        vim.fn.shellescape(exe_file), vim.fn.shellescape(obj_file))
    else
      link_cmd = string.format("ld -o %s %s", 
        vim.fn.shellescape(exe_file), vim.fn.shellescape(obj_file))
    end
  end
  
  -- Assemble
  vim.notify("🔨 Assembling: " .. assemble_cmd, vim.log.levels.DEBUG)
  local result = vim.fn.system(assemble_cmd)
  local exit_code = vim.v.shell_error
  
  if exit_code ~= 0 then
    vim.notify("❌ Assembly failed: " .. result, vim.log.levels.ERROR)
    return nil
  end
  
  -- Link
  vim.notify("🔗 Linking: " .. link_cmd, vim.log.levels.DEBUG)
  result = vim.fn.system(link_cmd)
  exit_code = vim.v.shell_error
  
  if exit_code ~= 0 then
    vim.notify("❌ Linking failed: " .. result, vim.log.levels.ERROR)
    -- Clean up object file
    vim.fn.delete(obj_file)
    return nil
  end
  
  -- Clean up object file
  vim.fn.delete(obj_file)
  
  vim.notify("✅ Successfully created: " .. exe_file, vim.log.levels.DEBUG)
  return exe_file
end

-- ============================================================================
-- Assembly Compilation Functions
-- ============================================================================

-- Function to compile and run assembly program
function M.compile_and_run_asm()
  if vim.bo.filetype ~= "asm" then
    vim.notify("❌ This function is for assembly files only", vim.log.levels.ERROR)
    return
  end
  
  local exe_file = detect_asm_type_and_assemble()
  if not exe_file then
    return
  end
  
  -- Ask whether to run
  local choice = vim.fn.confirm("Run the program?", "&Yes\n&No", 1)
  if choice == 1 then
    vim.notify("🚀 Running: " .. exe_file, vim.log.levels.DEBUG)
    vim.cmd("!./" .. vim.fn.shellescape(vim.fn.fnamemodify(exe_file, ":t")))
  end
end

-- Function to compile assembly program only (don't run)
function M.compile_asm_only()
  if vim.bo.filetype ~= "asm" then
    vim.notify("❌ This function is for assembly files only", vim.log.levels.ERROR)
    return
  end
  
  detect_asm_type_and_assemble()
end

-- ============================================================================
-- Assembly Debugging System
-- ============================================================================

-- Function to find or compile assembly executable for debugging
local function find_or_compile_asm_executable()
  local cwd = vim.fn.getcwd()
  local current_file = vim.fn.expand('%:p')
  local file_stem = vim.fn.expand('%:t:r')

  -- Check if executable exists
  local possible_executables = {
    cwd .. "/" .. file_stem,
    cwd .. "/a.out",
    cwd .. "/" .. file_stem .. ".out"
  }
  
  for _, exe_path in ipairs(possible_executables) do
    if vim.fn.executable(exe_path) == 1 then
      -- Check if executable is newer than source file
      local exe_time = vim.fn.getftime(exe_path)
      local src_time = vim.fn.getftime(current_file)
      
      if exe_time > src_time then
        vim.notify("✅ Found existing executable: " .. exe_path, vim.log.levels.DEBUG)
        return exe_path
      end
    end
  end
  
  -- Need to recompile
  vim.notify("🔨 Compiling assembly file for debugging...", vim.log.levels.DEBUG)
  local exe_file = detect_asm_type_and_assemble()
  
  if exe_file and vim.fn.executable(exe_file) == 1 then
    return exe_file
  else
    vim.notify("❌ Failed to create executable for debugging", vim.log.levels.ERROR)
    return nil
  end
end

-- Function to configure assembly language debugging
function M.configure_dap_asm()
  local dap = require('dap')
  
  -- Ensure GDB is available
  if vim.fn.executable("gdb") ~= 1 then
    vim.notify("❌ GDB not found. Please install GDB for assembly debugging.", vim.log.levels.ERROR)
    return false
  end
  
  -- Configure GDB adapter
  dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" }
  }
  
  -- Add assembly language debugging configuration
  dap.configurations.asm = {
    {
      name = "Debug Assembly (Auto-compile)",
      type = "gdb",
      request = "launch",
      program = find_or_compile_asm_executable,
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
      args = function()
        local args_str = vim.fn.input('Program arguments (press Enter if none needed): ')
        return args_str == "" and {} or vim.split(args_str, " ", { plain = true })
      end,
      runInTerminal = false,
      setupCommands = {
        {
          text = '-enable-pretty-printing',
          description = 'enable pretty printing',
          ignoreFailures = false
        },
        {
          text = '-gdb-set disassembly-flavor intel',
          description = 'set Intel disassembly syntax',
          ignoreFailures = true
        },
        {
          text = '-gdb-set print elements 200',
          description = 'limit array printing',
          ignoreFailures = false
        },
      },
    },
    {
      name = "Debug Assembly (External Terminal)",
      type = "gdb",
      request = "launch",
      program = find_or_compile_asm_executable,
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
      args = function()
        local args_str = vim.fn.input('Program arguments: ')
        return args_str == "" and {} or vim.split(args_str, " ", { plain = true })
      end,
      runInTerminal = true,
      console = "externalTerminal",
      setupCommands = {
        {
          text = '-enable-pretty-printing',
          description = 'enable pretty printing',
          ignoreFailures = false
        },
        {
          text = '-gdb-set disassembly-flavor intel',
          description = 'set Intel disassembly syntax',
          ignoreFailures = true
        },
      },
    }
  }
  
  -- vim.notify("✅ Assembly debugging configured!", vim.log.levels.DEBUG)
  -- vim.notify("💡 Features:", vim.log.levels.DEBUG)
  -- vim.notify("  • Auto-detects NASM vs GAS syntax", vim.log.levels.DEBUG)
  -- vim.notify("  • Intelligent 32/64-bit compilation", vim.log.levels.DEBUG)
  -- vim.notify("  • Intel disassembly syntax in GDB", vim.log.levels.DEBUG)
  -- vim.notify("  • External terminal support for input", vim.log.levels.DEBUG)
  
  return true
end

-- ============================================================================
-- Assembly File Type Setup
-- ============================================================================

-- Function to setup assembly file type with keybindings and settings
function M.setup_assembly_filetype()
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Editor settings for assembly files
  vim.bo[bufnr].expandtab = false      -- Use tabs for assembly
  vim.bo[bufnr].tabstop = 8           -- 8-space tabs
  vim.bo[bufnr].shiftwidth = 8        -- 8-space indentation
  vim.bo[bufnr].softtabstop = 8       -- 8-space soft tabs
  vim.bo[bufnr].commentstring = "; %s" -- Assembly comment style
  
  -- Compile shortcut
  vim.keymap.set('n', '<F9>', M.compile_asm_only, 
    { buffer = bufnr, desc = 'Compile assembly file' })
  
  -- Compile and run shortcut
  vim.keymap.set('n', '<leader>ar', M.compile_and_run_asm, 
    { buffer = bufnr, desc = 'Compile and run assembly' })
  
  -- Configure debugging shortcut
  vim.keymap.set('n', '<leader>da', M.configure_dap_asm, 
    { buffer = bufnr, desc = 'Configure assembly debugging' })
  
  -- vim.notify("🔧 Assembly setup complete!", vim.log.levels.DEBUG)
  -- vim.notify("💡 Available commands:", vim.log.levels.DEBUG)
  -- vim.notify("  • F9: Compile assembly file", vim.log.levels.DEBUG)
  -- vim.notify("  • <leader>ar: Compile and run", vim.log.levels.DEBUG)
  -- vim.notify("  • <leader>da: Setup debugging", vim.log.levels.DEBUG)
end

-- ============================================================================
-- Utility Functions
-- ============================================================================

-- Function to clean assembly build artifacts
function M.clean_assembly_build()
  local cwd = vim.fn.getcwd()
  local file_stem = vim.fn.expand('%:t:r')
  
  local artifacts = {
    cwd .. "/" .. file_stem,
    cwd .. "/" .. file_stem .. ".o",
    cwd .. "/" .. file_stem .. ".out",
    cwd .. "/a.out"
  }
  
  local cleaned = 0
  for _, file in ipairs(artifacts) do
    if vim.fn.filereadable(file) == 1 then
      vim.fn.delete(file)
      vim.notify("🗑️  Removed: " .. file, vim.log.levels.DEBUG)
      cleaned = cleaned + 1
    end
  end
  
  if cleaned == 0 then
    vim.notify("✨ No build artifacts to clean", vim.log.levels.DEBUG)
  else
    vim.notify("✅ Cleaned " .. cleaned .. " build artifact(s)", vim.log.levels.DEBUG)
  end
end

-- ============================================================================
-- Auto-commands and File Type Detection
-- ============================================================================

-- Set up assembly file type detection
vim.api.nvim_create_autocmd("FileType", {
  pattern = "asm",
  callback = M.setup_assembly_filetype,
  desc = "Setup assembly file type with keybindings and settings"
})

-- Support additional assembly file extensions
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.nasm", "*.inc", "*.s"},
  callback = function()
    vim.bo.filetype = "asm"
  end,
  desc = "Set filetype to asm for additional assembly file extensions"
})

-- ============================================================================
-- User Commands
-- ============================================================================

-- Create user commands
vim.api.nvim_create_user_command('AsmCompile', M.compile_asm_only, { desc = 'Compile assembly file' })
vim.api.nvim_create_user_command('AsmRun', M.compile_and_run_asm, { desc = 'Compile and run assembly file' })
vim.api.nvim_create_user_command('AsmDebugSetup', M.configure_dap_asm, { desc = 'Configure GDB for assembly debugging' })
vim.api.nvim_create_user_command('AsmClean', M.clean_assembly_build, { desc = 'Clean assembly build artifacts' })

-- Export the module
return M