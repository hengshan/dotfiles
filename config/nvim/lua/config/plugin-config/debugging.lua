-- ============================================================================
-- Debugging Configuration - Basic setup (will be enhanced later)
-- ============================================================================

-- ============================================================================
-- DAP Setup - Defer loading to avoid circular dependency
-- ============================================================================
local function get_dap()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then
        vim.notify("nvim-dap not found!", vim.log.levels.ERROR)
        return nil
    end
    return dap
end

-- ============================================================================
-- DAP UI Setup (from original lines 784-824)
-- ============================================================================
local dapui_ok, dapui = pcall(require, "dapui")
if dapui_ok then
    -- Ensure web-devicons is loaded for DAP UI
    pcall(require, "nvim-web-devicons")
    
    dapui.setup({
        controls = {
            element = "repl",           -- From original
            enabled = true,             -- From original  
        },
        element_mappings = {},
        expand_lines = true,            -- From original
        icons = {
            expanded = "▾",
            collapsed = "▸",
            current_frame = "▸"
        },
        floating = {
            border = "single",          -- From original
            max_height = 0.9,           -- From original
            max_width = 0.9,            -- From original
            mappings = {
                close = { "q", "<Esc>" } -- From original
            }
        },
        force_buffers = true,           -- From original
        layouts = {
            {
                elements = {
                    { id = "scopes", size = 0.25 },      -- From original
                    { id = "breakpoints", size = 0.25 }, -- From original
                    { id = "stacks", size = 0.25 },      -- From original
                    { id = "watches", size = 0.25 }      -- From original
                },
                position = "left",       -- From original
                size = 40               -- From original
            },
            {
                elements = {
                    { id = "console", size = 0.5 },     -- From original - supports input
                    { id = "repl", size = 0.5 }         -- From original - debug commands
                },
                position = "bottom",     -- From original
                size = 10               -- From original - bigger for input visibility
            }
        },
        render = {
            indent = 1,                 -- From original
            max_value_lines = 100       -- From original
        }
    })
    
    -- Auto open/close DAP UI (deferred)
    vim.defer_fn(function()
        local dap = get_dap()
        if dap then
            dap.listeners.after.event_initialized['dapui_config'] = function()
                dapui.open()
            end
            -- Remove auto-close listeners to keep dapui open after debugging session ends
            -- Users can manually toggle with <leader>du if needed
        end
    end, 100)
    
    -- vim.notify("✅ DAP UI configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- DAP Virtual Text Setup
-- ============================================================================
local dap_virtual_text_ok, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
if dap_virtual_text_ok then
    dap_virtual_text.setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        filter_references_pattern = '<module',
        virt_text_pos = 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
    })
    -- vim.notify("✅ DAP Virtual Text configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- Advanced Python DAP Configuration with Environment Detection
-- ============================================================================

-- Load Python debug module
local python_debug_ok, python_debug = pcall(require, "config.plugin-config.python-debug")
if python_debug_ok then
    -- vim.notify("✅ Python environment detection loaded", vim.log.levels.DEBUG)
    
    -- Auto-setup Python debugging on FileType event (safer than defer_fn)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
            vim.defer_fn(function()
                python_debug.auto_debug_setup()
            end, 1000)
        end,
        once = true,
        desc = "Auto-setup Python debugging on first Python file"
    })
else
    -- Fallback basic Python configuration (deferred)
    vim.defer_fn(function()
        local dap = get_dap()
        if dap then
            dap.adapters.python = {
                type = 'executable',
                command = 'python3',
                args = { '-m', 'debugpy.adapter' },
            }

            dap.configurations.python = {
                {
                    type = 'python',
                    request = 'launch',
                    name = 'Launch file',
                    program = '${file}',
                    pythonPath = function()
                        return vim.fn.exepath('python3') or vim.fn.exepath('python')
                    end,
                    console = "integratedTerminal",
                },
            }
        end
    end, 300)
    
    vim.notify("⚠️ Using fallback Python debug configuration", vim.log.levels.WARN)
end

