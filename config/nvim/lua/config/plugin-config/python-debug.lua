-- ============================================================================
-- Advanced Python Environment Detection and Debugging
-- Restored from original configuration with enhancements
-- ============================================================================

local M = {}

-- ============================================================================
-- Python Environment Detection System
-- ============================================================================

-- Function to get available Python interpreters with priority
local function get_python_interpreters()
  local interpreters = {}
  local cwd = vim.fn.getcwd()
  
  -- Get current environment status
  local active_python = vim.fn.exepath("python") or vim.fn.exepath("python3")
  local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
  local conda_env = vim.fn.getenv("CONDA_DEFAULT_ENV")
  local conda_prefix = vim.fn.getenv("CONDA_PREFIX")
  
  -- Handle userdata values (when env vars don't exist)
  -- vim.fn.getenv returns vim.NIL (userdata) when env var doesn't exist
  if type(virtual_env) ~= "string" or virtual_env == vim.NIL then virtual_env = nil end
  if type(conda_env) ~= "string" or conda_env == vim.NIL then conda_env = nil end
  if type(conda_prefix) ~= "string" or conda_prefix == vim.NIL then conda_prefix = nil end
  
  -- 1. Currently active environment (highest priority if it exists)
  if active_python and (virtual_env or conda_env) then
    local env_name = ""
    local env_type = ""
    
    if virtual_env then
      local venv_name = vim.fn.fnamemodify(virtual_env, ":t")
      if virtual_env:match("/.venv$") then
        env_name = "UV/Venv (.venv)"
        env_type = "uv"
      elseif virtual_env:match("/venv$") then
        env_name = "Python Venv"
        env_type = "venv"
      else
        env_name = "Venv: " .. venv_name
        env_type = "venv"
      end
    elseif conda_env then
      env_name = "Conda: " .. conda_env
      env_type = "conda"
    end
    
    table.insert(interpreters, {
      path = active_python,
      display = "🌟 " .. env_name .. " (active)",
      priority = 0,
      type = env_type
    })
  end
  
  -- 2. Project virtual environments
  local venv_paths = {
    {path = cwd .. "/.venv/bin/python", name = "UV/Venv (.venv)", priority = 1},
    {path = cwd .. "/venv/bin/python", name = "Venv (venv)", priority = 2}
  }
  
  for _, venv in ipairs(venv_paths) do
    if vim.fn.executable(venv.path) == 1 then
      -- Don't add if it's already the active environment
      local skip = false
      if virtual_env and venv.path == virtual_env .. "/bin/python" then
        skip = true
      end
      
      if not skip then
        table.insert(interpreters, {
          path = venv.path,
          display = "🚀 " .. venv.name,
          priority = venv.priority,
          type = "venv"
        })
      end
    end
  end
  
  -- 3. Conda environments (if available)
  local conda_cmd = vim.fn.exepath("conda")
  if conda_cmd then
    local handle = io.popen("conda env list 2>/dev/null")
    if handle then
      local output = handle:read("*a")
      handle:close()
      
      for line in output:gmatch("[^\n]+") do
        if not line:match("^#") and line:match("%S") then
          local env_name, env_path = line:match("^([^%s*]+)%s+([^%s]+)")
          
          -- Handle lines with * (active environment indicator)
          if not env_name and line:match("%*") then
            env_name, env_path = line:match("^([^%s*]+)%s*%*%s+([^%s]+)")
          end
          
          if env_name and env_path then
            env_path = env_path:gsub("%s+$", "")
            local python_path = env_path .. "/bin/python"
            
            if vim.fn.executable(python_path) == 1 then
              -- Don't add if it's already the active environment
              local skip = false
              if conda_env == env_name or (conda_prefix and python_path == conda_prefix .. "/bin/python") then
                skip = true
              end
              
              if not skip then
                table.insert(interpreters, {
                  path = python_path,
                  display = "🐍 Conda: " .. env_name,
                  priority = 4,
                  type = "conda"
                })
              end
            end
          end
        end
      end
    end
  end
  
  -- 4. System Python (lowest priority)
  local system_python = vim.fn.exepath("python3") or vim.fn.exepath("python")
  if system_python then
    local skip = false
    if active_python == system_python and not (virtual_env or conda_env) then
      table.insert(interpreters, {
        path = system_python,
        display = "🌟 System Python (active)",
        priority = 0,
        type = "system"
      })
      skip = true
    end
    
    if not skip then
      table.insert(interpreters, {
        path = system_python,
        display = "🐍 System Python",
        priority = 5,
        type = "system"
      })
    end
  end
  
  -- Sort by priority (lower number = higher priority)
  table.sort(interpreters, function(a, b)
    return a.priority < b.priority
  end)
  
  return interpreters
end

-- ============================================================================
-- Debugpy Adapter Management
-- ============================================================================

-- Function to get or install global debugpy adapter
local function get_debugpy_adapter()
  -- Check if pipx debugpy exists
  local pipx_debugpy = vim.fn.expand("~/.local/share/pipx/venvs/debugpy/bin/python")
  if vim.fn.executable(pipx_debugpy) == 1 then
    -- Verify debugpy is actually installed
    local result = vim.fn.system(pipx_debugpy .. ' -c "import debugpy" 2>/dev/null')
    if vim.v.shell_error == 0 then
      return pipx_debugpy
    end
  end
  
  -- Check if global pip debugpy exists
  local system_python = vim.fn.exepath("python3") or vim.fn.exepath("python")
  if system_python then
    local result = vim.fn.system(system_python .. ' -c "import debugpy" 2>/dev/null')
    if vim.v.shell_error == 0 then
      return system_python
    end
  end
  
  -- No debugpy found, offer to install via pipx
  local choice = vim.fn.confirm(
    "No global debugpy adapter found.\nInstall debugpy globally via pipx (recommended)?",
    "&Yes (pipx)\n&Yes (system pip)\n&Cancel", 
    1
  )
  
  if choice == 1 then
    vim.notify("📦 Installing debugpy via pipx...", vim.log.levels.WARN)
    local result = vim.fn.system("pipx install debugpy")
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ debugpy installed via pipx!", vim.log.levels.DEBUG)
      return pipx_debugpy
    else
      vim.notify("❌ pipx install failed: " .. result, vim.log.levels.ERROR)
    end
  elseif choice == 2 then
    vim.notify("📦 Installing debugpy via system pip...", vim.log.levels.WARN)
    local result = vim.fn.system(system_python .. " -m pip install debugpy --user")
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ debugpy installed via system pip!", vim.log.levels.DEBUG)
      return system_python
    else
      vim.notify("❌ system pip install failed: " .. result, vim.log.levels.ERROR)
    end
  end
  
  return nil
end

-- ============================================================================
-- Environment Switching and Path Management
-- ============================================================================

-- Function to clean and update PATH for Python environment
local function update_python_environment(python_path)
  local env_root = vim.fn.fnamemodify(python_path, ":h:h")  -- Remove /bin/python
  
  -- Get current PATH and filter out old Python environment paths
  local current_path = vim.fn.getenv("PATH")
  local path_parts = vim.split(current_path, ":", {plain = true})
  local new_path_parts = {}
  
  for _, part in ipairs(path_parts) do
    local skip = false
    
    -- Skip known Python environment patterns
    if part:match("/miniconda3/envs/[^/]+/bin$") or 
       part:match("/anaconda3/envs/[^/]+/bin$") or
       part:match("/%.venv/bin$") or 
       part:match("/venv/bin$") or
       part:match(".*/%.venv/bin$") or  -- Match any .venv/bin path
       part:match(".*/venv/bin$") then  -- Match any venv/bin path
      -- Don't add old Python environment paths
      skip = true
    end
    
    if not skip then
      table.insert(new_path_parts, part)
    end
  end
  
  -- Prepend the new environment's bin directory
  local env_bin = env_root .. "/bin"
  table.insert(new_path_parts, 1, env_bin)
  
  local new_path = table.concat(new_path_parts, ":")
  vim.fn.setenv("PATH", new_path)
  
  -- Set environment variables for virtual environments
  if python_path:match("/%.venv/") or python_path:match("/venv/") then
    vim.fn.setenv("VIRTUAL_ENV", env_root)
    vim.fn.setenv("CONDA_DEFAULT_ENV", vim.NIL)
    vim.fn.setenv("CONDA_PREFIX", vim.NIL)
  elseif python_path:match("/miniconda3/envs/") or python_path:match("/anaconda3/envs/") then
    local env_name = vim.fn.fnamemodify(env_root, ":t")
    vim.fn.setenv("CONDA_DEFAULT_ENV", env_name)
    vim.fn.setenv("CONDA_PREFIX", env_root)
    vim.fn.setenv("VIRTUAL_ENV", vim.NIL)
  else
    -- System Python
    vim.fn.setenv("VIRTUAL_ENV", vim.NIL)
    vim.fn.setenv("CONDA_DEFAULT_ENV", vim.NIL)
    vim.fn.setenv("CONDA_PREFIX", vim.NIL)
  end
end

-- ============================================================================
-- DAP Configuration for Python
-- ============================================================================

-- Function to configure DAP with selected Python interpreter
local function configure_dap_python(debugpy_adapter, python_path, update_env)
  local dap = require('dap')
  
  -- Clear existing Python configurations
  dap.configurations.python = {}
  
  -- Setup dap-python with debuggy adapter
  require("dap-python").setup(debugpy_adapter)
  
  -- Override the Python path for running the actual code
  dap.configurations.python = {
    {
      type = 'python',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      pythonPath = python_path,
      console = "integratedTerminal",
      justMyCode = false,
    },
    {
      type = 'python',
      request = 'launch', 
      name = 'Launch file with arguments',
      program = '${file}',
      args = function()
        local args_string = vim.fn.input('Arguments: ')
        return vim.split(args_string, " ", {plain = true})
      end,
      pythonPath = python_path,
      console = "integratedTerminal",
      justMyCode = false,
    },
  }
  
  if update_env then
    update_python_environment(python_path)
    
    -- Restart LSP servers for Python to pick up new environment
    vim.schedule(function()
      M.restart_python_lsp(python_path)
    end)
  end
end

-- Function to restart Python LSP servers with new environment
function M.restart_python_lsp(python_path)
  -- Get directory of Python interpreter for venv detection
  local python_dir = vim.fn.fnamemodify(python_path, ":h:h")
  
  -- Stop existing Python LSP clients
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.name == "pyright" or client.name == "ruff" then
      -- vim.notify("🔄 Restarting " .. client.name .. " for new Python environment", vim.log.levels.DEBUG)
      client.stop()
    end
  end
  
  -- Wait a bit then restart with new settings
  vim.defer_fn(function()
    -- Update Pyright settings
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    
    -- Configure Pyright with new Python path
    lspconfig.pyright.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        -- Basic LSP navigation keybindings
        local opts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)  -- Consistent with main LSP config
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
      end,
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "standard",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            disableOrganizeImports = true,
            stubPath = vim.fn.expand("~/.pyright/stubs")
          },
          pythonPath = python_path,
          venvPath = python_dir
        },
        pyright = {
          disableOrganizeImports = true
        }
      }
    })
    
    -- Also restart Ruff with new environment
    lspconfig.ruff.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        -- Basic LSP navigation keybindings
        local opts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)  -- Consistent with main LSP config
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
      end,
      init_options = {
        settings = {
          interpreter = { python_path }
        }
      }
    })
    
    vim.notify("✅ Python LSP servers restarted with new environment", vim.log.levels.DEBUG)
  end, 1000)
