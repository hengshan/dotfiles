-- ============================================================================
-- Overseer Task Runner Configuration
-- ============================================================================

local overseer_ok, overseer = pcall(require, "overseer")
if not overseer_ok then
  vim.notify("❌ overseer.nvim not available", vim.log.levels.ERROR)
  return
end

-- ============================================================================
-- Overseer Setup
-- ============================================================================

overseer.setup({
  strategy = "jobstart", -- 完全静默，不显示任何窗口
  templates = { "builtin" },
  auto_scroll = true,
  task_list = {
    direction = "float",
    min_height = 10,
    max_height = 20,
    default_detail = 1,
    width = 0.6,
    height = 0.6,
    bindings = {
      ["?"] = "ShowHelp",
      ["g?"] = "ShowHelp", 
      ["<CR>"] = "RunAction",
      ["<C-e>"] = "Edit",
      ["o"] = "Open",
      ["<C-v>"] = "OpenVsplit",
      ["<C-s>"] = "OpenSplit",
      ["<C-f>"] = "OpenFloat",
      ["<C-q>"] = "OpenQuickFix",
      ["p"] = "TogglePreview",
      ["<C-l>"] = "IncreaseDetail",
      ["<C-h>"] = "DecreaseDetail",
      ["L"] = "IncreaseAllDetail",
      ["H"] = "DecreaseAllDetail",
      ["["] = "DecreaseWidth",
      ["]"] = "IncreaseWidth",
      ["{"] = "PrevTask",
      ["}"] = "NextTask",
      ["<C-k>"] = "ScrollOutputUp",
      ["<C-j>"] = "ScrollOutputDown",
      ["q"] = "Close",
    },
  },
  -- Configure the floating window used for task templates that require input
  -- and the floating window used for editing tasks
  form = {
    border = "rounded",
    zindex = 40,
    -- Dimensions can be integers or a float between 0 and 1 (percentage of screen)
    min_width = 80,
    max_width = 0.9,
    width = nil,
    min_height = 10,
    max_height = 0.9,
    height = nil,
    -- Set any window options here (e.g. winhighlight)
    win_opts = {
      winblend = 10,
    },
  },
  task_win = {
    -- How much space to leave around the floating window
    padding = 2,
    border = "rounded",
    -- Set any window options here (e.g. winhighlight)
    win_opts = {
      winblend = 10,
    },
  },
  help_win = {
    border = "rounded",
    win_opts = {},
  },
  -- Aliases for bundles of components. Redefine the builtins, or create your own.
  component_aliases = {
    -- Most tasks are initialized with the default components
    default = {
      { "display_duration", detail_level = 2 },
      "on_output_summarize",
      "on_exit_set_status",
      "on_complete_notify",
      "on_complete_dispose",
    },
    -- Tasks from tasks.json use these components
    default_vscode = {
      "default",
      "on_result_diagnostics",
    },
  },
  bundles = {
    -- When saving a bundle with OverseerSaveBundle or save_bundle(), filter the tasks with
    -- these options (passed to list_tasks())
    save_task_opts = {
      bundleable = true,
    },
    -- Autoload bundled tasks when vim starts up
    autoload_bundled = false,
  },
  -- A list of components to preload on setup.
  -- Only matters if you want them to show up in component completions.
  preload_components = {},
  -- Controls when the parameter prompt is shown when running a template
  -- "always" Show when template has any params
  -- "missing" Show when template has any params not explicitly passed in
  -- "allow" Only show when a required param is missing
  default_template_prompt = "allow",
  -- For debugging purposes. This will create a log file in stdpath("log")
  log = {
    {
      type = "echo",
      level = vim.log.levels.WARN,
    },
    {
      type = "file",
      filename = "overseer.log",
      level = vim.log.levels.DEBUG,
    },
  },
})

-- ============================================================================
-- Custom Task Templates
-- ============================================================================

-- C++ Build Template
overseer.register_template({
  name = "cpp_build",
  builder = function()
    local file = vim.fn.expand("%:p")
    local file_stem = vim.fn.expand("%:t:r")
    local dir = vim.fn.expand("%:p:h")
    local is_cpp = file:match("%.cpp$") or file:match("%.cxx$") or file:match("%.cc$")
    local compiler = is_cpp and "g++" or "gcc"
    local std_flag = is_cpp and "-std=c++17" or ""
    
    return {
      cmd = { compiler },
      args = { "-g", "-O0", "-Wall", std_flag, "-o", file_stem, file },
      cwd = dir,
      components = {
        { "on_output_quickfix", open = true },
        "default",
      },
    }
  end,
  condition = {
    filetype = { "cpp", "c" },
  },
})

