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
  ensure_installed = {"markdown", "markdown_inline", "lua", "vim", "bash", "python", "typescript", "tsx", "javascript", "html", "css", "json", "yaml", "toml", "c", "cpp", "asm", "cmake", "make", "dockerfile", "gitignore", "regex", "comment"},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true,
    -- 对某些语言禁用，因为可能冲突
    disable = { "python" },  -- Python 有专门的缩进插件
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
    position = "float",  -- Position of the window: "botright", "topleft", "vertical", "float", etc.
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
  command = "/home/hank/.claude/local/claude",        -- Command used to launch Claude Code
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
        continue = "<leader>cc", -- Normal mode keymap for Claude Code with continue flag
        verbose = "<leader>cv",  -- Normal mode keymap for Claude Code with verbose flag
        resume = "<leader>cr",  -- Normal mode keymap for Claude Code with resume flag
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

-- ============================
-- LSP Configuration
-- ============================
-- This section configures Language Server Protocol with:
-- - Pyright: Type checking, hover, navigation (Python)
-- - Ruff: Formatting, linting, code actions (Python)
-- - Capability separation to avoid conflicts
-- - Python-specific keybindings for formatting and code actions

-- LSP on_attach function for basic navigation
local function enhanced_on_attach(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  
  -- Buffer local mappings for LSP navigation
  local opts = { noremap=true, silent=true, buffer=bufnr }
  
  -- Basic LSP navigation keybindings
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
end

-- LSP capabilities for nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

-- Initialize Mason (LSP installer)
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

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
      
      -- Pyright 特定配置 - 仅用于类型检查
      ['pyright'] = function()
        require('lspconfig').pyright.setup({
          capabilities = capabilities,
          on_attach = enhanced_on_attach,  -- 简化：让LspAttach autocmd处理能力分离
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "standard",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                disableOrganizeImports = true,  -- 关键：禁用导入组织
                stubPath = vim.fn.expand("~/.pyright/stubs")
              },
              pythonPath = "python",
              venvPath = ".venv"
            },
            pyright = {
              disableOrganizeImports = true  -- 禁用Pyright的导入组织
            }
          }
        })
      end,
      
      -- Ruff 特定配置 - 专门用于格式化、linting和代码动作
      ['ruff'] = function()
        require('lspconfig').ruff.setup({
          capabilities = capabilities,
          on_attach = enhanced_on_attach,  -- 简化：让LspAttach autocmd处理能力分离
          init_options = {
            settings = {
              -- 启用所有Ruff功能
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

-- Set up clangd
require('lspconfig').clangd.setup({
  capabilities = capabilities,
  on_attach = enhanced_on_attach,
  cmd = {
    "clangd",
    "--background-index", 
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
  filetypes = {"c", "cpp", "objc", "objcpp", "cuda"},
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

-- 替换你现有的 LuaSnip 配置
local luasnip = require('luasnip')

luasnip.config.setup({
  history = true,
  update_events = 'TextChanged,TextChangedI',
  delete_check_events = "TextChanged",
})

-- 方法1：自动查找 friendly-snippets
local function find_friendly_snippets()
  -- 常见的插件管理器路径
  local possible_paths = {
    vim.fn.stdpath("data") .. "/plugged/friendly-snippets",           -- vim-plug
    vim.fn.stdpath("data") .. "/lazy/friendly-snippets",              -- lazy.nvim  
    vim.fn.stdpath("data") .. "/site/pack/packer/start/friendly-snippets", -- packer
    "~/.local/share/nvim/plugged/friendly-snippets",                  -- 手动安装
  }
  
  for _, path in ipairs(possible_paths) do
    local expanded_path = vim.fn.expand(path)
    if vim.fn.isdirectory(expanded_path) == 1 then
      return expanded_path
    end
  end
  
  -- friendly-snippets not found in common locations
  return nil
end

-- 方法2：更智能的查找
local function smart_load_snippets()
  -- 先尝试默认加载（让 LuaSnip 自己找）
  require('luasnip.loaders.from_vscode').lazy_load()
  
  -- 然后尝试手动路径
  local snippets_path = find_friendly_snippets()
  if snippets_path then
    require('luasnip.loaders.from_vscode').lazy_load({paths = {snippets_path}})
  end
end

-- 替换你现有的加载代码
smart_load_snippets()

-- 设置快捷键 目前Tab可以用
vim.keymap.set({"i"}, "<C-K>", function() 
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  end
end, {silent = true})

vim.keymap.set({"i", "s"}, "<C-L>", function() 
  if luasnip.jumpable(1) then
    luasnip.jump(1)
  end
end, {silent = true})

vim.keymap.set({"i", "s"}, "<C-J>", function() 
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  end
end, {silent = true})

-- 方法1：查询当前文件类型的 snippets
vim.keymap.set('n', '<leader>sl', function()
  local filetype = vim.bo.filetype
  local snippets = luasnip.get_snippets(filetype)
  
  print("=== Snippets for " .. filetype .. " ===")
  for _, snippet in ipairs(snippets) do
    local desc = snippet.name or snippet.dscr or "No description"
    print("  " .. snippet.trigger .. " → " .. desc)
  end
  print("Total: " .. #snippets .. " snippets")
end, { desc = "List current filetype snippets" })

-- 方法2：查询所有语言的 snippets
vim.keymap.set('n', '<leader>sL', function()
  local all_snippets = luasnip.get_snippets()
  
  print("=== All Available Snippets ===")
  for ft, snippets in pairs(all_snippets) do
    if #snippets > 0 then
      print(ft .. " (" .. #snippets .. " snippets):")
      for i, snippet in ipairs(snippets) do
        if i <= 5 then -- 只显示前5个
          print("  " .. snippet.trigger)
        end
      end
      if #snippets > 5 then
        print("  ... and " .. (#snippets - 5) .. " more")
      end
      print("")
    end
  end
end, { desc = "List all snippets" })

-- 搜索特定 snippet
vim.keymap.set('n', '<leader>sf', function()
  local search_term = vim.fn.input("Search snippet: ")
  if search_term == "" then return end
  
  local filetype = vim.bo.filetype
  local snippets = luasnip.get_snippets(filetype)
  
  print("=== Search Results for '" .. search_term .. "' ===")
  local found = 0
  for _, snippet in ipairs(snippets) do
    if string.find(snippet.trigger:lower(), search_term:lower()) or 
       (snippet.name and string.find(snippet.name:lower(), search_term:lower())) then
      print("  " .. snippet.trigger .. " → " .. (snippet.name or ""))
      found = found + 1
    end
  end
  
  if found == 0 then
    print("No snippets found matching '" .. search_term .. "'")
  else
    print("Found " .. found .. " matching snippets")
  end
end, { desc = "Search snippets" })

-- 快速添加 snippet 的快捷键
vim.keymap.set('n', '<leader>sa', function()
  -- 获取当前选中的文本作为 snippet 内容
  local filetype = vim.bo.filetype
  local trigger = vim.fn.input("Snippet trigger: ")
  if trigger == "" then return end
  
  local description = vim.fn.input("Description: ")
  local content = vim.fn.input("Content: ")
  
  -- 创建简单的 snippet
  luasnip.add_snippets(filetype, {
    luasnip.snippet(trigger, {
      luasnip.text_node(content),
      luasnip.insert_node(0)
    })
  })
  
  print("✓ Added snippet '" .. trigger .. "' for " .. filetype)
end, { desc = "Add simple snippet" })

-- 打开 snippets 编辑文件
vim.keymap.set('n', '<leader>se', function()
  local snippets_file = vim.fn.stdpath("config") .. "/lua/snippets/init.lua"
  
  -- 如果文件不存在，创建基本模板
  if vim.fn.filereadable(snippets_file) == 0 then
    local template = [[-- Custom snippets
local luasnip = require('luasnip')
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node

-- Add your custom snippets here
luasnip.add_snippets("python", {
  -- Example snippet here
})
]]
    vim.fn.mkdir(vim.fn.fnamemodify(snippets_file, ":h"), "p")
    vim.fn.writefile(vim.split(template, '\n'), snippets_file)
  end
  
  vim.cmd("edit " .. snippets_file)
end, { desc = "Edit custom snippets" })

-- 重新加载 snippets
vim.keymap.set('n', '<leader>sr', function()
  package.loaded["snippets"] = nil
  local ok, err = pcall(require, "snippets")
  if ok then
    print("✓ Snippets reloaded successfully")
  else
    print("✗ Error reloading snippets: " .. err)
  end
end, { desc = "Reload snippets" })

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
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
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
require('dapui').setup({
  controls = {
    element = "repl",
    enabled = true,
  },
  element_mappings = {},
  expand_lines = true,
  floating = {
    border = "single",
    max_height = 0.9,
    max_width = 0.9,
    mappings = {
      close = { "q", "<Esc>" }
    }
  },
  force_buffers = true,
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.25 },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 }
      },
      position = "left",
      size = 40
    },
    {
      elements = {
        { id = "console", size = 0.5 },  -- Console for program I/O (supports input)
        { id = "repl", size = 0.5 }      -- REPL for debug commands
      },
      position = "bottom",
      size = 10  -- Slightly bigger for better input visibility
    }
  },
  render = {
    indent = 1,
    max_value_lines = 100
  }
})

-- ============================
-- 2. 汇编语言编译和运行函数
-- ============================

-- 函数：检测汇编语言类型和选择合适的汇编器
local function detect_asm_type_and_assemble()
  local current_file = vim.fn.expand('%:p')
  local file_stem = vim.fn.expand('%:t:r')
  local file_ext = vim.fn.expand('%:e'):lower()
  local cwd = vim.fn.getcwd()
  
  -- 检查文件内容以确定汇编器类型
  local content = vim.fn.readfile(current_file, '', 10) -- 读取前10行
  local content_str = table.concat(content, '\n'):lower()
  
  local assembler = "nasm"  -- 默认使用 NASM
  local format = "elf64"    -- 默认64位格式
  local linker = "ld"       -- 默认链接器
  
  -- 检测汇编器类型
  if content_str:match("%.intel_syntax") then
    assembler = "gas"
    format = ""
  elseif content_str:match("%%include") or content_str:match("section%s+%.data") then
    assembler = "nasm"
    format = "elf64"
  end
  
  -- 检测架构
  if content_str:match("eax") or content_str:match("ebx") or 
     content_str:match("ecx") or content_str:match("edx") then
    if assembler == "nasm" then
      format = "elf32"
    end
  end
  
  vim.notify("🔍 Detected: " .. assembler .. " assembler", vim.log.levels.INFO)
  
  local obj_file = cwd .. "/" .. file_stem .. ".o"
  local exe_file = cwd .. "/" .. file_stem
  
  local assemble_cmd, link_cmd
  
  if assembler == "nasm" then
    assemble_cmd = string.format("nasm -f %s -g -F dwarf -o %s %s", 
      format, vim.fn.shellescape(obj_file), vim.fn.shellescape(current_file))
  elseif assembler == "gas" then
    if format == "elf32" then
      assemble_cmd = string.format("as --32 -o %s %s", 
        vim.fn.shellescape(obj_file), vim.fn.shellescape(current_file))
      link_cmd = string.format("ld -m elf_i386 -o %s %s", 
        vim.fn.shellescape(exe_file), vim.fn.shellescape(obj_file))
    else
      assemble_cmd = string.format("as --64 -o %s %s", 
        vim.fn.shellescape(obj_file), vim.fn.shellescape(current_file))
      link_cmd = string.format("ld -o %s %s", 
        vim.fn.shellescape(exe_file), vim.fn.shellescape(obj_file))
    end
  end
  
  -- 如果是 NASM，设置链接命令
  if assembler == "nasm" then
    if format == "elf32" then
      link_cmd = string.format("ld -m elf_i386 -o %s %s", 
        vim.fn.shellescape(exe_file), vim.fn.shellescape(obj_file))
    else
      link_cmd = string.format("ld -o %s %s", 
        vim.fn.shellescape(exe_file), vim.fn.shellescape(obj_file))
    end
  end
  
  vim.notify("🔨 Assembling: " .. assemble_cmd, vim.log.levels.INFO)
  
  -- 执行汇编
  local assemble_result = vim.fn.system(assemble_cmd)
  local assemble_exit = vim.v.shell_error
  
  if assemble_exit ~= 0 then
    vim.notify("❌ Assembly failed: " .. assemble_result, vim.log.levels.ERROR)
    return nil
  end
  
  vim.notify("✅ Assembly successful!", vim.log.levels.INFO)
  
  -- 执行链接
  vim.notify("🔗 Linking: " .. link_cmd, vim.log.levels.INFO)
  local link_result = vim.fn.system(link_cmd)
  local link_exit = vim.v.shell_error
  
  if link_exit ~= 0 then
    vim.notify("❌ Linking failed: " .. link_result, vim.log.levels.ERROR)
    return nil
  end
  
  vim.notify("✅ Linking successful! Executable: " .. exe_file, vim.log.levels.INFO)
  return exe_file
end

-- 函数：编译并运行汇编程序
local function compile_and_run_asm()
  if vim.bo.filetype ~= "asm" then
    vim.notify("❌ This function is for assembly files only", vim.log.levels.ERROR)
    return
  end
  
  local exe_file = detect_asm_type_and_assemble()
  if not exe_file then
    return
  end
  
  -- 询问是否运行
  local choice = vim.fn.confirm("Assembly successful! Run the program?", "&Yes\n&No", 1)
  if choice == 1 then
    vim.notify("🚀 Running: " .. exe_file, vim.log.levels.INFO)
    -- 在新的终端窗口中运行
    vim.cmd("belowright split")
    vim.cmd("terminal " .. vim.fn.shellescape(exe_file))
    vim.cmd("startinsert")
  end
end

-- 函数：只编译汇编程序（不运行）
local function compile_asm_only()
  if vim.bo.filetype ~= "asm" then
    vim.notify("❌ This function is for assembly files only", vim.log.levels.ERROR)
    return
  end
  
  detect_asm_type_and_assemble()
end

-- ============================
-- Streamlined debugpy Setup
-- ============================

-- Function to find available Python interpreters (for running code)
local function find_python_interpreters()
  local interpreters = {}
  local cwd = vim.fn.getcwd()
  
  -- Detect currently active environments
  local active_python = vim.fn.exepath("python") or vim.fn.exepath("python3")
  local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
  local conda_env = vim.fn.getenv("CONDA_DEFAULT_ENV")
  local conda_prefix = vim.fn.getenv("CONDA_PREFIX")
  
  -- Handle userdata values (when env vars don't exist)
  if type(virtual_env) ~= "string" then virtual_env = nil end
  if type(conda_env) ~= "string" then conda_env = nil end
  if type(conda_prefix) ~= "string" then conda_prefix = nil end
  
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
      display = "⚡ " .. env_name .. " (ACTIVE)",
      priority = 0,
      type = env_type,
      is_active = true
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
      
      for line in output:gmatch("[^\r\n]+") do
        if not line:match("^#") and line:match("%S") then
          local is_current = line:match("%*") ~= nil
          local env_name, env_path
          
          if is_current then
            env_name, env_path = line:match("^(%S+)%s+%*%s+(.+)$")
          else
            env_name, env_path = line:match("^(%S+)%s+(.+)$")
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
  
  -- 4. System Python (search in system paths only)
  local system_paths = {"/usr/bin/python3", "/usr/bin/python", "/bin/python3", "/bin/python"}
  local system_python = nil
  
  -- Find the first available system Python
  for _, candidate in ipairs(system_paths) do
    if vim.fn.executable(candidate) == 1 then
      system_python = candidate
      break
    end
  end
  
  if system_python then
    local skip = false
    if active_python == system_python and not (virtual_env or conda_env) then
      table.insert(interpreters, {
        path = system_python,
        display = "⚡ System Python (ACTIVE)",
        priority = 0,
        type = "system",
        is_active = true
      })
      skip = true
    end
    
    if not skip then
      table.insert(interpreters, {
        path = system_python,
        display = "🖥️  System Python",
        priority = 5,
        type = "system"
      })
    end
  end
  
  -- Sort by priority
  table.sort(interpreters, function(a, b) return a.priority < b.priority end)
  return interpreters
end

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
    vim.notify("📦 Installing debugpy via pipx...", vim.log.levels.INFO)
    local result = vim.fn.system("pipx install debugpy")
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ debugpy installed via pipx!", vim.log.levels.INFO)
      return pipx_debugpy
    else
      vim.notify("❌ pipx install failed: " .. result, vim.log.levels.ERROR)
    end
  elseif choice == 2 then
    vim.notify("📦 Installing debugpy via system pip...", vim.log.levels.INFO)
    local result = vim.fn.system(system_python .. " -m pip install debugpy --user")
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ debugpy installed via system pip!", vim.log.levels.INFO)
      return system_python
    else
      vim.notify("❌ system pip install failed: " .. result, vim.log.levels.ERROR)
    end
  end
  
  return nil
end

-- Function to safely update Neovim's environment to match interpreter
local function update_nvim_environment(python_path)
  -- Get the directory containing the Python interpreter
  local python_dir = vim.fn.fnamemodify(python_path, ":h")
  local env_root = vim.fn.fnamemodify(python_dir, ":h")  -- Go up one level from bin/
  
  -- Safely update PATH - only remove known Python environment paths
  local current_path = vim.fn.getenv("PATH")
  if type(current_path) == "string" then
    local new_path_parts = {}
    local is_system_python = python_dir:match("^/usr/bin$") or python_dir:match("^/bin$")
    
    -- For non-system Python, add the python_dir first
    if not is_system_python then
      table.insert(new_path_parts, python_dir)
    end
    
    -- Split PATH and filter out old Python environment paths
    for part in current_path:gmatch("[^:]+") do
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
      elseif part == python_dir and not is_system_python then
        -- Don't duplicate the new path (except for system paths)
        skip = true
      end
      
      if not skip then
        table.insert(new_path_parts, part)
      end
    end
    
    -- Set the new PATH
    vim.fn.setenv("PATH", table.concat(new_path_parts, ":"))
  end
  
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
    -- System Python - clear all virtual env variables
    vim.fn.setenv("VIRTUAL_ENV", vim.NIL)
    vim.fn.setenv("CONDA_DEFAULT_ENV", vim.NIL)
    vim.fn.setenv("CONDA_PREFIX", vim.NIL)
  end
end

-- Function to configure DAP with selected Python interpreter
local function configure_dap_python(debugpy_adapter, python_path, update_env)
  local dap = require('dap')
  
  -- Clear existing Python configurations to prevent duplication
  dap.configurations.python = {}
  
  -- Setup dap-python with debugpy adapter
  require("dap-python").setup(debugpy_adapter)
  
  -- Override the Python path for running the actual code
  for _, config in ipairs(dap.configurations.python or {}) do
    if config.type == "python" and config.request == "launch" then
      config.console = "integratedTerminal"
      config.pythonPath = python_path
    end
  end
  
  -- Update Neovim's environment if requested
  if update_env then
    update_nvim_environment(python_path)
  end
end

-- Main function to select and configure Python interpreter for debugging
local function select_python_for_debugging()
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
  
  local interpreters = find_python_interpreters()
  
  if #interpreters == 0 then
    vim.notify("❌ No Python interpreters found", vim.log.levels.ERROR)
    return
  end
  
  pickers.new({}, {
    prompt_title = "🐍 Select Python Interpreter to Run Your Code",
    finder = finders.new_table {
      results = interpreters,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
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
          
          vim.notify("✅ Debugging configured and environment switched!", vim.log.levels.INFO)
          vim.notify("🔧 Debugpy adapter: " .. debugpy_adapter, vim.log.levels.INFO)
          vim.notify("🐍 Code runner: " .. selection.value.display, vim.log.levels.INFO)
          vim.notify("🔄 Neovim environment updated to match interpreter", vim.log.levels.INFO)
        end
      end)
      return true
    end,
  }):find()
end

-- Auto setup that uses active environment or best available
local function auto_debug_setup()
  -- First, ensure we have a debugpy adapter
  local debugpy_adapter = get_debugpy_adapter()
  if not debugpy_adapter then
    vim.notify("❌ Cannot setup debugging without debugpy adapter", vim.log.levels.ERROR)
    return false
  end
  
  local interpreters = find_python_interpreters()
  
  if #interpreters == 0 then
    vim.notify("❌ No Python interpreters found", vim.log.levels.ERROR)
    return false
  end
  
  -- Find the highest priority interpreter (active environment or project venv if available)
  local best_interpreter = interpreters[1]  -- Already sorted by priority
  local python_path = best_interpreter.path
  
  -- Configure DAP with selected interpreter and update environment
  configure_dap_python(debugpy_adapter, python_path, true)
  
  vim.notify("🐍 Using: " .. best_interpreter.display, vim.log.levels.INFO)
  return true
end

-- Quick setup that prefers project environments (for manual use)
local function quick_debug_setup()
  if auto_debug_setup() then
    vim.notify("✅ Quick setup complete!", vim.log.levels.INFO)
  end
end

-- Function to show current Python environment info
local function show_python_env()
  -- Force refresh of PATH-based lookups
  local current_path = vim.fn.getenv("PATH")
  local python_path = nil
  local python3_path = nil
  
  -- Manual search through PATH to avoid caching issues
  if type(current_path) == "string" then
    for path_dir in current_path:gmatch("[^:]+") do
      if not python_path then
        local candidate = path_dir .. "/python"
        if vim.fn.executable(candidate) == 1 then
          python_path = candidate
        end
      end
      if not python3_path then
        local candidate = path_dir .. "/python3"
        if vim.fn.executable(candidate) == 1 then
          python3_path = candidate
        end
      end
      if python_path and python3_path then break end
    end
  end
  
  -- Fallback to exepath if manual search didn't work
  python_path = python_path or vim.fn.exepath("python")
  python3_path = python3_path or vim.fn.exepath("python3")
  
  local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
  local conda_env = vim.fn.getenv("CONDA_DEFAULT_ENV")
  local conda_prefix = vim.fn.getenv("CONDA_PREFIX")
  
  -- Handle userdata values
  if type(virtual_env) ~= "string" then virtual_env = nil end
  if type(conda_env) ~= "string" then conda_env = nil end
  if type(conda_prefix) ~= "string" then conda_prefix = nil end
  
  print("=== Current Python Environment ===")
  print("Python executable: " .. (python_path or "Not found"))
  print("Python3 executable: " .. (python3_path or "Not found"))
  print("VIRTUAL_ENV: " .. (virtual_env or "None"))
  print("CONDA_DEFAULT_ENV: " .. (conda_env or "None"))
  print("CONDA_PREFIX: " .. (conda_prefix or "None"))
  print("Real path (python): " .. (python_path and vim.fn.resolve(python_path) or "N/A"))
  print("Real path (python3): " .. (python3_path and vim.fn.resolve(python3_path) or "N/A"))
  print("PATH (first 8 entries):")
  if type(current_path) == "string" then
    local count = 0
    for part in current_path:gmatch("[^:]+") do
      if count < 8 then
        -- Mark Python-related paths
        local marker = ""
        if part:match("/%.venv/bin$") then marker = " [VENV]"
        elseif part:match("/miniconda3/envs/[^/]+/bin$") or part:match("/anaconda3/envs/[^/]+/bin$") then marker = " [CONDA]"
        elseif part == "/usr/bin" or part == "/bin" then marker = " [SYSTEM]"
        end
        print("  " .. part .. marker)
        count = count + 1
      end
    end
    if current_path:match(":"):len() > 0 then
      local total_parts = 0
      for _ in current_path:gmatch("[^:]+") do total_parts = total_parts + 1 end
      if total_parts > 8 then
        print("  ... and " .. (total_parts - 8) .. " more entries")
      end
    end
  end
  
  -- Show which Python would be used for different commands
  print("Command resolution:")
  print("  'python' would use: " .. (python_path or "Not found"))
  print("  'python3' would use: " .. (python3_path or "Not found"))
end

-- Debug function to test system Python path update
local function debug_system_python_switch()
  -- Find system Python the same way as the interpreter finder
  local system_paths = {"/usr/bin/python3", "/usr/bin/python", "/bin/python3", "/bin/python"}
  local system_python = nil
  
  for _, candidate in ipairs(system_paths) do
    if vim.fn.executable(candidate) == 1 then
      system_python = candidate
      break
    end
  end
  
  if not system_python then
    print("❌ No system Python found in /usr/bin or /bin")
    return
  end
  
  print("=== Debug System Python Switch ===")
  print("Found system Python at: " .. system_python)
  
  -- Get debugpy adapter
  local debugpy_adapter = get_debugpy_adapter()
  if not debugpy_adapter then
    print("❌ No debugpy adapter available")
    return
  end
  
  print("Using debugpy adapter: " .. debugpy_adapter)
  print("Current PATH before switch:")
  local current_path = vim.fn.getenv("PATH")
  if type(current_path) == "string" then
    local count = 0
    for part in current_path:gmatch("[^:]+") do
      if count < 3 then
        print("  " .. part)
        count = count + 1
      end
    end
  end
  
  -- Perform the switch
  configure_dap_python(debugpy_adapter, system_python, true)
  
  print("PATH after switch:")
  local new_path = vim.fn.getenv("PATH")
  if type(new_path) == "string" then
    local count = 0
    for part in new_path:gmatch("[^:]+") do
      if count < 3 then
        print("  " .. part)
        count = count + 1
      end
    end
  end
  
  print("Environment variables after switch:")
  local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
  local conda_env = vim.fn.getenv("CONDA_DEFAULT_ENV")
  if type(virtual_env) ~= "string" then virtual_env = nil end
  if type(conda_env) ~= "string" then conda_env = nil end
  print("  VIRTUAL_ENV: " .. (virtual_env or "None"))
  print("  CONDA_DEFAULT_ENV: " .. (conda_env or "None"))
  
  -- Test python resolution
  local resolved_python = vim.fn.exepath("python")
  local resolved_python3 = vim.fn.exepath("python3")
  print("Resolved python: " .. (resolved_python or "Not found"))
  print("Resolved python3: " .. (resolved_python3 or "Not found"))
end

-- ============================
-- 汇编语言调试配置（扩展现有 GDB 配置）
-- ============================

-- 函数：查找或编译汇编可执行文件用于调试
local function find_or_compile_asm_executable()
  local cwd = vim.fn.getcwd()
  local current_file = vim.fn.expand('%:p')
  local file_stem = vim.fn.expand('%:t:r')

  -- 检查是否存在可执行文件
  local possible_executables = {
    cwd .. "/" .. file_stem,
    cwd .. "/" .. file_stem .. ".out",
    cwd .. "/a.out"
  }
  
  vim.notify("🔍 Looking for executable for " .. vim.fn.expand('%:t'), vim.log.levels.INFO)
  
  -- 检查现有可执行文件
  for _, candidate in ipairs(possible_executables) do
    if vim.fn.executable(candidate) == 1 then
      local exe_time = vim.fn.getftime(candidate)
      local src_time = vim.fn.getftime(current_file)
      
      if exe_time >= src_time then
        vim.notify("✅ Using existing executable: " .. candidate, vim.log.levels.INFO)
        return candidate
      else
        vim.notify("⚠️  Executable is older than source file: " .. candidate, vim.log.levels.WARN)
      end
    end
  end
  
  -- 需要重新编译
  vim.notify("🔨 Compiling assembly file for debugging...", vim.log.levels.INFO)
  local exe_file = detect_asm_type_and_assemble()
  
  if exe_file and vim.fn.executable(exe_file) == 1 then
    return exe_file
  else
    vim.notify("❌ Failed to create executable for debugging", vim.log.levels.ERROR)
    return nil
  end
end

-- 函数：配置汇编语言调试
local function configure_dap_asm()
  local dap = require('dap')
  
  -- 确保 GDB 可用
  if vim.fn.executable("gdb") ~= 1 then
    vim.notify("❌ GDB not found. Please install GDB for assembly debugging.", vim.log.levels.ERROR)
    return false
  end
  
  -- 配置 GDB 适配器
  dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" },
  }
  
  -- 添加汇编语言调试配置
  dap.configurations.asm = {
    {
      name = "Debug Assembly (Auto-compile)",
      type = "gdb",
      request = "launch",
      program = find_or_compile_asm_executable,
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
      args = function()
        local args_str = vim.fn.input('Program arguments (press Enter if none needed): ')
        return args_str == "" and {} or vim.split(args_str, " ", { plain = true })
      end,
      console = "integratedTerminal",
      setupCommands = {
        {
          text = '-enable-pretty-printing',
          description = 'enable pretty printing',
          ignoreFailures = false
        },
        {
          text = '-gdb-set disassembly-flavor intel',
          description = 'set Intel disassembly syntax',
          ignoreFailures = true
        },
        {
          text = '-gdb-set print elements 200',
          description = 'limit array printing',
          ignoreFailures = true
        },
      },
    },
    {
      name = "Debug Assembly (Manual path)",
      type = "gdb",
      request = "launch",
      program = function()
        local cwd = vim.fn.getcwd()
        local current_file = vim.fn.expand('%:t:r')
        local default_path = cwd .. "/" .. current_file
        
        if vim.fn.executable(default_path) ~= 1 then
          default_path = cwd .. "/a.out"
        end
        
        return vim.fn.input('Path to executable: ', default_path, 'file')
      end,
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
      args = function()
        local args_str = vim.fn.input('Program arguments: ')
        return args_str == "" and {} or vim.split(args_str, " ", { plain = true })
      end,
      console = "integratedTerminal",
      setupCommands = {
        {
          text = '-enable-pretty-printing',
          description = 'enable pretty printing',
          ignoreFailures = false
        },
        {
          text = '-gdb-set disassembly-flavor intel',
          description = 'set Intel disassembly syntax',
          ignoreFailures = true
        },
      },
    }
  }
  
  vim.notify("✅ Assembly debugging configured with GDB", vim.log.levels.INFO)
  return true
end

-- ============================
-- C/C++ GDB Configuration
-- ============================

-- Function to check if executable has debug information
local function has_debug_info(executable_path)
  if vim.fn.executable("file") == 1 and vim.fn.executable("grep") == 1 then
    local result = vim.fn.system("file " .. vim.fn.shellescape(executable_path) .. " | grep -q 'not stripped'")
    return vim.v.shell_error == 0
  end
  -- If we can't check, assume it's okay
  return true
end

-- 添加 CMake 检测函数
local function is_cmake_project()
  return vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 1
end

local function find_cmake_build_dir()
  local cwd = vim.fn.getcwd()
  local possible_dirs = {
    cwd .. "/build",
    cwd .. "/cmake-build-debug", 
    cwd .. "/cmake-build-release",
    cwd .. "/out/build"
  }
  for _, dir in ipairs(possible_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      return dir
    end
  end
  return nil
end

local function find_cmake_executables(build_dir)
  if not build_dir then return {} end
  local executables = {}
  local handle = io.popen("find " .. vim.fn.shellescape(build_dir) .. " -type f -executable -not -path '*/CMakeFiles/*' 2>/dev/null")
  if handle then
    for line in handle:lines() do
      if not line:match("%.so$") and not line:match("%.a$") and 
         not line:match("/cmake$") and not line:match("/cpack$") and not line:match("/ctest$") then
        table.insert(executables, line)
      end
    end
    handle:close()
  end
  return executables
end

-- Function to find or compile C/C++ executable
local function find_or_compile_cpp_executable()
  local cwd = vim.fn.getcwd()
  local current_file = vim.fn.expand('%:p')
  local file_stem = vim.fn.expand('%:t:r')  -- filename without extension

  -- 新增: CMake 项目检测
  if is_cmake_project() then
    vim.notify("🏗️  CMake project detected", vim.log.levels.INFO)
    
    local build_dir = find_cmake_build_dir()
    if not build_dir then
      local choice = vim.fn.confirm("No build dir found. Create?", "&Debug\n&Release\n&Cancel", 1)
      if choice == 1 or choice == 2 then
        build_dir = cwd .. "/build"
        vim.fn.mkdir(build_dir, "p")
        local build_type = choice == 1 and "Debug" or "Release"
        local result = vim.fn.system("cd " .. vim.fn.shellescape(build_dir) .. " && cmake -DCMAKE_BUILD_TYPE=" .. build_type .. " ..")
        if vim.v.shell_error ~= 0 then
          vim.notify("❌ CMake config failed: " .. result, vim.log.levels.ERROR)
          return nil
        end
      else
        return nil
      end
    end
    
    -- 构建
    vim.notify("🔨 Building CMake project...", vim.log.levels.INFO)
    local build_result = vim.fn.system("cd " .. vim.fn.shellescape(build_dir) .. " && make -j$(nproc)")
    if vim.v.shell_error ~= 0 then
      vim.notify("❌ Build failed: " .. build_result, vim.log.levels.ERROR)
      return nil
    end
    
    -- 查找可执行文件
    local executables = find_cmake_executables(build_dir)
    if #executables == 1 then
      vim.notify("✅ Found: " .. executables[1], vim.log.levels.INFO)
      return executables[1]
    elseif #executables > 1 then
      -- 让用户选择
      local items = {"Select executable:"}
      for i, exe in ipairs(executables) do
        table.insert(items, i .. ". " .. vim.fn.fnamemodify(exe, ":t"))
      end
      local choice = vim.fn.inputlist(items)
      return executables[choice] or nil
    else
      vim.notify("❌ No executables found", vim.log.levels.ERROR)
      return nil
    end
  else 
    -- More comprehensive executable name checking
    local possible_executables = {
      cwd .. "/" .. file_stem,          -- Same name as source file (hello.cpp -> hello)
      cwd .. "/a.out",                  -- Default gcc output
      cwd .. "/main",                   -- Common name
      cwd .. "/program",                -- Generic name
      cwd .. "/" .. file_stem .. ".out", -- filename.out
      cwd .. "/" .. file_stem .. ".exe"  -- filename.exe (some people use this)
    }
    
    vim.notify("🔍 Looking for executable for " .. vim.fn.expand('%:t'), vim.log.levels.INFO)
    
    -- First, check if any executable already exists and is suitable
    for _, candidate in ipairs(possible_executables) do
      if vim.fn.executable(candidate) == 1 then
        vim.notify("📁 Found executable: " .. candidate, vim.log.levels.INFO)
        
        -- Check if executable is newer than source file
        local exe_time = vim.fn.getftime(candidate)
        local src_time = vim.fn.getftime(current_file)
        
        if exe_time >= src_time then
          -- Check if it has debug information
          if has_debug_info(candidate) then
            vim.notify("✅ Using existing executable with debug info: " .. candidate, vim.log.levels.INFO)
            return candidate
          else
            vim.notify("⚠️  Executable exists but lacks debug info: " .. candidate, vim.log.levels.WARN)
            -- Continue to offer recompilation
          end
        else
          vim.notify("⚠️  Executable is older than source file: " .. candidate, vim.log.levels.WARN)
        end
      end
    end
    
    -- No suitable executable found, offer to compile
    local source_file = vim.fn.expand('%:t')
    local choice = vim.fn.confirm(
      "No suitable executable found for " .. source_file .. ".\nOptions:",
      "&g++\ng&cc\n&Quit",
      1
    )
    
    if choice == 1 then -- g++
      local output_name = cwd .. "/" .. file_stem
      local compile_cmd = string.format("g++ -g -Wall -o %s %s", vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
      vim.notify("🔨 Compiling with debug info: " .. compile_cmd, vim.log.levels.INFO)
      
      local result = vim.fn.system(compile_cmd)
      local exit_code = vim.v.shell_error
      
      if exit_code == 0 then
        vim.notify("✅ Compilation successful with debug information!", vim.log.levels.INFO)
        return output_name
      else
        vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
        return nil
      end
    elseif choice == 2 then -- gcc
      local output_name = cwd .. "/" .. file_stem
      local compile_cmd = string.format("gcc -g -Wall -o %s %s", vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
      vim.notify("🔨 Compiling with debug info: " .. compile_cmd, vim.log.levels.INFO)
      
      local result = vim.fn.system(compile_cmd)
      local exit_code = vim.v.shell_error
      
      if exit_code == 0 then
        vim.notify("✅ Compilation successful with debug information!", vim.log.levels.INFO)
        return output_name
      else
        vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
        return nil
      end
    elseif choice == 3 then -- Quit
      vim.notify("❌ Compilation cancelled.", vim.log.levels.INFO)
      return nil
    end
  end -- 关闭 else 块
end -- 关闭函数

-- Function to configure GDB for C/C++ debugging
local function configure_dap_cpp()
  local dap = require('dap')
  
  -- Clear existing C/C++ configurations to prevent duplication
  dap.configurations.c = {}
  dap.configurations.cpp = {}
  
  -- GDB adapter configuration with better error handling
  dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" },
  }
  
  -- C/C++ debug configurations
  local cpp_config = {
    {
      name = "Launch (Auto-detect/Compile)",
      type = "gdb",
      request = "launch",
      program = find_or_compile_cpp_executable,
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
      args = function()
        local args_str = vim.fn.input('Program arguments (press Enter if none needed): ')
        if args_str == "" then
          return {}
        end
        return vim.split(args_str, " ", { plain = true })
      end,
      console = "integratedTerminal",  -- Use integrated terminal
      externalConsole = false,         -- Don't use external console by default
      -- Better process control
      miDebuggerPath = "/usr/bin/gdb",
      stopAtEntry = false,
      runInTerminal = false,
      -- Ensure proper source file mapping and debugging setup
      setupCommands = {
        {
          text = '-enable-pretty-printing',
          description = 'enable pretty printing',
          ignoreFailures = false
        },
        {
          text = '-gdb-set print elements 200',
          description = 'limit array printing',
          ignoreFailures = true
        },
        {
          text = '-gdb-set confirm off',
          description = 'disable confirmation prompts',
          ignoreFailures = true
        },
        {
          text = '-gdb-set pagination off',
          description = 'disable pagination',
          ignoreFailures = true
        },
        {
          text = '-gdb-set breakpoint pending on',
          description = 'allow pending breakpoints',
          ignoreFailures = true
        },
      },
    },
    {
      name = "Launch CMake (Force rebuild)",
      type = "gdb",
      request = "launch",
      program = function()
        if not is_cmake_project() then
          vim.notify("❌ Not a CMake project", vim.log.levels.ERROR)
          return nil
        end
        local build_dir = find_cmake_build_dir() or (vim.fn.getcwd() .. "/build")
        vim.notify("🔨 Force rebuilding...", vim.log.levels.INFO)
        vim.fn.system("cd " .. vim.fn.shellescape(build_dir) .. " && make clean && make -j$(nproc)")
        if vim.v.shell_error ~= 0 then
          vim.notify("❌ Rebuild failed", vim.log.levels.ERROR)
          return nil
        end
        local executables = find_cmake_executables(build_dir)
        return executables[1] or nil
      end,
      cwd = '${workspaceFolder}',
      args = function()
        local args_str = vim.fn.input('Program arguments: ')
        return args_str == "" and {} or vim.split(args_str, " ", { plain = true })
      end,
      console = "integratedTerminal",
    },
    {
      name = "Launch (Manual path)",
      type = "gdb",
      request = "launch",
      program = function()
        local cwd = vim.fn.getcwd()
        local current_file = vim.fn.expand('%:t:r')
        local default_path = cwd .. "/" .. current_file
        
        -- Check if default exists
        if vim.fn.executable(default_path) ~= 1 then
          default_path = cwd .. "/a.out"
        end
        
        return vim.fn.input('Path to executable: ', default_path, 'file')
      end,
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
      args = function()
        local args_str = vim.fn.input('Program arguments (press Enter if none needed): ')
        if args_str == "" then
          return {}
        end
        return vim.split(args_str, " ", { plain = true })
      end,
      console = "integratedTerminal",  -- Route output to terminal
      -- Ensure proper source file mapping
      setupCommands = {
        {
          text = '-enable-pretty-printing',
          description = 'enable pretty printing',
          ignoreFailures = false
        },
        {
          text = '-gdb-set print elements 0',
          description = "don't limit printing of large arrays",
          ignoreFailures = true
        },
        {
          text = '-gdb-set inferior-tty /dev/stdin',
          description = 'redirect input/output to console',
          ignoreFailures = true
        },
      },
    },
    {
      name = "Select and attach to process",
      type = "gdb",
      request = "attach",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/a.out', 'file')
      end,
      pid = function()
         local name = vim.fn.input('Executable name (for pgrep): ')
         return require("dap.utils").pick_process({filter = name})
      end,
      cwd = '${workspaceFolder}'
    },
    {
      name = 'Attach to gdbserver :1234',
      type = 'gdb',
      request = 'attach',
      target = 'localhost:1234',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/a.out', 'file')
      end,
      cwd = '${workspaceFolder}'
    }
  }
  
  dap.configurations.c = cpp_config
  dap.configurations.cpp = cpp_config
  
  vim.notify("✅ GDB debugging configured for C/C++", vim.log.levels.INFO)
  vim.notify("💡 Launch options:", vim.log.levels.INFO)
  vim.notify("  • 'Launch (Auto-detect/Compile)' - integrated terminal", vim.log.levels.INFO)
  vim.notify("  • 'Launch (External Terminal)' - for std::cin/getline input", vim.log.levels.INFO)
  return true
end

-- Function to check if GDB is available and offer installation
local function ensure_gdb_available()
  if vim.fn.executable("gdb") == 1 then
    return true
  end
  
  local choice = vim.fn.confirm(
    "GDB not found. Install it?",
    "&Yes (apt)\n&Cancel",
    1
  )
  
  if choice == 1 then
    vim.notify("📦 Installing GDB...", vim.log.levels.INFO)
    local result = vim.fn.system("sudo apt update && sudo apt install -y gdb")
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ GDB installed successfully!", vim.log.levels.INFO)
      return true
    else
      vim.notify("❌ GDB installation failed: " .. result, vim.log.levels.ERROR)
    end
  end
  
  return false
end

-- ============================
-- JavaScript/TypeScript DAP Configuration  
-- ============================

-- Function to configure DAP for JavaScript/TypeScript
local function configure_dap_js()
  local dap = require('dap')
  
  -- Clear existing JS/TS configurations
  dap.configurations.javascript = {}
  dap.configurations.typescript = {}
  dap.configurations.javascriptreact = {}
  dap.configurations.typescriptreact = {}
  
  -- Ensure vscode-js-debug is available
  local js_debug_path = vim.fn.stdpath('data') .. '/lazy/vscode-js-debug'
  if vim.fn.isdirectory(js_debug_path) == 0 then
    vim.notify("❌ vscode-js-debug not found. Install nvim-dap-vscode-js properly.", vim.log.levels.ERROR)
    return false
  end
  
  -- Node.js configurations
  local js_config = {
    {
      name = "Launch Node.js",
      type = "pwa-node",
      request = "launch",
      program = function()
        local cwd = vim.fn.getcwd()
        local default_file = "${file}"
        
        -- Check for package.json main script
        local package_json = cwd .. "/package.json"
        if vim.fn.filereadable(package_json) == 1 then
          local content = vim.fn.readfile(package_json)
          local json_str = table.concat(content, '\n')
          local main_match = json_str:match('"main"%s*:%s*"([^"]+)"')
          if main_match then
            default_file = cwd .. "/" .. main_match
          end
        end
        
        return vim.fn.input('Path to script: ', default_file, 'file')
      end,
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    },
    {
      name = "Launch Node.js (current file)",
      type = "pwa-node", 
      request = "launch",
      program = "${file}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    },
    {
      name = "Attach to Node.js",
      type = "pwa-node",
      request = "attach",
      processId = require('dap.utils').pick_process,
      cwd = "${workspaceFolder}",
    },
    {
      name = "Launch Chrome",
      type = "pwa-chrome",
      request = "launch",
      url = function()
        local co = coroutine.running()
        return coroutine.create(function()
          local url = vim.fn.input('URL: ', 'http://localhost:3000')
          coroutine.resume(co, url)
        end)
      end,
      webRoot = "${workspaceFolder}",
      userDataDir = "${workspaceFolder}/.vscode/chrome-debug-userdatadir"
    }
  }
  
  dap.configurations.javascript = js_config
  dap.configurations.typescript = js_config
  dap.configurations.javascriptreact = js_config  
  dap.configurations.typescriptreact = js_config
  
  vim.notify("✅ JavaScript/TypeScript debugging configured", vim.log.levels.INFO)
  return true
end

-- ============================
-- Unified DAP Configuration System
-- ============================

-- Function to auto-configure DAP based on current file type
local function configure_dap_by_filetype(filetype)
  filetype = filetype or vim.bo.filetype
  
  if filetype == "python" then
    return auto_debug_setup()
  elseif filetype == "c" or filetype == "cpp" then
    if ensure_gdb_available() then
      return configure_dap_cpp()
    end
    return false
  elseif filetype == "asm" then
    return configure_dap_asm()      -- 新的汇编语言配置
  elseif filetype == "javascript" or filetype == "typescript" or 
         filetype == "javascriptreact" or filetype == "typescriptreact" then
    return configure_dap_js()
  else
    vim.notify("❌ No DAP configuration available for filetype: " .. filetype, vim.log.levels.WARN)
    return false
  end
end

-- Smart debugging function that auto-configures based on file type
local function smart_debug_start()
  local filetype = vim.bo.filetype
  local dap = require('dap')
  
  -- Check if debugging is already configured for this filetype
  local configs = dap.configurations[filetype]
  if not configs or #configs == 0 then
    vim.notify("🔧 Auto-configuring debugging for " .. filetype .. "...", vim.log.levels.INFO)
    if not configure_dap_by_filetype(filetype) then
      return
    end
  end
  
  -- Start debugging
  dap.continue()
end

-- Quick launch function for interactive C/C++ programs (external terminal)
local function debug_cpp_interactive()
  if vim.bo.filetype ~= "c" and vim.bo.filetype ~= "cpp" then
    vim.notify("❌ This function is for C/C++ files only", vim.log.levels.ERROR)
    return
  end
  
  -- Configure DAP for C/C++
  if not configure_dap_by_filetype(vim.bo.filetype) then
    return
  end
  
  local dap = require('dap')
  -- Start debugging with external terminal configuration (2nd config)
  dap.run(dap.configurations.cpp[2])
end

-- Function to force recompile C/C++ with debug info
local function force_recompile_cpp()
  local cwd = vim.fn.getcwd()
  local current_file = vim.fn.expand('%:p')
  local file_stem = vim.fn.expand('%:t:r')
  
  if vim.bo.filetype ~= "cpp" and vim.bo.filetype ~= "c" then
    vim.notify("❌ Not a C/C++ file", vim.log.levels.ERROR)
    return
  end
  
  local choice = vim.fn.confirm(
    "Force recompile " .. vim.fn.expand('%:t') .. " with debug info?",
    "&g++\ng&cc\n&Quit",
    1
  )
  
  if choice == 1 then -- g++
    local output_name = cwd .. "/" .. file_stem
    local compile_cmd = string.format("g++ -g -Wall -o %s %s", vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
    vim.notify("🔨 Force compiling: " .. compile_cmd, vim.log.levels.INFO)
    
    local result = vim.fn.system(compile_cmd)
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ Force compilation successful! Ready for debugging.", vim.log.levels.INFO)
      -- Automatically configure debugging after successful compilation
      configure_dap_cpp()
    else
      vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
    end
  elseif choice == 2 then -- gcc
    local output_name = cwd .. "/" .. file_stem
    local compile_cmd = string.format("gcc -g -Wall -o %s %s", vim.fn.shellescape(output_name), vim.fn.shellescape(current_file))
    vim.notify("🔨 Force compiling: " .. compile_cmd, vim.log.levels.INFO)
    
    local result = vim.fn.system(compile_cmd)
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      vim.notify("✅ Force compilation successful! Ready for debugging.", vim.log.levels.INFO)
      -- Automatically configure debugging after successful compilation
      configure_dap_cpp()
    else
      vim.notify("❌ Compilation failed: " .. result, vim.log.levels.ERROR)
    end
  elseif choice == 3 then -- Quit
    vim.notify("❌ Compilation cancelled.", vim.log.levels.INFO)
    return
  end
end

-- User commands for DAP setup
vim.api.nvim_create_user_command('DapSetupPython', select_python_for_debugging, { desc = 'Select Python interpreter for debugging' })
vim.api.nvim_create_user_command('DapQuickSetup', quick_debug_setup, { desc = 'Quick debug setup with best available interpreter' })
vim.api.nvim_create_user_command('DapSetupCpp', configure_dap_cpp, { desc = 'Configure GDB for C/C++ debugging' })
vim.api.nvim_create_user_command('DapSetupJs', configure_dap_js, { desc = 'Configure debugging for JavaScript/TypeScript' })
vim.api.nvim_create_user_command('DapSetupAuto', function() configure_dap_by_filetype() end, { desc = 'Auto-configure DAP for current filetype' })
vim.api.nvim_create_user_command('DapForceRecompile', force_recompile_cpp, { desc = 'Force recompile C/C++ with debug info' })
vim.api.nvim_create_user_command('DapInteractive', debug_cpp_interactive, { desc = 'Debug C/C++ with external terminal for input' })
vim.api.nvim_create_user_command('PythonEnv', show_python_env, { desc = 'Show current Python environment info' })

-- Enhanced keybindings for DAP setup
vim.keymap.set('n', '<leader>dp', select_python_for_debugging, { desc = 'Select Python interpreter for debugging' })
vim.keymap.set('n', '<leader>dq', quick_debug_setup, { desc = 'Quick debug setup' })
vim.keymap.set('n', '<leader>dc', configure_dap_cpp, { desc = 'Configure C/C++ debugging (GDB)' })
vim.keymap.set('n', '<leader>dj', configure_dap_js, { desc = 'Configure JavaScript/TypeScript debugging' })
vim.keymap.set('n', '<leader>da', function() configure_dap_by_filetype() end, { desc = 'Auto-configure DAP for current filetype' })
vim.keymap.set('n', '<leader>di', show_python_env, { desc = 'Show Python environment info' })
vim.keymap.set('n', '<leader>df', force_recompile_cpp, { desc = 'Force recompile C/C++ with debug info' })

local dap = require('dap')
local dapui = require('dapui')

-- Debugging keymaps with unified smart debugging
vim.keymap.set('n', '<F5>', smart_debug_start, { desc = "Smart Debug: Auto-configure and Start/Continue" })
vim.keymap.set('n', '<Leader>dt', debug_cpp_interactive, { desc = "Debug C/C++ (Interactive/External Terminal)" })
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
vim.keymap.set('n', '<leader>dn', function()
  require('dap').terminate()
end, { desc = "Terminate DAP" })
vim.keymap.set('n', '<Leader>dx', function() 
  local dap = require('dap')
  dap.terminate()
  vim.schedule(function()
    dap.close()
  end)
end, { desc = "Force Terminate and Close Debug Session" })
vim.keymap.set({'n', 'v'}, '<Leader>de', function() require('dapui').eval() end, { desc = "Evaluate expression" })
vim.keymap.set('n', '<Leader>dE', function()
  local expr = vim.fn.input('Expression: ')
  require('dapui').eval(expr)
end, { desc = "Evaluate custom expression" })
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

-- LSP capability separation to avoid Pyright/Ruff conflicts
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp_attach_capabilities', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then return end
    
    -- Separate Pyright and Ruff capabilities to prevent conflicts
    if client.name == 'ruff' then
      -- Ruff: formatting, linting, code actions, import organization
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.definitionProvider = false
      client.server_capabilities.referencesProvider = false
      client.server_capabilities.documentFormattingProvider = true
      client.server_capabilities.codeActionProvider = true
    elseif client.name == 'pyright' then
      -- Pyright: type checking, hover, navigation
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
      client.server_capabilities.codeActionProvider = false
    end
  end,
  desc = 'Separate Pyright and Ruff capabilities to avoid conflicts',
})

-- LSP utility commands
vim.api.nvim_create_user_command('LspRestart', function()
  vim.cmd('LspRestart')
end, { desc = 'Restart LSP servers' })

-- Python-specific keybindings for formatting and code actions
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    
    -- Format with Ruff
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format({ 
        async = true,
        filter = function(client)
          return client.name == "ruff"
        end
      })
    end, { buffer = bufnr, desc = 'Format with Ruff' })
    
    -- Code actions
    vim.keymap.set('n', '<leader>ca', function()
      vim.lsp.buf.code_action()
    end, { buffer = bufnr, desc = 'Code actions' })
    
    vim.keymap.set('v', '<leader>ca', function()
      vim.lsp.buf.range_code_action()
    end, { buffer = bufnr, desc = 'Range code actions' })
    
    -- Organize imports
    vim.keymap.set('n', '<leader>oi', function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" } },
        apply = true,
      })
    end, { buffer = bufnr, desc = 'Organize imports' })
  end,
})

-- 汇编语言相关命令
vim.api.nvim_create_user_command('AsmCompile', compile_asm_only, { desc = 'Compile assembly file' })
vim.api.nvim_create_user_command('AsmRun', compile_and_run_asm, { desc = 'Compile and run assembly file' })
vim.api.nvim_create_user_command('DapSetupAsm', configure_dap_asm, { desc = 'Configure GDB for assembly debugging' })

-- 汇编语言完整配置（快捷键 + 编辑器设置）
vim.api.nvim_create_autocmd("FileType", {
  pattern = "asm",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    
    -- ===============================
    -- 编辑器设置
    -- ===============================
    vim.bo.shiftwidth = 8
    vim.bo.tabstop = 8
    vim.bo.expandtab = false  -- 汇编通常使用 tab 而不是空格
    vim.bo.commentstring = "; %s"  -- 汇编注释格式
    
    -- ===============================
    -- 快捷键设置
    -- ===============================
    
    -- 编译快捷键
    vim.keymap.set('n', '<F9>', compile_asm_only, 
      { buffer = bufnr, desc = 'Compile assembly file' })
    
    -- 编译并运行快捷键
    vim.keymap.set('n', '<leader>ar', compile_and_run_asm, 
      { buffer = bufnr, desc = 'Compile and run assembly' })
    
    -- 配置调试快捷键
    vim.keymap.set('n', '<leader>da', configure_dap_asm, 
      { buffer = bufnr, desc = 'Configure assembly debugging' })
    
    -- ===============================
    -- 提示信息
    -- ===============================
    vim.notify("🔧 Assembly setup complete!", vim.log.levels.INFO)
    vim.notify("📋 Keybindings: F9 (compile), <leader>ar (run), <leader>da (debug)", vim.log.levels.INFO)
    vim.notify("⚙️  Editor: 8-space tabs, '; comment' format", vim.log.levels.INFO)
  end,
})

-- ===============================
-- 可选：支持更多汇编文件扩展名
-- ===============================

-- 如果你还想支持其他汇编文件扩展名，可以添加：
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.nasm", "*.inc", "*.s"},
  callback = function()
    vim.bo.filetype = "asm"
  end,
  desc = "Set filetype to asm for additional assembly file extensions"
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
  \ NvimTreeToggle | wincmd p | ene | exe 'cd' argv()[0] | endif

" Close nvim-tree if it's the last window
autocmd BufEnter * if winnr('$') == 1 && exists('b:NvimTree') && b:NvimTree.isTabTree() | quit | endif

" ============================
" Plugin-specific Settings
" ============================

" EasyMotion settings
let g:EasyMotion_do_mapping = 0 " Disable default mappings
" Use regular motions instead of overwin to avoid regex errors
nmap <Leader>s <Plug>(easymotion-f2)
" Jump to start of word (forward/backward)
nmap <Leader>ss <Plug>(easymotion-bd-w)

" Jump to start of line
nmap <Leader>g <Plug>(easymotion-bd-jk)
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