end

-- ============================================================================
-- Interactive Python Environment Selection
-- ============================================================================

-- Function to show Python interpreter selection via Telescope
function M.select_python_interpreter()
  local telescope_ok, telescope_builtin = pcall(require, "telescope.builtin")
  if not telescope_ok then
    vim.notify("❌ Telescope not available", vim.log.levels.ERROR)
    return
  end
  
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  
  -- First, ensure we have a debugpy adapter
  local debugpy_adapter = get_debugpy_adapter()
  if not debugpy_adapter then
    vim.notify("❌ Cannot setup debugging without debugpy adapter", vim.log.levels.ERROR)
    return
  end
  
  local interpreters = get_python_interpreters()
  
  if #interpreters == 0 then
    vim.notify("❌ No Python interpreters found", vim.log.levels.ERROR)
    return
  end
  
  pickers.new({}, {
    prompt_title = "Select Python Interpreter",
    finder = finders.new_table {
      results = interpreters,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display .. " (" .. entry.path .. ")",
          ordinal = entry.display,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local python_path = selection.value.path
          
          -- Configure DAP with selected interpreter and update environment
          configure_dap_python(debugpy_adapter, python_path, true)
          
          vim.notify("✅ Debugging configured and environment switched!", vim.log.levels.DEBUG)
          -- vim.notify("🔧 Debugpy adapter: " .. debugpy_adapter, vim.log.levels.DEBUG)
          vim.notify("🐍 Code runner: " .. selection.value.display, vim.log.levels.DEBUG)
          vim.notify("🔄 Neovim environment updated to match interpreter", vim.log.levels.DEBUG)
        end
      end)
      return true
    end,
  }):find()