-- Make Build Template  
overseer.register_template({
  name = "make_build",
  builder = function()
    return {
      cmd = { "make" },
      args = {},
      components = {
        { "on_output_quickfix", open = true },
        "default",
      },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.filereadable("Makefile") == 1 or vim.fn.filereadable("makefile") == 1
    end,
  },
})

-- CMake Build Template
overseer.register_template({
  name = "cmake_configure",
  builder = function()
    return {
      cmd = { "cmake" },
      args = { "-B", "build", "-DCMAKE_BUILD_TYPE=Debug", "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      components = {
        { "on_output_quickfix", open = true },
        "default",
      },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.filereadable("CMakeLists.txt") == 1
    end,
  },
})

overseer.register_template({
  name = "cmake_build",
  builder = function()
    return {
      cmd = { "cmake" },
      args = { "--build", "build", "-j4" },
      components = {
        { "on_output_quickfix", open = true },
        "default",
      },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.filereadable("CMakeLists.txt") == 1 and vim.fn.isdirectory("build") == 1
    end,
  },
})

-- ============================================================================
-- Integration with existing keymaps
-- ============================================================================

-- CMake project initialization helper
vim.api.nvim_create_user_command('CMakeInit', function()
  local cwd = vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(cwd, ":t")
  
  -- Create basic CMakeLists.txt if it doesn't exist
  if vim.fn.filereadable("CMakeLists.txt") == 0 then
    local cmake_content = string.format([[
cmake_minimum_required(VERSION 3.16)
project(%s)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Debug build flags
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -Wall -Wextra")

# Add executable
add_executable(%s main.cpp)
]], project_name, project_name)
    
    vim.fn.writefile(vim.split(cmake_content, "\n"), "CMakeLists.txt")
    vim.notify("✅ Created CMakeLists.txt for project: " .. project_name, vim.log.levels.INFO)
  end
  
  -- Create main.cpp if it doesn't exist
  if vim.fn.filereadable("main.cpp") == 0 then
    local cpp_content = [[
#include <iostream>

int main() {
    std::cout << "Hello, CMake!" << std::endl;
    return 0;
}
]]
    vim.fn.writefile(vim.split(cpp_content, "\n"), "main.cpp")
    vim.notify("✅ Created main.cpp", vim.log.levels.INFO)
  end
  
  vim.notify("🚀 CMake project initialized! Use <leader>cc to configure", vim.log.levels.INFO)
end, { desc = 'Initialize CMake C++ project' })

-- Enhanced run commands
vim.api.nvim_create_user_command('OverseerQuickRun', function()
  local ft = vim.bo.filetype
  if vim.fn.filereadable("CMakeLists.txt") == 1 then
    if vim.fn.isdirectory("build") == 0 then
      overseer.run_template({ name = "cmake_configure" }, function(task)
        if task then
          vim.notify("🔧 Configuring CMake project", vim.log.levels.DEBUG)
        end
      end)
    else
      overseer.run_template({ name = "cmake_build" }, function(task)
        if task then
          vim.notify("🔨 Building CMake project", vim.log.levels.DEBUG)
        end
      end)
    end
  elseif ft == "cpp" or ft == "c" then
    overseer.run_template({ name = "cpp_build" }, function(task)
      if task then
        vim.notify("🔨 Building " .. vim.fn.expand("%:t"), vim.log.levels.DEBUG)
      end
    end)
  elseif ft == "make" or vim.fn.filereadable("Makefile") == 1 then
    overseer.run_template({ name = "make_build" })
  else
    vim.notify("No suitable build template for filetype: " .. ft, vim.log.levels.WARN)
  end
end, { desc = 'Quick run appropriate build task' })

-- Status check
vim.api.nvim_create_user_command('OverseerStatus', function()
  local tasks = overseer.list_tasks({ recent_first = true })
  print("=== Overseer Status ===")
  if #tasks == 0 then
    print("No tasks found")
  else
    print("Recent tasks:")
    for i, task in ipairs(tasks) do
      if i > 5 then break end -- Show only last 5
      local status = task:get_status()
      print(string.format("  %s: %s", task.name, status))
    end
  end
end, { desc = 'Show overseer task status' })

-- ============================================================================
-- Auto-completion and helpers
-- ============================================================================

-- Auto-run build when saving C/C++ files (optional)
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = {"*.cpp", "*.c", "*.h", "*.hpp"},
--   callback = function()
--     local choice = vim.fn.confirm("Auto-build after save?", "&Yes\n&No", 2)
--     if choice == 1 then
--       vim.cmd("OverseerQuickRun")
--     end
--   end,
--   desc = "Optional auto-build on save"
-- })

vim.notify("✅ Overseer task runner configured", vim.log.levels.DEBUG)