-- ============================================================================
-- Navigation Plugins Configuration - Restored from original config
-- ============================================================================

-- ============================================================================
-- EasyMotion Configuration (from original lines 2543-2552)
-- ============================================================================
-- EasyMotion settings (from original config)
vim.g.EasyMotion_do_mapping = 0  -- Disable default mappings (from original)
vim.g.EasyMotion_smartcase = 1   -- Smart case matching (from original)

-- EasyMotion keymaps (from original config)
-- Use regular motions instead of overwin to avoid regex errors (from original comment)
vim.keymap.set('n', '<Leader>s', '<Plug>(easymotion-f2)', { desc = 'EasyMotion: Find 2 characters' })
-- Jump to start of word (forward/backward) (from original)
vim.keymap.set('n', '<Leader>ss', '<Plug>(easymotion-bd-w)', { desc = 'EasyMotion: Jump to word' })
-- Jump to start of line (from original)
vim.keymap.set('n', '<Leader>g', '<Plug>(easymotion-bd-jk)', { desc = 'EasyMotion: Jump to line' })

-- ============================================================================
-- Sneak Configuration (from original lines 2554-2555)
-- ============================================================================
-- Sneak settings (from original config)
vim.g.sneak_label = 1  -- Enable labels for sneak (from original)

-- ============================================================================
-- Additional Navigation Enhancements
-- ============================================================================

-- Buffer switching enhancements
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete current buffer' })
vim.keymap.set('n', '<leader>ba', ':bufdo bd<CR>', { desc = 'Delete all buffers' })

-- Tab navigation
vim.keymap.set('n', '<leader>tn', ':tabnew<CR>', { desc = 'New tab' })
vim.keymap.set('n', '<leader>tc', ':tabclose<CR>', { desc = 'Close tab' })
vim.keymap.set('n', '<leader>to', ':tabonly<CR>', { desc = 'Close other tabs' })

-- Quick navigation to common files
vim.keymap.set('n', '<leader>fv', ':e ~/.config/nvim/init.lua<CR>', { desc = 'Edit init.lua' })
vim.keymap.set('n', '<leader>fz', ':e ~/.zshrc<CR>', { desc = 'Edit zshrc' })

-- vim.notify("✅ Navigation plugins configured successfully", vim.log.levels.DEBUG)
