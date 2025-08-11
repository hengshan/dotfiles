-- ============================================================================
-- Miscellaneous Plugins Configuration
-- ============================================================================

-- ============================================================================
-- Claude Code Configuration - Moved to lazy.lua to avoid conflicts
-- ============================================================================
-- Claude Code is now configured directly in lazy.lua to ensure proper initialization

-- ============================================================================
-- Rust Tools Configuration
-- ============================================================================
local rust_tools_ok, rust_tools = pcall(require, "rust-tools")
if rust_tools_ok then
    rust_tools.setup({
        -- LSP configuration
        server = {
            on_attach = function(client, bufnr)
                -- Enable completion triggered by <c-x><c-o>
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
                
                -- Rust-specific keybindings
                local opts = { noremap=true, silent=true, buffer=bufnr }
                vim.keymap.set('n', '<leader>rh', rust_tools.hover_actions.hover_actions, 
                              vim.tbl_extend('force', opts, { desc = 'Rust hover actions' }))
                vim.keymap.set('n', '<leader>ra', rust_tools.code_action_group.code_action_group, 
                              vim.tbl_extend('force', opts, { desc = 'Rust code actions' }))
            end,
            settings = {
                ["rust-analyzer"] = {
                    assist = {
                        importGranularity = "module",
                        importPrefix = "self",
                    },
                    cargo = {
                        loadOutDirsFromCheck = true
                    },
                    procMacro = {
                        enable = true
                    },
                    checkOnSave = {
                        command = "clippy"
                    },
                },
            },
        },
        
        -- Debugging configuration
        dap = {
            adapter = {
                type = 'executable',
                command = 'lldb-vscode',
                name = 'rt_lldb',
            },
        },
    })
    
    vim.notify("✅ Rust Tools configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- Python Specific Plugins (from original config - were missing!)
-- ============================================================================

-- Python PEP8 indent plugin is loaded automatically when the plugin is installed
-- Python Black indent plugin is loaded automatically when the plugin is installed

-- Set up Python-specific keymaps and settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        
        -- Python-specific keymaps
        vim.keymap.set('n', '<leader>pr', ':!python3 %<CR>', 
                      { buffer = bufnr, desc = 'Run Python file' })
        vim.keymap.set('n', '<leader>pi', ':!python3 -i %<CR>', 
                      { buffer = bufnr, desc = 'Run Python interactive' })
        vim.keymap.set('n', '<leader>pm', ':!python3 -m ', 
                      { buffer = bufnr, desc = 'Run Python module' })
    end,
    desc = "Python specific settings and keymaps",
})

-- ============================================================================
-- TypeScript/React Specific Configuration (from original config)
-- ============================================================================

-- TypeScript and React plugins are loaded automatically
-- Set up TypeScript/React specific settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        
        -- TS/JS specific keymaps
        vim.keymap.set('n', '<leader>jr', ':!node %<CR>', 
                      { buffer = bufnr, desc = 'Run with Node.js' })
        vim.keymap.set('n', '<leader>jt', ':!npm test<CR>', 
                      { buffer = bufnr, desc = 'Run npm test' })
        vim.keymap.set('n', '<leader>jb', ':!npm run build<CR>', 
                      { buffer = bufnr, desc = 'Run npm build' })
        vim.keymap.set('n', '<leader>jd', ':!npm run dev<CR>', 
                      { buffer = bufnr, desc = 'Run npm dev' })
    end,
    desc = "TypeScript/JavaScript specific settings and keymaps",
})

-- ============================================================================
-- File Type Associations (from original lines 2484-2490)
-- ============================================================================

-- Assembly file extensions (already in autocmds.lua but keeping here for completeness)
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.nasm", "*.inc", "*.s" },
    callback = function()
        vim.bo.filetype = "asm"
    end,
    desc = "Set filetype to asm for additional assembly file extensions",
})

-- Additional useful file type associations
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.tsx" },
    callback = function()
        vim.bo.filetype = "typescriptreact"
    end,
    desc = "Set filetype for TSX files",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.jsx" },
    callback = function()
        vim.bo.filetype = "javascriptreact"
    end,
    desc = "Set filetype for JSX files",
})

-- ============================================================================
-- Performance and Startup Optimizations
-- ============================================================================

-- Disable some built-in plugins for faster startup
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logipat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_matchit = 1

-- vim.notify("✅ Miscellaneous plugins configured successfully", vim.log.levels.DEBUG)