-- ============================================================================
-- JavaScript/TypeScript DAP Configuration (from original lines 778-781)
-- ============================================================================
local dap_vscode_js_ok, dap_vscode_js = pcall(require, "dap-vscode-js")
if dap_vscode_js_ok then
    dap_vscode_js.setup({
        debugger_path = vim.fn.stdpath('data') .. '/plugged/vscode-js-debug', -- From original - vim-plug path
        adapters = { 'pwa-node', 'pwa-chrome' }  -- From original
    })
    
    -- Basic JS/TS configurations (deferred)
    vim.defer_fn(function()
        local dap = get_dap()
        if dap then
            dap.configurations.javascript = {
                {
                    type = 'pwa-node',
                    request = 'launch',
                    name = 'Launch file',
                    program = '${file}',
                    cwd = '${workspaceFolder}',
                    console = 'integratedTerminal',
                },
            }
            
            dap.configurations.typescript = dap.configurations.javascript
            dap.configurations.javascriptreact = dap.configurations.javascript
            dap.configurations.typescriptreact = dap.configurations.javascript
        end
    end, 150)
    
    -- vim.notify("✅ JavaScript/TypeScript debugging configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- Basic Debugging Keymaps (from original lines 2244-2274)
-- ============================================================================

-- Core debugging controls (deferred to avoid circular dependency)
vim.defer_fn(function()
    local dap = get_dap()
    if not dap then return end
    
    -- Core debugging controls (from original config)
    vim.keymap.set('n', '<F5>', dap.continue, { desc = "Debug: Start/Continue" })
    vim.keymap.set('n', '<F10>', dap.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set('n', '<F11>', dap.step_into, { desc = "Debug: Step Into" })
    vim.keymap.set('n', '<F12>', dap.step_out, { desc = "Debug: Step Out" })

    -- Breakpoint management (from original config)
    vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set('n', '<Leader>B', function()
        dap.set_breakpoint(vim.fn.input('Condition: '))
    end, { desc = "Debug: Conditional Breakpoint" })

    -- Log point (from original lines 2253-2255)
    vim.keymap.set('n', '<Leader>lp', function()
        dap.set_breakpoint(nil, nil, vim.fn.input('Log point: '))
    end, { desc = "Debug: Log Point" })

    -- REPL and session management (from original config)
    vim.keymap.set('n', '<Leader>dr', dap.repl.open, { desc = "Debug: Open REPL" })
    vim.keymap.set('n', '<Leader>dl', dap.run_last, { desc = "Debug: Run Last" })

    -- Terminate debugging (from original lines 2258-2267)
    vim.keymap.set('n', '<leader>dn', function()
        dap.terminate()
    end, { desc = "Debug: Terminate" })

    vim.keymap.set('n', '<Leader>dx', function() 
        dap.terminate()
        vim.schedule(function()
            dap.close()
        end)
    end, { desc = "Debug: Force Terminate and Close Session" })

    -- Expression evaluation (from original lines 2268-2272)
    vim.keymap.set({'n', 'v'}, '<Leader>de', function() 
        if dapui_ok then
            dapui.eval() 
        else
            dap.eval()
        end
    end, { desc = "Debug: Evaluate expression" })

    vim.keymap.set('n', '<Leader>dE', function()
        local expr = vim.fn.input('Expression: ')
        if dapui_ok then
            dapui.eval(expr)
        else
            dap.eval(expr)
        end
    end, { desc = "Debug: Evaluate custom expression" })
end, 200)

-- UI toggle (from original line 2274)
if dapui_ok then
    vim.keymap.set('n', '<Leader>du', dapui.toggle, { desc = "Debug: Toggle UI" })
end

-- ============================================================================
-- Quick Setup Commands and Enhanced Keybindings
-- ============================================================================

-- Load C/C++ debug module with immediate configuration
local cpp_debug_ok, cpp_debug = pcall(require, "config.plugin-config.cpp-debug")
if cpp_debug_ok then
    -- vim.notify("✅ C/C++ compilation and debugging loaded", vim.log.levels.DEBUG)
    
    -- Setup autocmd for C/C++ files only
    local cpp_configured = false
    
    -- Function to configure C/C++ debugging
    local function setup_cpp_debugging()
        if not cpp_configured then
            cpp_configured = true
            vim.schedule(function()
                local success = cpp_debug.configure_dap_cpp()
                if success then
                    vim.notify("🔧 C/C++ debugging configured", vim.log.levels.INFO)
                else
                    vim.notify("❌ Failed to configure C/C++ debugging", vim.log.levels.ERROR)
                end
            end)
        end
    end
    
    -- Multiple event triggers to ensure configuration
    vim.api.nvim_create_autocmd({"FileType", "BufEnter", "BufRead"}, {
        pattern = {"*.c", "*.cpp", "*.h", "*.hpp"},
        callback = function()
            local ft = vim.bo.filetype
            if ft == "c" or ft == "cpp" then
                setup_cpp_debugging()
            end
        end,
        desc = "Auto-setup C/C++ debugging on C/C++ files"
    })
    
    -- Also trigger on filetype event
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {"c", "cpp"},
        callback = setup_cpp_debugging,
        desc = "Auto-setup C/C++ debugging on filetype detection"
    })
else
    vim.notify("⚠️ C/C++ debug module not available", vim.log.levels.WARN)
end

-- Load Assembly debug module with immediate configuration
local asm_debug_ok, asm_debug = pcall(require, "config.plugin-config.assembly-debug")
if asm_debug_ok then
    -- vim.notify("✅ Assembly language support loaded", vim.log.levels.DEBUG)
    
    -- Setup autocmd for Assembly files only  
    local asm_configured = false
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {"asm", "nasm"},
        callback = function()
            if not asm_configured then
                asm_configured = true
                vim.defer_fn(function()
                    asm_debug.configure_dap_asm()
                end, 100)
            end
        end,
        desc = "Auto-setup Assembly debugging on Assembly files"
    })
