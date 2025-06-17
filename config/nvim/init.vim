set clipboard=unnamedplus
" Leader key
let mapleader = " "

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

nnoremap <leader>c :call ToggleComment()<CR>

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

" Navigation & Movement
Plug 'easymotion/vim-easymotion'
Plug 'justinmk/vim-sneak'

" Text Editing
Plug 'kylechui/nvim-surround'
Plug 'windwp/nvim-autopairs'

" File Management & Search
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'

" LSP & Completion
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" Snippets (using vsnip)
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" git diff
Plug 'sindrets/diffview.nvim'

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
  ensure_installed = { "markdown", "markdown_inline", "lua", "vim", "bash","python" }, -- 按需添加语言
  highlight = {
    enable = true, -- 启用语法高亮
    additional_vim_regex_highlighting = false, -- 禁用冗余的 Vim 正则高亮
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

-- Add these functions to adjust nvimtree width
local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- Custom width adjustment mappings
  vim.keymap.set('n', '<C-]>', function()
    vim.cmd('NvimTreeResize +5')
  end, opts('Increase width'))

  vim.keymap.set('n', '<C-[>', function()
    vim.cmd('NvimTreeResize -5')
  end, opts('Decrease width'))
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

-- nvim-cmp setup
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For vsnip users
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
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
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

-- LSP capabilities for nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Example LSP server setups (uncomment and modify as needed)
require('lspconfig')['pyright'].setup {
  capabilities = capabilities
}

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

-- require('lspconfig')['tsserver'].setup {
--   capabilities = capabilities
-- }
-- require('lspconfig')['lua_ls'].setup {
--   capabilities = capabilities
-- }

-- Integrate autopairs with cmp
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)
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
nnoremap <leader>gd <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap <leader>gr <cmd>lua vim.lsp.buf.references()<cr>
nnoremap <leader>gh <cmd>lua vim.lsp.buf.hover()<cr>
nnoremap <leader>rn <cmd>lua vim.lsp.buf.rename()<cr>
nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<cr>

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
nmap <Leader>w <Plug>(easymotion-overwin-w)
nmap <Leader>b <Plug>(easymotion-overwin-b)

" Jump to start of line
nmap <Leader>j <Plug>(easymotion-overwin-line)
let g:EasyMotion_smartcase = 1

" Sneak settings
let g:sneak#label = 1
