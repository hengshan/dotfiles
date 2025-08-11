-- ============================================================================
-- Core Vim Options - Restored from original init.vim
-- ============================================================================

-- ============================================================================
-- Leader Keys (set in init.lua - removed duplicate)
-- ============================================================================

-- ============================================================================
-- System Integration
-- ============================================================================
vim.opt.clipboard = 'unnamedplus'  -- Use system clipboard for copy/paste to Windows/Linux

-- ============================================================================
-- Timing Settings (from original config)
-- ============================================================================
vim.opt.timeoutlen = 400    -- Time to wait for a mapped sequence (leader key combo)
vim.opt.ttimeoutlen = 50    -- Faster response for key codes (e.g., arrow keys)

-- ============================================================================
-- Basic Editor Settings
-- ============================================================================
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Cursor and display
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = 'yes'

-- Search settings
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- ============================================================================
-- Indentation (from original config)
-- ============================================================================
vim.opt.expandtab = true        -- Convert tabs to spaces (recommended in original)
vim.opt.tabstop = 2             -- Original used 2 spaces for most files
vim.opt.shiftwidth = 2          -- Original used 2 spaces for most files
vim.opt.softtabstop = 2
vim.opt.autoindent = true
vim.opt.smartindent = true

-- ============================================================================
-- Window and Split Behavior
-- ============================================================================
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ============================================================================
-- Backup and File Handling
-- ============================================================================
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undodir')

-- ============================================================================
-- UI and Appearance
-- ============================================================================
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.showmode = false
vim.opt.showtabline = 2
vim.opt.laststatus = 2
vim.opt.cmdheight = 2

-- Window appearance settings
vim.opt.fillchars:append({
  eob = ' ',         -- Remove ~ at end of buffer
})

-- ============================================================================
-- Mouse and Completion
-- ============================================================================
vim.opt.mouse = 'a'
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- ============================================================================
-- Performance
-- ============================================================================
vim.opt.updatetime = 300
vim.opt.hidden = true

-- ============================================================================
-- UFO Folding Requirements (from original config)
-- ============================================================================
vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- ============================================================================
-- Auto-create directories when saving
-- ============================================================================
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
  callback = function()
    local dir = vim.fn.expand('<afile>:p:h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})