end

-- ============================================================================
-- Automatic Python Debug Setup
-- ============================================================================

-- Auto setup that uses active environment or best available
function M.auto_debug_setup()
  -- First, ensure we have a debugpy adapter
  local debugpy_adapter = get_debugpy_adapter()
  if not debugpy_adapter then
    vim.notify("❌ Cannot setup debugging without debugpy adapter", vim.log.levels.ERROR)
    return false
  end
  
  local interpreters = get_python_interpreters()
  if #interpreters == 0 then
    vim.notify("❌ No Python interpreters found", vim.log.levels.ERROR)
    return false
  end
  
  -- Find the best interpreter based on current environment status
  local best_interpreter = nil
  local active_python = vim.fn.exepath("python") or vim.fn.exepath("python3")
  local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
  local conda_env = vim.fn.getenv("CONDA_DEFAULT_ENV")
  
  -- Handle vim.NIL
  if type(virtual_env) ~= "string" or virtual_env == vim.NIL then virtual_env = nil end
  if type(conda_env) ~= "string" or conda_env == vim.NIL then conda_env = nil end
  
  -- If no active environment, prefer system Python if it's what's currently active
  if not virtual_env and not conda_env then
    for _, interp in ipairs(interpreters) do
      if interp.type == "system" and interp.path == active_python then
        best_interpreter = interp
        break
      end
    end
  end
  
  -- Fallback to first interpreter (already sorted by priority)
  if not best_interpreter then
    best_interpreter = interpreters[1]
  end
  
  local python_path = best_interpreter.path
  
  -- Configure DAP with selected interpreter and update environment
  configure_dap_python(debugpy_adapter, python_path, true)
  
  -- vim.notify("🐍 Using: " .. best_interpreter.display, vim.log.levels.DEBUG)
  -- vim.notify("🔧 Debugpy adapter: " .. debugpy_adapter, vim.log.levels.DEBUG)
  
  return true
