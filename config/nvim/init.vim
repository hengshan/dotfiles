set clipboard=unnamedplus
" Leader key
let mapleader = " "
set timeoutlen=400  " Time to wait for a mapped sequence (leader key combo)
set ttimeoutlen=50  " Faster response for key codes (e.g., arrow keys)

inoremap jj <Esc>
vnoremap <leader>b c**<C-r>"**<Esc>

"K to split and create a new line with indent and insert
nnoremap K a<CR><Esc> 


" 注释配置
" 单行注释切换
function! ToggleComment()
    let line = getline('.')
    if line =~ '^\s*#'
        silent! s/^\(\s*\)# \?/\1/
    else
        silent! s/^\(\s*\)/\1# /
    endif
endfunction

nnoremap <leader>/ :call ToggleComment()<CR>

" 多行注释切换
function! ToggleCommentRange() range
    for line_num in range(a:firstline, a:lastline)
        let line = getline(line_num)
        if line =~ '^\s*#'
            call setline(line_num, substitute(line, '^\(\s*\)# \?', '\1', ''))
        else
            call setline(line_num, substitute(line, '^\(\s*\)', '\1# ', ''))
        endif
    endfor
endfunction

vnoremap <leader>c :call ToggleCommentRange()<CR>

" ============================
" Auto-install vim-plug
" ============================
let autoload_plug = has('nvim') ? 
      \ stdpath('data') . '/site/autoload/plug.vim' :
      \ '~/.vim/autoload/plug.vim'

if empty(glob(autoload_plug))
  silent execute '!curl -fLo ' . shellescape(autoload_plug) . ' --create-dirs 
        \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
endif

" Source vim-plug
execute 'source ' . autoload_plug

" ============================
" Plugin Installation
" ============================
call plug#begin()
" highlight syntax
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" File Management & Search
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'

" LSP & Completion
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-cmdline'
Plug 'onsails/lspkind.nvim'

" Snippet Engine + JS Regexp Support
Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'}
Plug 'rafamadriz/friendly-snippets'

" Python specific
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'jeetsukumaran/vim-python-indent-black'

" python debug
Plug 'mfussenegger/nvim-dap-python'

" TypeScript/React specific
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

" Debugging
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'mxsdev/nvim-dap-vscode-js'
Plug 'nvim-neotest/nvim-nio'

" UI Enhancements
Plug 'folke/trouble.nvim'
Plug 'ray-x/lsp_signature.nvim'

" Navigation & Movement
Plug 'easymotion/vim-easymotion'
Plug 'justinmk/vim-sneak'

" Text Editing
Plug 'kylechui/nvim-surround'
Plug 'windwp/nvim-autopairs'

" async lint
Plug 'mfussenegger/nvim-lint'

" git diff
Plug 'sindrets/diffview.nvim'

" Claude Code Neovim Plugin
Plug 'greggh/claude-code.nvim'

" Maximize vim panel
Plug 'declancm/maximize.nvim'

" refactoring
Plug 'ThePrimeagen/refactoring.nvim'

" UFO 折叠插件
Plug 'kevinhwang91/nvim-ufo'
Plug 'kevinhwang91/promise-async'

call plug#end()

" Auto-install missing plugins
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

" ============================
" Basic Vim Settings
" ============================
set number
set relativenumber
set hlsearch
set incsearch
set ignorecase
set smartcase
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
set smartindent
set expandtab       " 将Tab转换为空格（推荐）

