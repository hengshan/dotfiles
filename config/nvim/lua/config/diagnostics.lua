-- ============================================================================
-- Configuration Diagnostics - Debug loading issues
-- ============================================================================

local M = {}

-- Check if plugins are loaded correctly
function M.check_plugins()
  local results = {}
  
  -- Check core plugins
  local plugins_to_check = {
    { name = "nvim-dap", module = "dap" },
    { name = "overseer.nvim", module = "overseer" },
    { name = "toggleterm.nvim", module = "toggleterm" },
    { name = "nvim-dap-ui", module = "dapui" },
  }
  
  print("=== Plugin Status Check ===")
  for _, plugin in ipairs(plugins_to_check) do
    local ok, mod = pcall(require, plugin.module)
    local status = ok and "✅ Loaded" or "❌ Failed"
    print(string.format("%-20s: %s", plugin.name, status))
    if not ok then
      print(string.format("  Error: %s", mod))
    end
    results[plugin.name] = ok
  end
  
  return results
end

-- Check DAP configurations
function M.check_dap_config()
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    print("❌ DAP not available")
    return false
  end
  
  print("\n=== DAP Configuration Status ===")
  print("Available adapters:")
  for name, adapter in pairs(dap.adapters) do
    print(string.format("  - %s: %s", name, type(adapter)))
  end
  
  print("\nAvailable configurations:")
  for lang, configs in pairs(dap.configurations) do
    if configs and #configs > 0 then
      print(string.format("  - %s: %d configuration(s)", lang, #configs))
      for i, config in ipairs(configs) do
        print(string.format("    %d. %s", i, config.name or "Unnamed"))
      end
    end
  end
  
  return true
end

-- Check overseer integration
function M.check_overseer()
  local overseer_ok, overseer = pcall(require, "overseer")
  if not overseer_ok then
    print("❌ Overseer not available")
    return false
  end
  
  print("\n=== Overseer Status ===")
  
  -- Check if we're in a project with build files
  local has_cmake = vim.fn.filereadable("CMakeLists.txt") == 1
  local has_makefile = vim.fn.filereadable("Makefile") == 1 or vim.fn.filereadable("makefile") == 1
  
  print(string.format("CMake project: %s", has_cmake and "Yes" or "No"))
  print(string.format("Make project: %s", has_makefile and "Yes" or "No"))
  
  -- List recent tasks
  local tasks = overseer.list_tasks({ recent_first = true })
  print(string.format("Recent tasks: %d", #tasks))
  
  return true
end

-- Check key mappings
function M.check_keymaps()
  print("\n=== Key Mappings Check ===")
  
  local key_checks = {
    { key = "<leader>b", desc = "Toggle Breakpoint" },
    { key = "<leader>cb", desc = "Build Project" },
    { key = "<leader>cc", desc = "Configure CMake" },
    { key = "<leader>or", desc = "Overseer Run" },
    { key = "<C-\\>", desc = "Toggle Terminal" },
    { key = "<F5>", desc = "Debug Continue" },
  }
  
  for _, check in ipairs(key_checks) do
    local maps = vim.api.nvim_get_keymap('n')
    local found = false
    for _, map in ipairs(maps) do
      if map.lhs == check.key then
        found = true
        break
      end
    end
    local status = found and "✅ Mapped" or "❌ Missing"
    print(string.format("%-15s: %s (%s)", check.key, status, check.desc))
  end
end

-- Run full diagnostics
function M.run_diagnostics()
  print("🔍 Running Neovim Configuration Diagnostics\n")
  
  local plugin_results = M.check_plugins()
  M.check_dap_config()
  M.check_overseer()
  M.check_keymaps()
  
  print("\n=== Summary ===")
  local all_ok = true
  for plugin, ok in pairs(plugin_results) do
    if not ok then
      all_ok = false
      print(string.format("❌ %s has issues", plugin))
    end
  end
  
  if all_ok then
    print("✅ All core plugins loaded successfully")
  else
    print("⚠️  Some plugins have loading issues")
    print("Try restarting Neovim or running :Lazy sync")
  end
end

-- Create user command
vim.api.nvim_create_user_command('DiagnosticsRun', M.run_diagnostics, { desc = 'Run configuration diagnostics' })

return M