end

-- ============================================================================
-- Python Environment Information Display
-- ============================================================================

-- Function to show current Python environment info
function M.show_python_env()
  -- Force refresh of PATH-based lookups
  local current_path = vim.fn.getenv("PATH")
  
  local python_path = vim.fn.exepath("python")
  local python3_path = vim.fn.exepath("python3")
  
  local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
  local conda_env = vim.fn.getenv("CONDA_DEFAULT_ENV")
  local conda_prefix = vim.fn.getenv("CONDA_PREFIX")
  
  -- Handle userdata values
  if type(virtual_env) ~= "string" or virtual_env == vim.NIL then virtual_env = nil end
  if type(conda_env) ~= "string" or conda_env == vim.NIL then conda_env = nil end
  if type(conda_prefix) ~= "string" or conda_prefix == vim.NIL then conda_prefix = nil end
  
  print("=== Current Python Environment ===")
  print("Python executable: " .. (python_path or "Not found"))
  print("Python3 executable: " .. (python3_path or "Not found"))
  print("VIRTUAL_ENV: " .. (virtual_env or "None"))
  print("CONDA_DEFAULT_ENV: " .. (conda_env or "None"))
  print("CONDA_PREFIX: " .. (conda_prefix or "None"))
  print("Real path (python): " .. (python_path and vim.fn.resolve(python_path) or "N/A"))
  print("Real path (python3): " .. (python3_path and vim.fn.resolve(python3_path) or "N/A"))
  
  print("\n=== Available Interpreters ===")
  local interpreters = get_python_interpreters()
  for i, interp in ipairs(interpreters) do
    print(i .. ". " .. interp.display .. " -> " .. interp.path)
  end
  
  print("\n=== PATH (Python-related entries) ===")
  if current_path then
    local path_parts = vim.split(current_path, ":", {plain = true})
    for i, part in ipairs(path_parts) do
      if part:match("python") or part:match("conda") or part:match("venv") or part:match("bin") then
        -- Mark Python-related paths
        local marker = ""
        if part:match("/%.venv/bin$") then marker = " [VENV]"
        elseif part:match("/miniconda3/envs/[^/]+/bin$") or part:match("/anaconda3/envs/[^/]+/bin$") then marker = " [CONDA]"
        elseif part == "/usr/bin" or part == "/bin" then marker = " [SYSTEM]"
        end
        print("  " .. i .. ". " .. part .. marker)
      end
    end
  end
end

-- ============================================================================
-- Quick Commands and User Commands
-- ============================================================================

-- Create user commands
vim.api.nvim_create_user_command('PythonDebugSelect', M.select_python_interpreter, { desc = 'Select Python interpreter for debugging' })
vim.api.nvim_create_user_command('PythonDebugAuto', M.auto_debug_setup, { desc = 'Auto-setup Python debugging' })
vim.api.nvim_create_user_command('PythonEnv', M.show_python_env, { desc = 'Show current Python environment info' })

-- Note: Keybindings are set in debugging.lua to avoid conflicts

-- Export the module
return M