" ============================
" Plugin Configurations (Lua)
" ============================
lua << EOF
require('nvim-treesitter.configs').setup({
  ensure_installed = { "markdown", "markdown_inline", "lua", "vim", "bash","python","typescript", "tsx", "javascript"},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

-- nvim-surround setup
require("nvim-surround").setup({})

-- nvim-autopairs setup
require("nvim-autopairs").setup({
  check_ts = true,
  ts_config = {
    lua = {'string'},
    javascript = {'template_string'},
    python = {'string'},
  }
})

-- Telescope setup
require("telescope").setup({
  defaults = {
    prompt_prefix = "🔍 ",
    selection_caret = "➤ ",
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist/",
      "build/",
      "__pycache__/",
      "*.pyc"
    },
    layout_config = {
      horizontal = {
        preview_width = 0.6,
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true
    },
    live_grep = {
      additional_args = function(opts)
        return {"--hidden"}
      end
    },
  }
})

-- ============================
-- Claude Code Setup
-- ============================
require("claude-code").setup({
  -- Terminal window settings
  window = {
    split_ratio = 0.45,      -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
    position = "botright",  -- Position of the window: "botright", "topleft", "vertical", "float", etc.
    enter_insert = true,    -- Whether to enter insert mode when opening Claude Code
    hide_numbers = true,    -- Hide line numbers in the terminal window
    hide_signcolumn = true, -- Hide the sign column in the terminal window
    
    -- Floating window configuration (only applies when position = "float")
    float = {
      width = "80%",        -- Width: number of columns or percentage string
      height = "80%",       -- Height: number of rows or percentage string
      row = "center",       -- Row position: number, "center", or percentage string
      col = "center",       -- Column position: number, "center", or percentage string
      relative = "editor",  -- Relative to: "editor" or "cursor"
      border = "rounded",   -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
    },
  },
  -- File refresh settings
  refresh = {
    enable = true,           -- Enable file change detection
    updatetime = 100,        -- updatetime when Claude Code is active (milliseconds)
    timer_interval = 1000,   -- How often to check for file changes (milliseconds)
    show_notifications = true, -- Show notification when files are reloaded
  },
  -- Git project settings
  git = {
    use_git_root = true,     -- Set CWD to git root when opening Claude Code (if in git project)
  },
  -- Shell-specific settings
  shell = {
    separator = '&&',        -- Command separator used in shell commands
    pushd_cmd = 'pushd',     -- Command to push directory onto stack (e.g., 'pushd' for bash/zsh, 'enter' for nushell)
    popd_cmd = 'popd',       -- Command to pop directory from stack (e.g., 'popd' for bash/zsh, 'exit' for nushell)
  },
  -- Command settings
  command = "claude",        -- Command used to launch Claude Code
  -- Command variants
  command_variants = {
    -- Conversation management
    continue = "--continue", -- Resume the most recent conversation
    resume = "--resume",     -- Display an interactive conversation picker
    -- Output options
    verbose = "--verbose",   -- Enable verbose logging with full turn-by-turn output
  },
  -- Keymaps
  keymaps = {
    toggle = {
      normal = "<leader><leader>",       -- Normal mode keymap for toggling Claude Code, false to disable
      terminal = "<leader><leader>",     -- Terminal mode keymap for toggling Claude Code, false to disable
      variants = {
        continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
        verbose = "<leader>cV",  -- Normal mode keymap for Claude Code with verbose flag
      },
    },
    window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
    scrolling = true,         -- Enable scrolling keymaps (<C-f/b>) for page up/down
  }
})

-- Add these functions to adjust nvimtree width
local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Default mappings
  api.config.mappings.default_on_attach(bufnr)
end

-- nvim-tree setup
require("nvim-tree").setup({
  disable_netrw = true,
  hijack_netrw = true,
  on_attach = my_on_attach,
  view = {
    width = 35,
    side = "left",
  },
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
      },
    },
  },
  filters = {
    dotfiles = false,
    custom = { ".git", "node_modules", ".cache", "__pycache__" },
  },
  git = {
    enable = true,
    ignore = false,
  },
})

-- maximize vim panel setup
require('maximize').setup()
vim.api.nvim_set_keymap('n', '<leader>z', "<cmd>lua require('maximize').toggle()<CR>", { noremap = true, silent = true })


-- LSP capabilities for nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

-- Initialize Mason (LSP installer)
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'pyright',       -- Python type checking
    'ruff',          -- Python linting (replaces ruff_lsp)
    'ts_ls',         -- TypeScript/JavaScript (replaces tsserver)
    'eslint',        -- JS/TS linting
    'lua_ls',        -- Lua LSP (if you use Lua)
    'jsonls',        -- JSON LSP
    'html',          -- HTML LSP
    'cssls'          -- CSS LSP
  },
  automatic_installation = true,
  handlers = {
      -- 默认处理器 - 处理大部分服务器
      function(server_name)
        require('lspconfig')[server_name].setup({
          capabilities = capabilities,
          on_attach = enhanced_on_attach,
        })
      end,
      
      -- Pyright 特定配置
      ['pyright'] = function()
        require('lspconfig').pyright.setup({
          capabilities = capabilities,
          on_attach = enhanced_on_attach,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "off",
                diagnosticSeverityOverrides = {
                  reportUnusedImport = "warning",
                  reportMissingImports = "error"
                },
                disableOrganizeImports = true,
                stubPath = vim.fn.expand("~/.pyright/stubs"),
                typeCheckingMode = "standard"
              },
              pythonPath = "python",
              venvPath = ".venv"
            }
          }
        })
      end,
      
      -- Ruff 特定配置
      ['ruff'] = function()
        require('lspconfig').ruff.setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            client.server_capabilities.hoverProvider = false
            client.server_capabilities.documentFormattingProvider = true
          end,
          init_options = {
            settings = {
              args = { "--ignore=E501" }
            }
          }
        })
      end,
      
      -- TypeScript 特定配置
      ['ts_ls'] = function()
        require('lspconfig').ts_ls.setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
          end,
          settings = {
            completions = {
              completeFunctionCalls = true
            },
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayVariableTypeHints = true
              }
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayVariableTypeHints = true
              }
            }
          },
          filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }
        })
      end,
      
      -- ESLint 特定配置
      ['eslint'] = function()
        require('lspconfig').eslint.setup({
          capabilities = capabilities
        })
      end,
    }
})

