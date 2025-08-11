-- ============================================================================
-- LSP Configuration - Restored from original config (lines 342-500)
-- ============================================================================

-- ============================================================================
-- Enhanced on_attach function (from original lines 350-362)
-- ============================================================================
local function enhanced_on_attach(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Buffer local mappings for LSP navigation
    local opts = { noremap=true, silent=true, buffer=bufnr }
    
    -- Basic LSP navigation keybindings (from original config)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)  -- Original used 'gh' not 'K'
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    
    -- Additional LSP keymaps
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format({ async = true })
    end, opts)
    
    -- Diagnostic navigation
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
    
    -- Highlight references under cursor (from original config)
    if client.server_capabilities.documentHighlightProvider then
        vim.cmd([[
            augroup lsp_document_highlight
                autocmd! * <buffer>
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
        ]])
    end
end

-- ============================================================================
-- LSP capabilities (from original lines 364-369)
-- ============================================================================
local function get_capabilities()
    -- LSP capabilities for nvim-cmp (from original config)
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    
    -- UFO folding capabilities (from original lines 366-369)
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }
    
    return capabilities
end

-- ============================================================================
-- Mason Setup (from original lines 372-380)
-- ============================================================================
local mason_ok, mason = pcall(require, "mason")
if mason_ok then
    mason.setup({
        ui = {
            border = 'rounded',
            icons = {
                package_installed = "✓",  -- From original
                package_pending = "➜",    -- From original  
                package_uninstalled = "✗" -- From original
            }
        }
    })
    -- vim.notify("✅ Mason configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- Mason-LSPConfig Setup with Handlers (from original lines 382-488)
-- ============================================================================
local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if mason_lspconfig_ok then
    local capabilities = get_capabilities()
    
    mason_lspconfig.setup({
        -- Ensure installed servers (from original lines 383-392)
        ensure_installed = {
            'pyright',       -- Python type checking
            'ruff',          -- Python linting (replaces ruff_lsp)
            'ts_ls',         -- TypeScript/JavaScript (replaces tsserver)
            'eslint',        -- JS/TS linting
            'lua_ls',        -- Lua LSP
            'jsonls',        -- JSON LSP
            'html',          -- HTML LSP
            'cssls',         -- CSS LSP
            'clangd',        -- C/C++ LSP
            'rust_analyzer', -- Rust LSP
            'cmake',         -- CMake LSP
        },
        automatic_installation = true,
        
        -- Handlers (from original lines 394-488)
        handlers = {
            -- Default handler for most servers (from original lines 396-401)
            function(server_name)
                require('lspconfig')[server_name].setup({
                    capabilities = capabilities,
                    on_attach = enhanced_on_attach,
                })
            end,
            
            -- Pyright specific configuration (from original lines 404-425)
            ['pyright'] = function()
                require('lspconfig').pyright.setup({
                    capabilities = capabilities,
                    on_attach = enhanced_on_attach,
                    settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "standard",       -- From original
                                autoSearchPaths = true,             -- From original
                                useLibraryCodeForTypes = true,      -- From original
                                disableOrganizeImports = true,      -- From original - KEY!
                                stubPath = vim.fn.expand("~/.pyright/stubs") -- From original
                            },
                            pythonPath = "python",                  -- From original
                            venvPath = ".venv"                      -- From original
                        },
                        pyright = {
                            disableOrganizeImports = true          -- From original - KEY!
                        }
                    }
                })
            end,
            
            -- Ruff specific configuration (from original lines 428-451)
            ['ruff'] = function()
                require('lspconfig').ruff.setup({
                    capabilities = capabilities,
                    on_attach = enhanced_on_attach,
                    init_options = {
                        settings = {
                            -- Enable all Ruff features (from original)
                            lint = {
                                enable = true
                            },
                            format = {
                                enable = true
                            },
                            organizeImports = {
                                enable = true
                            },
                            fixViolations = {
                                enable = true
                            },
                            args = { "--ignore=E501" }             -- From original
                        }
                    }
                })
            end,
            
            -- TypeScript specific configuration (from original lines 454-478)
            ['ts_ls'] = function()
                require('lspconfig').ts_ls.setup({
                    capabilities = capabilities,
                    on_attach = function(client, bufnr)
                        -- Disable formatting (from original line 458)
                        client.server_capabilities.documentFormattingProvider = false
                        enhanced_on_attach(client, bufnr)
                    end,
                    settings = {
                        completions = {
                            completeFunctionCalls = true           -- From original
                        },
                        typescript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",     -- From original
                                includeInlayVariableTypeHints = true        -- From original
                            }
                        },
                        javascript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",     -- From original
                                includeInlayVariableTypeHints = true        -- From original
                            }
                        }
                    },
                    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }
                })
            end,
            
            -- ESLint specific configuration (from original lines 481-487)
            ['eslint'] = function()
                require('lspconfig').eslint.setup({
                    capabilities = capabilities,
                    on_attach = enhanced_on_attach,
                })
            end,
            
            -- Lua LSP specific configuration for Neovim (GitHub #24119 solution)
            ['lua_ls'] = function()
                require('lspconfig').lua_ls.setup({
                    capabilities = capabilities,
                    on_attach = enhanced_on_attach,
                    on_init = function(client)
                        local path = client.workspace_folders[1].name
                        if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
                            return
                        end

                        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                            runtime = {
                                version = 'LuaJIT'
                            },
                            diagnostics = {
                                globals = { 'vim' }
                            },
                            workspace = {
                                checkThirdParty = false,
                                library = {
                                    vim.env.VIMRUNTIME
                                }
                            },
                            telemetry = {
                                enable = false
                            }
                        })
                    end,
                    settings = {
                        Lua = {}  -- Important: empty table, settings applied in on_init
                    }
                })
            end,
            
            -- Clangd specific configuration (from original lines 492-510)
            ['clangd'] = function()
                require('lspconfig').clangd.setup({
                    capabilities = capabilities,
                    on_attach = enhanced_on_attach,
                    cmd = {
                        "clangd",
                        "--background-index",           -- From original
                        "--clang-tidy",                 -- From original
                        "--header-insertion=iwyu",      -- From original
                        "--completion-style=detailed",  -- From original
                        "--function-arg-placeholders",  -- From original
                        "--fallback-style=llvm",        -- From original
                    },
                    init_options = {
                        usePlaceholders = true,         -- From original
                        completeUnimported = true,      -- From original
                        clangdFileStatus = true,        -- From original
                    },
                    filetypes = {"c", "cpp", "objc", "objcpp", "cuda"}, -- From original
                })
            end,
            
            -- CMake LSP configuration
            ['cmake'] = function()
                require('lspconfig').cmake.setup({
                    capabilities = capabilities,
                    on_attach = enhanced_on_attach,
                    filetypes = {"cmake"},
                    init_options = {
                        buildDirectory = "build"
                    },
                    settings = {
                        cmake = {
                            buildDirectory = "build"
                        }
                    }
                })
            end,
        }
    })
    -- vim.notify("✅ Mason-LSPConfig configured", vim.log.levels.DEBUG)
