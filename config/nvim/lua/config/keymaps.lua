-- ============================================================================
-- Key Mappings - Restored from original init.vim with improvements
-- ============================================================================

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ============================================================================
-- Escape Alternatives (from original config)
-- ============================================================================
map('i', 'jj', '<Esc>', { desc = 'Exit insert mode' })  -- User's preferred jj mapping

-- Split line and create new line with indent (from original line 11)
-- Changed from 'K' to avoid conflict with LSP hover
map('n', '<leader>k', 'a<CR><Esc>', { desc = 'Split line and create new line with indent' })

-- ============================================================================
-- Search and Navigation
-- ============================================================================
-- Clear search highlighting (from original line 2499)
map('n', '<C-n>', ':nohl<CR>', { desc = 'Clear search highlighting' })

-- ============================================================================
-- Window Navigation and Management
-- ============================================================================
-- Window navigation
map('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })

-- Window resizing (from original lines 2558-2563)
map('n', '<leader>kk', ':resize +4<CR>', { desc = 'Increase window height' })
map('n', '<leader>jj', ':resize -4<CR>', { desc = 'Decrease window height' })
map('n', '<leader>h', ':vertical resize -4<CR>', { desc = 'Decrease window width' })
map('n', '<leader>l', ':vertical resize +4<CR>', { desc = 'Increase window width' })
map('n', '<leader>;', '<C-w>=', { desc = 'Equalize window sizes' })

-- ============================================================================
-- Window Maximization (Simple and Reliable Alternative)
-- ============================================================================
-- Simple window maximize toggle using native Vim commands
local maximized = false
local function toggle_maximize()
  if maximized then
    vim.cmd('wincmd =')  -- Equalize all windows
    maximized = false
  else
    vim.cmd('resize 999')        -- Maximize height
    vim.cmd('vertical resize 999') -- Maximize width  
    maximized = true
  end
end

map('n', '<leader>z', toggle_maximize, { desc = 'Toggle maximize window' })

-- ============================================================================
-- Buffer Navigation
-- ============================================================================
map('n', '<S-l>', ':bnext<CR>', { desc = 'Next buffer' })
map('n', '<S-h>', ':bprevious<CR>', { desc = 'Previous buffer' })

-- ============================================================================
-- Visual Mode Enhancements
-- ============================================================================
-- Better indenting in visual mode
map('v', '<', '<gv', { desc = 'Indent left and reselect' })
map('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Move selected lines up/down
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- ============================================================================
-- Copy/Paste Enhancements
-- ============================================================================
-- Stay in center when jumping
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
map('n', 'n', 'nzzzv', { desc = 'Next search result and center' })
map('n', 'N', 'Nzzzv', { desc = 'Previous search result and center' })

-- Better paste in visual mode
map('x', '<leader>p', '"_dP', { desc = 'Paste without yanking' })

-- System clipboard operations
map('n', '<leader>y', '"+y', { desc = 'Copy to system clipboard' })
map('v', '<leader>y', '"+y', { desc = 'Copy to system clipboard' })
map('n', '<leader>Y', '"+Y', { desc = 'Copy line to system clipboard' })

-- Delete to void register
map('n', '<leader>d', '"_d', { desc = 'Delete to void register' })
map('v', '<leader>d', '"_d', { desc = 'Delete to void register' })

-- ============================================================================
-- File Operations
-- ============================================================================
-- Save file (from original line 2568)
map('n', '<leader>w', ':w<CR>', { desc = 'Save file' })

-- Make file executable
map('n', '<leader>x', '<cmd>!chmod +x %<CR>', { desc = 'Make file executable' })

-- ============================================================================
-- Terminal
-- ============================================================================
-- Open terminal at bottom (from original line 2566)
map('n', '<leader>t', ':belowright split | terminal<CR>', { desc = 'Open terminal at bottom' })

-- Terminal escape (from original line 2571)
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- ============================================================================
-- Quick Fix and Location List Navigation
-- ============================================================================
map('n', '<C-k>', '<cmd>cnext<CR>zz', { desc = 'Next quickfix item' })
map('n', '<C-j>', '<cmd>cprev<CR>zz', { desc = 'Previous quickfix item' })
map('n', '<leader>k', '<cmd>lnext<CR>zz', { desc = 'Next location list item' })
map('n', '<leader>j', '<cmd>lprev<CR>zz', { desc = 'Previous location list item' })

-- ============================================================================
-- Search and Replace
-- ============================================================================
-- Replace word under cursor
map('n', '<leader>u', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { noremap = true, silent = false, desc = 'Replace word under cursor' })

-- ============================================================================
-- Comment Toggle (will be enhanced with proper comment detection)
-- ============================================================================
-- Basic comment toggle (will be overridden by plugin config later)
map('n', '<leader>/', 'gcc', { desc = 'Toggle line comment' })
map('v', '<leader>/', 'gc', { desc = 'Toggle block comment' })

-- ============================================================================
-- Plugin Keymaps (placeholders - will be overridden by plugin configs)
-- ============================================================================

-- Telescope (from original lines 2502-2507)
map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help tags' })
map('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = 'Recent files' })
map('n', '<leader>fc', '<cmd>Telescope commands<cr>', { desc = 'Commands' })

-- File tree (from original lines 2510-2511)
map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle file tree' })
map('n', '<leader>E', '<cmd>NvimTreeFocus<cr>', { desc = 'Focus file tree' })

-- LSP (from original lines 2514-2518)
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { desc = 'Go to definition' })
map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', { desc = 'Show references' })
map('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', { desc = 'Hover documentation' })
map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { desc = 'Rename symbol' })

-- Diagnostic (from original line 2574)
map('n', '<leader>le', '<cmd>lua vim.diagnostic.open_float()<CR>', { desc = 'Show diagnostic' })

