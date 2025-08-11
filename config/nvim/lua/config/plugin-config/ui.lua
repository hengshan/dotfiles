-- ============================================================================
-- UI Plugins Configuration - Restored from original config
-- ============================================================================

-- ============================================================================
-- Lualine Configuration
-- ============================================================================
local status_ok, lualine = pcall(require, "lualine")
if status_ok then
    lualine.setup({
        options = {
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = { 'alpha', 'dashboard', 'NvimTree' },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = { 'filename' },
            lualine_x = { 'encoding', 'fileformat', 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' }
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { 'filename' },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {}
        },
    })
    vim.notify("✅ Lualine configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- GitSigns Configuration
-- ============================================================================
local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
if gitsigns_ok then
    gitsigns.setup({
        signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
        },
        numhl = false,
        linehl = false,
        watch_gitdir = {
            interval = 1000,
            follow_files = true,
        },
        current_line_blame = false,
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        
        -- Keymaps
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns
            
            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end
            
            -- Navigation
            map('n', ']c', function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() gs.next_hunk() end)
                return '<Ignore>'
            end, {expr=true, desc="Next git hunk"})
            
            map('n', '[c', function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() gs.prev_hunk() end)
                return '<Ignore>'
            end, {expr=true, desc="Previous git hunk"})
            
            -- Actions
            map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>', {desc="Stage hunk"})
            map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', {desc="Reset hunk"})
            map('n', '<leader>hS', gs.stage_buffer, {desc="Stage buffer"})
            map('n', '<leader>hu', gs.undo_stage_hunk, {desc="Undo stage hunk"})
            map('n', '<leader>hR', gs.reset_buffer, {desc="Reset buffer"})
            map('n', '<leader>hp', gs.preview_hunk, {desc="Preview hunk"})
            map('n', '<leader>hb', function() gs.blame_line{full=true} end, {desc="Blame line"})
            map('n', '<leader>tb', gs.toggle_current_line_blame, {desc="Toggle line blame"})
            map('n', '<leader>hd', gs.diffthis, {desc="Diff this"})
            map('n', '<leader>hD', function() gs.diffthis('~') end, {desc="Diff this ~"})
            map('n', '<leader>td', gs.toggle_deleted, {desc="Toggle deleted"})
            
            -- Text object
            map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc="Select hunk"})
        end
    })
    vim.notify("✅ GitSigns configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- Indent Blankline Configuration
-- ============================================================================
local ibl_ok, ibl = pcall(require, "ibl")
if ibl_ok then
    ibl.setup({
        indent = {
            char = '│',
            tab_char = '│',
        },
        scope = {
            enabled = true,
            show_start = true,
            show_end = false,
            injected_languages = false,
            highlight = { 'Function', 'Label' },
            priority = 500,
        },
        exclude = {
            filetypes = {
                'help',
                'alpha',
                'dashboard',
                'neo-tree',
                'Trouble',
                'lazy',
                'mason',
                'notify',
                'toggleterm',
                'lazyterm',
            },
        },
    })
    vim.notify("✅ Indent Blankline configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- Trouble Configuration
-- ============================================================================
local trouble_ok, trouble = pcall(require, "trouble")
if trouble_ok then
    trouble.setup({
        position = "bottom",
        height = 10,
        width = 50,
        icons = true,
        mode = "workspace_diagnostics",
        fold_open = '',
        fold_closed = '',
        group = true,
        padding = true,
        action_keys = {
            close = "q",
            cancel = "<esc>",
            refresh = "r",
            jump = { "<cr>", "<tab>" },
            open_split = { "<c-x>" },
            open_vsplit = { "<c-v>" },
            open_tab = { "<c-t>" },
            jump_close = { "o" },
            toggle_mode = "m",
            toggle_preview = "P",
            hover = "K",
            preview = "p",
            close_folds = { "zM", "zm" },
            open_folds = { "zR", "zr" },
            toggle_fold = { "zA", "za" },
            previous = "k",
            next = "j",
        },
        indent_lines = true,
        auto_open = false,
        auto_close = false,
        auto_preview = true,
        auto_fold = false,
        auto_jump = { "lsp_definitions" },
        signs = {
            error = '',
            warning = '',
            hint = '',
            information = '',
            other = '﫠',
        },
        use_diagnostic_signs = false,
    })

    -- Trouble keymaps
    vim.keymap.set('n', '<leader>xx', '<cmd>TroubleToggle<cr>', { desc = 'Toggle trouble' })
    vim.keymap.set('n', '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', { desc = 'Workspace diagnostics' })
    vim.keymap.set('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', { desc = 'Document diagnostics' })
    vim.keymap.set('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', { desc = 'Location list' })
    vim.keymap.set('n', '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', { desc = 'Quickfix' })
    vim.keymap.set('n', 'gR', '<cmd>TroubleToggle lsp_references<cr>', { desc = 'LSP references' })
    
    vim.notify("✅ Trouble configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- UFO (Advanced Folding) Configuration - From original lines 2324-2368
-- ============================================================================
local ufo_ok, ufo = pcall(require, "ufo")
if ufo_ok then
    -- UFO setup with provider selector from original config
    ufo.setup({
        provider_selector = function(bufnr, filetype, buftype)
            -- Provider selection from original config (lines 2325-2337)
            if filetype == 'python' then
                return {'treesitter', 'indent'}
            elseif filetype == 'javascript' or filetype == 'typescript' or 
                   filetype == 'typescriptreact' or filetype == 'javascriptreact' then
                return {'lsp', 'treesitter'}
            elseif filetype == 'lua' then
                return {'treesitter', 'indent'}
            else
                -- Default provider (from original)
                return {'treesitter', 'indent'}
            end
        end,
        
        -- Custom fold text handler from original config (lines 2340-2367)
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local suffix = (' 󰁂 %d '):format(endLnum - lnum)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0
            
            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    local hlGroup = chunk[2]
                    table.insert(newVirtText, {chunkText, hlGroup})
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end
            
            table.insert(newVirtText, {suffix, 'MoreMsg'})
            return newVirtText
        end
    })
    
    vim.notify("✅ UFO (Advanced Folding) configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- Which-key Configuration (Updated for v3 API)
-- ============================================================================
local which_key_ok, which_key = pcall(require, "which-key")
if which_key_ok then
    which_key.setup({
        preset = "modern",  -- Use modern preset
        delay = 500,        -- Delay before showing which-key popup
        expand = 1,         -- Expand groups when <= n mappings
        notify = true,      -- Show notification for invalid key
        
        -- Plugins configuration
        plugins = {
            marks = true,
            registers = true,
            spelling = {
                enabled = true,
                suggestions = 20,
            },
            presets = {
                operators = false,
                motions = true,
                text_objects = true,
                windows = true,
                nav = true,
                z = true,
                g = true,
            },
        },
        
        -- Window configuration
        win = {
            border = "rounded",
            padding = { 1, 2 },
            title = true,
            title_pos = "center",
            zindex = 1000,
        },
        
        -- Layout configuration  
        layout = {
            width = { min = 20 },
            spacing = 3,
            align = "left",
        },
        
        -- Key configuration
        keys = {
            scroll_down = "<c-d>",
            scroll_up = "<c-u>",
        },
        
        -- Sort mappings
        sort = { "local", "order", "group", "alphanum", "mod" },
        
        -- Disable for certain filetypes
        disable = {
            ft = {},
            bt = {},
        },
    })
    
    -- Register key mappings with descriptions (new v3 API)
    which_key.add({
        { "<leader>f", group = "find" },
        { "<leader>d", group = "debug" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "git hunks" },
        { "<leader>l", group = "lsp" },
        { "<leader>r", group = "refactor" },
        { "<leader>w", group = "workspace" },
        { "<leader>c", group = "cmake/code" },
        { "<leader>cb", desc = "Build Project" },
        { "<leader>cc", desc = "Configure CMake" },
        { "<leader>x", group = "trouble" },
        { "<leader>s", group = "search/snippets" },
        { "<leader>b", group = "buffer" },
        { "<leader>a", group = "ai/assistant" },
        { "<leader>j", group = "javascript" },
        { "<leader>p", group = "python" },
        { "<leader>t", group = "terminal/toggle" },
        { "<leader>o", group = "overseer/tasks" },
        { "g", group = "goto" },
        { "z", group = "fold" },
        { "]", group = "next" },
        { "[", group = "prev" },
    })
    
    vim.notify("✅ Which-key v3 configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- LSP Signature Configuration (from original config - was missing!)
-- ============================================================================
local signature_ok, signature = pcall(require, "lsp_signature")
if signature_ok then
    signature.setup({
        bind = true,
        handler_opts = {
            border = "rounded"
        },
        hint_enable = true,
        hint_prefix = "🐼 ",
    })
    vim.notify("✅ LSP Signature configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- Maximize Plugin Configuration (from original line 337-338)
-- ============================================================================
local maximize_ok, maximize = pcall(require, "maximize")
if maximize_ok then
    maximize.setup()
    -- Keymap from original config
    vim.keymap.set('n', '<leader>z', "<cmd>lua require('maximize').toggle()<CR>", 
                  { noremap = true, silent = true, desc = 'Toggle maximize window' })
    vim.notify("✅ Maximize plugin configured", vim.log.levels.DEBUG)
end

-- ============================================================================
-- Set Colorscheme (from original was gruvbox)
-- ============================================================================
pcall(function()
    vim.cmd('colorscheme gruvbox')
    vim.notify("✅ Colorscheme set to gruvbox", vim.log.levels.DEBUG)
end)

-- vim.notify("✅ All UI plugins configured successfully", vim.log.levels.DEBUG)