else
    -- Fallback: if mason-lspconfig is not available, setup lua_ls directly
    local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
    if lspconfig_ok then
        lspconfig.lua_ls.setup({
            capabilities = get_capabilities(),
            on_attach = enhanced_on_attach,
            on_init = function(client)
                local path = client.workspace_folders[1].name
                if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
                    return
                end

                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                    runtime = {
                        version = 'LuaJIT'
                    },
                    diagnostics = {
                        globals = { 'vim' }
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME
                        }
                    },
                    telemetry = {
                        enable = false
                    }
                })
            end,
            settings = {
                Lua = {}  -- Important: empty table, settings applied in on_init
            }
        })
    end
end

-- ============================================================================
-- Manual LSP Configurations (from original lines 491-520)
-- ============================================================================

-- Clangd configuration (from original lines 491-509)
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if lspconfig_ok then
    local capabilities = get_capabilities()
    
    -- Markdown-oxide configuration (from original lines 512-520)
    lspconfig.markdown_oxide.setup({
        capabilities = capabilities,
        filetypes = { "markdown" },
        on_attach = function(client, bufnr)
            -- Custom keybindings for markdown (from original)
            local opts = { buffer = bufnr, desc = "Hover docs" }
            vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, 
                          vim.tbl_extend('force', opts, { desc = "Goto definition" }))
        end,
    })
    
    -- vim.notify("✅ Manual LSP configurations loaded", vim.log.levels.DEBUG)
end

-- ============================================================================
-- LSP Capability Separation (from original lines 2371-2393) - CRITICAL!
-- ============================================================================
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp_attach_capabilities', { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then return end
        
        -- Separate Pyright and Ruff capabilities to prevent conflicts (CRITICAL!)
        if client.name == 'ruff' then
            -- Ruff: formatting, linting, code actions, import organization
            client.server_capabilities.hoverProvider = false                -- From original
            client.server_capabilities.definitionProvider = false           -- From original
            client.server_capabilities.referencesProvider = false           -- From original
            client.server_capabilities.documentFormattingProvider = true    -- From original
            client.server_capabilities.codeActionProvider = true            -- From original
        elseif client.name == 'pyright' then
            -- Pyright: type checking, hover, navigation
            client.server_capabilities.documentFormattingProvider = false         -- From original
            client.server_capabilities.documentRangeFormattingProvider = false   -- From original
            client.server_capabilities.codeActionProvider = false                 -- From original
        end
    end,
    desc = 'Separate Pyright and Ruff capabilities to avoid conflicts',
})

-- ============================================================================
-- Python-specific keybindings (from original lines 2401-2433)
-- ============================================================================
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        
        -- Format with Ruff (from original lines 2407-2414)
        vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format({ 
                async = true,
                filter = function(client)
                    return client.name == "ruff"  -- Only use Ruff for formatting
                end
            })
        end, { buffer = bufnr, desc = 'Format with Ruff' })
        
        -- Code actions (from original lines 2417-2423)
        vim.keymap.set('n', '<leader>ca', function()
            vim.lsp.buf.code_action()
        end, { buffer = bufnr, desc = 'Code actions' })
        
        vim.keymap.set('v', '<leader>ca', function()
            vim.lsp.buf.range_code_action()
        end, { buffer = bufnr, desc = 'Range code actions' })
        
        -- Organize imports (from original lines 2426-2431)
        vim.keymap.set('n', '<leader>oi', function()
            vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" } },
                apply = true,
            })
        end, { buffer = bufnr, desc = 'Organize imports' })
    end,
})

-- ============================================================================
-- Diagnostic Configuration with modern sign API (replaces deprecated sign_define)
-- ============================================================================
vim.diagnostic.config({
    virtual_text = {
        enabled = true,
        source = 'always',
        prefix = '●',
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = ' ',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.HINT] = ' ',
            [vim.diagnostic.severity.INFO] = ' ',
        }
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})

-- ============================================================================
-- LSP Utility Commands (from original lines 2396-2398)
-- ============================================================================
vim.api.nvim_create_user_command('LspRestart', function()
    vim.cmd('LspRestart')
end, { desc = 'Restart LSP servers' })

-- vim.notify("✅ LSP configuration completed successfully", vim.log.levels.DEBUG)