-- Set up markdown-oxide
require('lspconfig').markdown_oxide.setup({
  capabilities = capabilities,
  filetypes = { "markdown" },
  on_attach = function(client, bufnr)
    -- Keybindings (customize as needed)
    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover docs" })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr, desc = "Goto definition" })
  end,
})

-- LuaSnip
require('luasnip').config.setup({
  history = true,
  update_events = 'TextChanged,TextChangedI'
})
require('luasnip.loaders.from_vscode').lazy_load()


-- nvim-cmp setup
local cmp = require'cmp'
local lspkind = require('lspkind')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require('luasnip').expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require('luasnip').jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'luasnip', priority = 750 },
    { name = 'buffer', priority = 500 },
    { name = 'path', priority = 250 },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
      ellipsis_char = '...',
    })
  }
})

-- Use buffer source for `/` and `?`
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for `:`
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- Integrate autopairs with cmp
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

-- DAP (Debugging)
require('dap-vscode-js').setup({
  debugger_path = vim.fn.stdpath('data') .. '/lazy/vscode-js-debug',
  adapters = { 'pwa-node', 'pwa-chrome' }
})

--debug python
require('dapui').setup()
require("dap-python").setup("/home/hank/.local/share/pipx/venvs/debugpy/bin/python")
local dap = require('dap')
local dapui = require('dapui')

-- Debugging keymaps
vim.keymap.set('n', '<F5>', dap.continue, { desc = "Continue/Start Debugging" })
vim.keymap.set('n', '<F10>', dap.step_over, { desc = "Step Over" })
vim.keymap.set('n', '<F11>', dap.step_into, { desc = "Step Into" })
vim.keymap.set('n', '<F12>', dap.step_out, { desc = "Step Out" })
vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
vim.keymap.set('n', '<Leader>B', function()
  dap.set_breakpoint(vim.fn.input('Condition: '))
end, { desc = "Conditional Breakpoint" })
vim.keymap.set('n', '<Leader>lp', function()
  dap.set_breakpoint(nil, nil, vim.fn.input('Log point: '))
end, { desc = "Log Point" })
vim.keymap.set('n', '<Leader>dr', dap.repl.open, { desc = "REPL" })
vim.keymap.set('n', '<Leader>dl', dap.run_last, { desc = "Run Last" })
vim.keymap.set('n', '<leader>de', function()
  require('dap').terminate()
end, { desc = "Terminate DAP" })

-- UI toggle
vim.keymap.set('n', '<Leader>du', dapui.toggle, { desc = "Toggle DAP UI" })