else
    vim.notify("⚠️ Assembly debug module not available", vim.log.levels.WARN)
end

-- Enhanced DAP quick setup based on filetype
vim.api.nvim_create_user_command('DapQuickSetup', function()
    local filetype = vim.bo.filetype
    
    if filetype == "python" then
        if python_debug_ok then
            python_debug.auto_debug_setup()
        else
            vim.notify("⚠️ Python debug module not available", vim.log.levels.WARN)
        end
    elseif filetype == "c" or filetype == "cpp" then
        if cpp_debug_ok then
            local success = cpp_debug.configure_dap_cpp()
            if success then
                vim.notify("✅ C/C++ debugging configured successfully", vim.log.levels.INFO)
            else
                vim.notify("❌ Failed to configure C/C++ debugging", vim.log.levels.ERROR)
            end
        else
            vim.notify("⚠️ C/C++ debug module not available", vim.log.levels.WARN)
        end
    elseif filetype == "asm" then
        if asm_debug_ok then
            asm_debug.configure_dap_asm()
        else
            vim.notify("⚠️ Assembly debug module not available", vim.log.levels.WARN)
        end
    elseif filetype == "javascript" or filetype == "typescript" or 
           filetype == "javascriptreact" or filetype == "typescriptreact" then
        vim.notify("🚀 JavaScript/TypeScript debugging ready", vim.log.levels.INFO)
    else
        vim.notify("🔧 Basic debugging setup for " .. filetype, vim.log.levels.INFO)
    end
end, { desc = 'Quick debug setup based on filetype' })

-- Command to check DAP configuration status
vim.api.nvim_create_user_command('DapStatus', function()
    local dap = require('dap')
    local filetype = vim.bo.filetype
    
    print("=== DAP Status ===")
    print("Current filetype: " .. filetype)
    print("Available configurations:")
    
    for lang, configs in pairs(dap.configurations) do
        if configs and #configs > 0 then
            print("  " .. lang .. ": " .. #configs .. " configuration(s)")
        end
    end
    
    if filetype and dap.configurations[filetype] then
        print("\nCurrent filetype (" .. filetype .. ") has " .. #dap.configurations[filetype] .. " configuration(s)")
    else
        print("\nNo configuration found for current filetype: " .. filetype)
    end
end, { desc = 'Check DAP configuration status' })

-- Simple test command to verify debugging module is loaded
vim.api.nvim_create_user_command('DapTest', function()
    print("=== DAP Test ===")
    print("Debugging module loaded: Yes")
    print("Available commands:")
    print("  :DapQuickSetup - Setup debugging for current filetype")
    print("  :DapStatus - Check configuration status")
    print("  <leader>dc - Configure C/C++ debugging")
    print("Current filetype: " .. vim.bo.filetype)
end, { desc = 'Test DAP debugging setup' })

-- Enhanced Python debugging keybindings
if python_debug_ok then
    vim.keymap.set('n', '<leader>dq', python_debug.select_python_interpreter, { desc = 'Quick Python debug setup' })
    vim.keymap.set('n', '<leader>dp', python_debug.auto_debug_setup, { desc = 'Auto Python debug setup' })
    vim.keymap.set('n', '<leader>di', python_debug.show_python_env, { desc = 'Show Python environment info' })
end

-- Enhanced C/C++ debugging keybindings
if cpp_debug_ok then
    vim.keymap.set('n', '<leader>dc', function()
        local success = cpp_debug.configure_dap_cpp()
        if success then
            vim.notify("✅ C/C++ debugging configured successfully", vim.log.levels.INFO)
        else
            vim.notify("❌ Failed to configure C/C++ debugging", vim.log.levels.ERROR)
        end
    end, { desc = 'Configure C/C++ debugging (GDB)' })
    vim.keymap.set('n', '<leader>df', cpp_debug.force_recompile_cpp, { desc = 'Force recompile C/C++ with debug info' })
    vim.keymap.set('n', '<leader>dt', cpp_debug.debug_cpp_interactive, { desc = 'Debug C/C++ (Interactive/External Terminal)' })
    vim.keymap.set('n', '<leader>cb', cpp_debug.build_project, { desc = 'Build C/C++ project' })
    vim.keymap.set('n', '<leader>cc', cpp_debug.clean_build, { desc = 'Clean C/C++ build' })
end

-- Enhanced Assembly debugging keybindings
if asm_debug_ok then
    vim.keymap.set('n', '<leader>da', asm_debug.configure_dap_asm, { desc = 'Configure Assembly debugging (GDB)' })
    vim.keymap.set('n', '<leader>ac', asm_debug.compile_asm_only, { desc = 'Compile assembly file' })
    vim.keymap.set('n', '<leader>ar', asm_debug.compile_and_run_asm, { desc = 'Compile and run assembly' })
    vim.keymap.set('n', '<leader>ax', asm_debug.clean_assembly_build, { desc = 'Clean assembly build artifacts' })
end

-- vim.notify("✅ Advanced debugging configured with multi-language support", vim.log.levels.DEBUG)