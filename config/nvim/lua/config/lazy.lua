-- ============================================================================
-- Lazy.nvim Plugin Manager Setup
-- ============================================================================

-- Install lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  -- ============================================================================
  -- Core Syntax and Language Support
  -- ============================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("config.plugin-config.treesitter")
    end,
  },

  -- ============================================================================
  -- File Management & Search
  -- ============================================================================
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make"
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    },
    config = function()
      require("config.plugin-config.telescope")
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,  -- Don't lazy load so auto-open works
    priority = 1000,  -- Load early
    cmd = { "Neotree" },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
      { "<leader>E", "<cmd>Neotree focus<cr>", desc = "Focus file tree" },
      { "<leader>ef", "<cmd>Neotree reveal<cr>", desc = "Find current file in tree" },
      { "<leader>er", "<cmd>Neotree refresh<cr>", desc = "Refresh file tree" },
      { "<leader>eg", "<cmd>Neotree git_status<cr>", desc = "Git status tree" },
      { "<leader>eb", "<cmd>Neotree buffers<cr>", desc = "Buffer tree" },
    },
    config = function()
      require("config.plugin-config.neo-tree")
    end,
  },

  { "nvim-tree/nvim-web-devicons",
    opts = {}
  },

  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },

  -- ============================================================================
  -- LSP & Completion System
  -- ============================================================================
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("config.plugin-config.lsp")
    end,
  },

  -- Completion Engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-vsnip",     -- Original used vsnip
      "hrsh7th/vim-vsnip",     -- Original vsnip support
      "onsails/lspkind.nvim",  -- Icons for completion
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("config.plugin-config.completion")
    end,
  },

  -- Snippet Engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
  },

  -- ============================================================================
  -- Python Specific (from original config - was missing!)
  -- ============================================================================
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },

  {
    "jeetsukumaran/vim-python-indent-black",
    ft = "python",
  },

  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
  },

  -- ============================================================================
  -- TypeScript/React Specific (from original config - was missing!)
  -- ============================================================================
  {
    "leafgarland/typescript-vim",
    ft = { "typescript", "typescriptreact" },
  },

  {
    "peitalin/vim-jsx-typescript",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  },

  {
    "styled-components/vim-styled-components",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    branch = "main",
  },

  -- ============================================================================
  -- Debugging System
  -- ============================================================================
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "mxsdev/nvim-dap-vscode-js",
      "nvim-tree/nvim-web-devicons",  -- For DAP UI icons
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: Open REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
    },
    config = function()
      require("config.plugin-config.debugging")
    end,
  },

  -- ============================================================================
  -- UI Enhancements
  -- ============================================================================
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle trouble" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace diagnostics" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document diagnostics" },
    },
    config = function()
      local trouble = require("trouble")
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
      })
    end,
  },

  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    config = function()
      require("lsp_signature").setup({
        bind = true,
        handler_opts = {
          border = "rounded"
        },
        hint_enable = true,
        hint_prefix = "🐼 ",
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
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
      })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
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
      })
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ibl").setup({
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
    end,
  },

  -- ============================================================================
  -- Navigation & Movement (from original config - was missing!)
  -- ============================================================================
  {
    "easymotion/vim-easymotion",
    keys = {
      { "<leader>s", "<Plug>(easymotion-f2)", desc = "EasyMotion: Find 2 characters" },
      { "<leader>ss", "<Plug>(easymotion-bd-w)", desc = "EasyMotion: Jump to word" },
      { "<leader>g", "<Plug>(easymotion-bd-jk)", desc = "EasyMotion: Jump to line" },
    },
    config = function()
      require("config.plugin-config.navigation")
    end,
  },

  {
    "justinmk/vim-sneak",
    keys = { "s", "S" },
    config = function()
      vim.g.sneak_label = 1
    end,
  },

  -- ============================================================================
  -- Text Editing Enhancements
  -- ============================================================================
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
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
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true,
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
      
      -- Integrate with nvim-cmp
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  {
    "numToStr/Comment.nvim",
    keys = {
      { "<leader>/", "gcc", desc = "Toggle line comment", remap = true },
      { "<leader>/", "gc", desc = "Toggle block comment", mode = "v", remap = true },
    },
    config = function()
      require("Comment").setup({
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
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      -- Configuration is in ui.lua
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<c-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>t", ":belowright split | terminal<CR>", desc = "Open terminal at bottom" },
    },
  },

  -- ============================================================================
  -- Code Quality and Linting (from original config - was missing!)
  -- ============================================================================
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- ============================================================================
  -- Git Integration (from original config - was missing!)
  -- ============================================================================
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diffview" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File history" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    },
    config = function()
      require("config.plugin-config.git")
    end,
  },

  -- ============================================================================
  -- Claude Code Integration (Local Installation)
  -- ============================================================================
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    lazy = false,  -- Don't lazy load to ensure commands are registered
    priority = 100,  -- Load after basic setup but before user interactions
    keys = {
      { "<leader>ai", "<cmd>ClaudeCode<CR>", desc = "Claude Code" },
      { "<leader>ad", "<cmd>ClaudeCode --dangerously-skip-permissions<CR>", desc = "Claude Code (skip permissions)" },
      { "<leader><leader>", function() require("claude-code").toggle() end, desc = "Toggle Claude Code" },
    },
    config = function()
      require("claude-code").setup({
        -- Terminal window settings (from original config)
        window = {
          split_ratio = 0.45,      -- Percentage of screen for the terminal window
          position = "float",       -- Position: "botright", "topleft", "vertical", "float"
          enter_insert = true,      -- Enter insert mode when opening Claude Code
          hide_numbers = true,      -- Hide line numbers in terminal window
          hide_signcolumn = true,   -- Hide sign column in terminal window
          
          -- Floating window configuration (from original lines 242-249)
          float = {
            width = "80%",        -- Width: number of columns or percentage string
            height = "80%",       -- Height: number of rows or percentage string
            row = "center",       -- Row position: number, "center", or percentage
            col = "center",       -- Column position: number, "center", or percentage
            relative = "editor",  -- Relative to: "editor" or "cursor"
            border = "rounded",   -- Border style: "none", "single", "double", "rounded"
          },
        },
        
        -- File refresh settings (from original lines 252-257)
        refresh = {
          enable = true,           -- Enable file change detection
          updatetime = 100,        -- updatetime when Claude Code is active (ms)
          timer_interval = 1000,   -- How often to check for file changes (ms)
          show_notifications = true, -- Show notification when files are reloaded
        },
        
        -- Git project settings (from original lines 259-261)
        git = {
          use_git_root = true,     -- Set CWD to git root when opening Claude Code
        },
        
        -- Shell-specific settings (from original lines 263-267)
        shell = {
          separator = '&&',        -- Command separator used in shell commands
          pushd_cmd = 'pushd',     -- Command to push directory onto stack
          popd_cmd = 'popd',       -- Command to pop directory from stack
        },
        
        -- Command settings (from original line 269)
        command = "/home/hank/.claude/local/claude",
        
        -- Command variants (from original lines 271-277)
        command_variants = {
          continue = "--continue", -- Resume the most recent conversation
          resume = "--resume",     -- Display an interactive conversation picker
          verbose = "--verbose",   -- Enable verbose logging
        },
        
        -- Keymaps (from original lines 279-291)
        keymaps = {
          toggle = {
            normal = "<leader><leader>",       -- Normal mode keymap for toggling
            terminal = "<leader><leader>",     -- Terminal mode keymap for toggling
            variants = {
              continue = "<leader>cc",       -- Continue flag
              verbose = "<leader>cv",        -- Verbose flag
              resume = "<leader>cr",         -- Resume flag
            },
          },
          window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
          scrolling = true,         -- Enable scrolling keymaps (<C-f/b>)
        }
      })
    end,
  },

  -- ============================================================================
  -- Window Management (from original config - was missing!)
  -- ============================================================================
  {
    "declancm/maximize.nvim",
    keys = {
      { "<leader>z", function() require("maximize").toggle() end, desc = "Toggle maximize window" },
    },
  },

  -- ============================================================================
  -- Refactoring Tools
  -- ============================================================================
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>rp", function() require('refactoring').debug.print_var() end, mode = {"x", "n"}, desc = "Debug Print Variable" },
      { "<leader>rc", function() require('refactoring').debug.cleanup({}) end, desc = "Debug Cleanup" },
      { "<leader>rr", function() require('telescope').extensions.refactoring.refactors() end, mode = {"n", "x"}, desc = "Refactor Menu" },
    },
    config = function()
      -- Configuration is in editing.lua
    end,
  },

  -- ============================================================================
  -- Advanced Folding (UFO)
  -- ============================================================================
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
      { "<leader>zc", "zc", desc = "Close fold under cursor" },
      { "<leader>zo", "zo", desc = "Open fold under cursor" },
      { "<leader>fp", function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then vim.lsp.buf.hover() end
      end, desc = "Peek fold or hover" },
    },
    config = function()
      require("ufo").setup({
        provider_selector = function(bufnr, filetype, buftype)
          if filetype == 'python' then
            return {'treesitter', 'indent'}
          elseif filetype == 'javascript' or filetype == 'typescript' or 
                 filetype == 'typescriptreact' or filetype == 'javascriptreact' then
            return {'lsp', 'treesitter'}
          elseif filetype == 'lua' then
            return {'treesitter', 'indent'}
          else
            return {'treesitter', 'indent'}
          end
        end,
        
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
    end,
  },

  -- ============================================================================
  -- Language Specific Enhancements
  -- ============================================================================
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("config.plugin-config.misc")
    end,
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- ============================================================================
  -- Colorschemes
  -- ============================================================================
  {
    "gruvbox-community/gruvbox",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme gruvbox")
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = true,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
  },

}, {
  -- Lazy.nvim configuration options
  defaults = {
    lazy = false, -- should plugins be lazy-loaded by default?
    version = nil, -- always use the latest git commit
  },
  install = {
    missing = true, -- install missing plugins on startup
    colorscheme = { "gruvbox", "habamax" }, -- try to load one of these colorschemes when starting an installation during startup
  },
  checker = {
    enabled = true, -- automatically check for plugin updates
    notify = false, -- get a notification when new updates are found
  },
  change_detection = {
    enabled = true,
    notify = false, -- get a notification when changes are found
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin",
      },
    },
  },
})

-- vim.notify("✅ Lazy.nvim configured successfully", vim.log.levels.DEBUG)