-- Refactoring.nvim setup
require('refactoring').setup({
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

-- Enhanced LSP on_attach function for better code actions
local function enhanced_on_attach(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  
  -- Buffer local mappings for LSP
  local opts = { noremap=true, silent=true, buffer=bufnr }
  
  -- Code actions with better UI
  vim.keymap.set('n', '<leader>ca', function()
    vim.lsp.buf.code_action()
  end, opts)
  
  -- Range code actions for visual selections
  vim.keymap.set('v', '<leader>ca', function()
    vim.lsp.buf.range_code_action()
  end, opts)
end


-- Debug Print Variable - 打印变量名和值
vim.keymap.set({"x", "n"}, "<leader>rp", function() require('refactoring').debug.print_var() end, { desc = "Debug Print Variable" })

-- Debug Print Statement - 只打印你输入的内容
vim.keymap.set("n", "<leader>rps", function() require('refactoring').debug.printf({below = false}) end, { desc = "Debug Print Statement" })
vim.keymap.set("n", "<leader>rpa", function() require('refactoring').debug.printf({below = false}) end, { desc = "Debug Print Above" })
vim.keymap.set("n", "<leader>rpb", function() require('refactoring').debug.printf({below = true}) end, { desc = "Debug Print Below" })

-- Debug Cleanup - 清理所有调试打印
vim.keymap.set("n", "<leader>rc", function() require('refactoring').debug.cleanup({}) end, { desc = "Debug Cleanup" })

-- telescope refactoring
require('telescope').load_extension('refactoring')
vim.keymap.set(
  {"n", "x"}, 
  "<leader>rr", 
  function() require('telescope').extensions.refactoring.refactors() end,
  { desc = "Refactor Menu" }
)
-- ============================
-- UFO (折叠) Configuration
-- ============================

-- 设置折叠方法
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- UFO 设置 - 基于你现有的 LSP 配置
require('ufo').setup({
  provider_selector = function(bufnr, filetype, buftype)
    -- 针对不同文件类型使用不同的折叠提供者
    if filetype == 'python' then
      return {'treesitter', 'indent'}
    elseif filetype == 'javascript' or filetype == 'typescript' or filetype == 'typescriptreact' or filetype == 'javascriptreact' then
      return {'lsp', 'treesitter'}
    elseif filetype == 'lua' then
      return {'treesitter', 'indent'}
    else
      -- 默认使用 treesitter 和 indent
      return {'treesitter', 'indent'}
    end
  end,
  
  -- 折叠文本自定义
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

-- ============================
-- 调试代码 - 检查 LSP 重复启动
-- ============================
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    print("LSP attached: " .. client.name .. " (buffer: " .. args.buf .. ")")
  end,
})
EOF

" ============================
" Keybindings
" ============================

" Clear search highlighting
nnoremap <C-n> :nohl<CR>

" Telescope keybindings
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fr <cmd>Telescope oldfiles<cr>
nnoremap <leader>fc <cmd>Telescope commands<cr>

" nvim-tree keybindings
nnoremap <leader>e <cmd>NvimTreeToggle<cr>
nnoremap <leader>E <cmd>NvimTreeFocus<cr>

" LSP keybindings (will work when LSP is set up)
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gh <cmd>lua vim.lsp.buf.hover()<CR>
" Less common/safety-needed actions (leader-based)
nnoremap <silent> <leader>rn <cmd>lua vim.lsp.buf.rename()<CR>

" Claude code keybindings
nnoremap <leader>ai <cmd>ClaudeCode<CR>
nnoremap <leader>ad <cmd>ClaudeCode "--dangerously-skip-permissions"<CR>

" === Filetype Specific ===
autocmd FileType python setlocal shiftwidth=4 tabstop=4
autocmd FileType typescript,typescriptreact,javascript,javascriptreact setlocal shiftwidth=2 tabstop=2

" ============================
" Auto Commands
" ============================

" Auto-open nvim-tree when starting with a directory
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | 
  \ exe 'NvimTreeOpen' argv()[0] | wincmd p | ene | exe 'cd' argv()[0] | endif

" Close nvim-tree if it's the last window
autocmd BufEnter * if winnr('$') == 1 && exists('b:NvimTree') && b:NvimTree.isTabTree() | quit | endif

" ============================
" Plugin-specific Settings
" ============================

" EasyMotion settings
let g:EasyMotion_do_mapping = 0 " Disable default mappings
nmap <Leader>s <Plug>(easymotion-overwin-f2)
" Jump to start of word (forward/backward)
nmap <Leader>ss <Plug>(easymotion-overwin-w)

" Jump to start of line
nmap <Leader>g <Plug>(easymotion-overwin-line)
let g:EasyMotion_smartcase = 1

" Sneak settings
let g:sneak#label = 1

" === Window Resizing Shortcuts ===
" Increase/Decrease Height (Horizontal Splits)
nnoremap <silent> <Leader>k :resize +4<CR>
nnoremap <silent> <Leader>j :resize -4<CR>
nnoremap <silent> <Leader>h :vertical resize -4<CR>
nnoremap <silent> <Leader>l :vertical resize +4<CR>
nnoremap <Leader>; <C-w>=

" open a new terminal at the bottom
nnoremap <leader>t :belowright split \| terminal<CR>
" save the current buffer
nnoremap <leader>w :w<CR>

" terminal escape
tnoremap <Esc><Esc> <C-\><C-n>

" show lsp diagnostic info
nnoremap <silent> <leader>le :lua vim.diagnostic.open_float()<CR>

" 只设置 UFO 特有的增强功能
nnoremap zR <cmd>lua require('ufo').openAllFolds()<CR>
nnoremap zM <cmd>lua require('ufo').closeAllFolds()<CR>

" 折叠预览
nnoremap <leader>fp <cmd>lua 
\   local winid = require('ufo').peekFoldedLinesUnderCursor()
\   if not winid then
\     vim.lsp.buf.hover()
\   end
\<CR>
