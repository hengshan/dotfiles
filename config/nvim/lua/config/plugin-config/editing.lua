-- ============================================================================
-- Editing Enhancement Plugins Configuration - Restored from original config
-- ============================================================================

-- ============================================================================
-- nvim-surround Configuration (from original line 186)
-- ============================================================================
local surround_ok, surround = pcall(require, "nvim-surround")
if surround_ok then
    surround.setup({
        keymaps = {
            insert = '<C-g>s',
            insert_line = '<C-g>S',
            normal = 'ys',
            normal_cur = 'yss',
            normal_line = 'yS',
            normal_cur_line = 'ySS',
            visual = 'S',
            visual_line = 'gS',
            delete = 'ds',
            change = 'cs',
        },
    })
    vim.notify("✅ nvim-surround configured", vim.log.levels.INFO)
end

-- ============================================================================
-- nvim-autopairs Configuration (from original lines 188-196)
-- ============================================================================
local autopairs_ok, autopairs = pcall(require, "nvim-autopairs")
if autopairs_ok then
    autopairs.setup({
        check_ts = true,  -- Enable treesitter support
        ts_config = {
            lua = {'string'},         
            javascript = {'template_string'},  
            python = {'string'},      
        },
        disable_filetype = { 'TelescopePrompt', 'vim' },
        disable_in_macro = false,
        disable_in_visualblock = false,
        disable_in_replace_mode = true,
        ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
        enable_moveright = true,
        enable_afterquote = true,
        enable_check_bracket_line = true,
        enable_bracket_in_quote = true,
        enable_abbr = false,
        break_undo = true,
        check_comma = true,
        map_cr = true,
        map_bs = true,
        map_c_h = false,
        map_c_w = false,
        -- Additional fast wrap configuration
        fast_wrap = {
            map = '<M-e>',
            chars = { '{', '[', '(', '"', "'" },
            pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
            offset = 0,
            end_key = '$',
            keys = 'qwertyuiopzxcvbnmasdfghjkl',
            check_comma = true,
            highlight = 'PmenuSel',
            highlight_grey = 'LineNr'
        },
    })
    vim.notify("✅ nvim-autopairs configured", vim.log.levels.INFO)
end

-- ============================================================================
-- Comment.nvim Configuration
-- ============================================================================
local comment_ok, comment = pcall(require, "Comment")
if comment_ok then
    comment.setup({
        padding = true,
        sticky = true,
        ignore = nil,
        toggler = {
            line = 'gcc',
            block = 'gbc',
        },
        opleader = {
            line = 'gc',
            block = 'gb',
        },
        extra = {
            above = 'gcO',
            below = 'gco',
            eol = 'gcA',
        },
        mappings = {
            basic = true,
            extra = true,
            extended = false,
        },
        pre_hook = nil,
        post_hook = nil,
    })
    
    -- Override the basic comment keymaps from keymaps.lua
    vim.keymap.set('n', '<leader>/', 'gcc', { desc = 'Toggle line comment', remap = true })
    vim.keymap.set('v', '<leader>/', 'gc', { desc = 'Toggle block comment', remap = true })
    
    vim.notify("✅ Comment.nvim configured", vim.log.levels.INFO)
end

-- ============================================================================
-- ToggleTerm Configuration  
-- ============================================================================
local toggleterm_ok, toggleterm = pcall(require, "toggleterm")
if toggleterm_ok then
    toggleterm.setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = 'float',
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
            border = 'curved',
            winblend = 0,
            highlights = {
                border = 'Normal',
                background = 'Normal',
            },
        },
    })

    -- Terminal key mappings
    local function set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', 'jj', [[<C-\><C-n>]], opts)  -- User's preferred jj
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    end

    vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        callback = set_terminal_keymaps,
    })
    
    vim.notify("✅ ToggleTerm configured", vim.log.levels.INFO)
end

-- ============================================================================
-- Refactoring.nvim Configuration (from original lines 2277-2312)
-- ============================================================================
local refactoring_ok, refactoring = pcall(require, "refactoring")
if refactoring_ok then
    refactoring.setup({
        -- From original config (lines 2278-2290)
        prompt_func_return_type = {
            python = false,
            typescript = true,
            javascript = true,
        },
        prompt_func_param_type = {
            python = false,
            typescript = true,
            javascript = true,
        },
        printf_statements = {},
        print_var_statements = {},
    })

    -- Refactoring keymaps from original config (lines 2295-2312)
    
    -- Debug Print Variable - 打印变量名和值 (from original line 2295)
    vim.keymap.set({"x", "n"}, "<leader>rp", function() 
        refactoring.debug.print_var() 
    end, { desc = "Debug Print Variable" })

    -- Debug Print Statement - 只打印你输入的内容 (from original lines 2298-2300)
    vim.keymap.set("n", "<leader>rps", function() 
        refactoring.debug.printf({below = false}) 
    end, { desc = "Debug Print Statement" })
    
    vim.keymap.set("n", "<leader>rpa", function() 
        refactoring.debug.printf({below = false}) 
    end, { desc = "Debug Print Above" })
    
    vim.keymap.set("n", "<leader>rpb", function() 
        refactoring.debug.printf({below = true}) 
    end, { desc = "Debug Print Below" })

    -- Debug Cleanup - 清理所有调试打印 (from original line 2303)
    vim.keymap.set("n", "<leader>rc", function() 
        refactoring.debug.cleanup({}) 
    end, { desc = "Debug Cleanup" })

    -- Load telescope extension and setup keymap (from original lines 2306-2312)
    pcall(function()
        require('telescope').load_extension('refactoring')
        vim.keymap.set({"n", "x"}, "<leader>rr", function() 
            require('telescope').extensions.refactoring.refactors() 
        end, { desc = "Refactor Menu" })
    end)
    
    vim.notify("✅ Refactoring.nvim configured", vim.log.levels.INFO)
end

-- ============================================================================
-- nvim-lint Configuration (from original config - was missing!)
-- ============================================================================
local lint_ok, lint = pcall(require, "lint")
if lint_ok then
    -- Configure linters by filetype
    lint.linters_by_ft = {
        python = {'ruff'},  -- Use ruff for Python linting
        javascript = {'eslint'},
        typescript = {'eslint'},
        javascriptreact = {'eslint'},
        typescriptreact = {'eslint'},
        lua = {'luacheck'},
        bash = {'shellcheck'},
        sh = {'shellcheck'},
    }

    -- Auto-lint on save and text change
    vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "InsertLeave" }, {
        callback = function()
            pcall(lint.try_lint)
        end,
    })
    
    vim.notify("✅ nvim-lint configured", vim.log.levels.INFO)
end

vim.notify("✅ All editing plugins configured successfully", vim.log.levels.INFO)