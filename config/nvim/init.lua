-- ============================================================================
-- Neovim Configuration - Pure Lua Architecture with Lazy.nvim
-- ============================================================================

-- Ensure faster loading by setting leader keys early
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ============================================================================
-- Core Configuration Loading
-- ============================================================================

-- Load modules in the correct order
require('config.options')    -- Basic vim settings 
require('config.keymaps')    -- Key mappings (including jj escape)
require('config.autocmds')   -- Autocommands and filetype configs
require('config.lazy')       -- Lazy.nvim plugin management