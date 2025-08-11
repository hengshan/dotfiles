-- ============================================================================
-- Telescope Configuration - Restored from original config
-- ============================================================================

local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  vim.notify("Telescope not found!", vim.log.levels.ERROR)
  return
end

-- Telescope setup (from original lines 198-227)
telescope.setup({
  defaults = {
    -- Custom prompt and selection indicators (from original config)
    prompt_prefix = "🔍 ",
    selection_caret = "➤ ",
    
    -- File ignore patterns (from original lines 203-210)
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist/",
      "build/",
      "__pycache__/",
      "*.pyc",
      -- Additional patterns for better filtering
      "%.lock",
      "%.min.js",
      "%.min.css",
    },
    
    -- Layout configuration (from original lines 211-215)
    layout_config = {
      horizontal = {
        preview_width = 0.6,
      },
    },
    
    -- Additional useful defaults
    path_display = { "truncate" },
    dynamic_preview_title = true,
    
    -- Mappings for better navigation
    mappings = {
      i = {
        ["<C-n>"] = "move_selection_next",
        ["<C-p>"] = "move_selection_previous",
        ["<C-c>"] = "close",
        ["<Down>"] = "move_selection_next",
        ["<Up>"] = "move_selection_previous",
        ["<CR>"] = "select_default",
        ["<C-x>"] = "select_horizontal",
        ["<C-v>"] = "select_vertical",
        ["<C-t>"] = "select_tab",
        ["<C-u>"] = "preview_scrolling_up",
        ["<C-d>"] = "preview_scrolling_down",
      },
      n = {
        ["<esc>"] = "close",
        ["<CR>"] = "select_default",
        ["<C-x>"] = "select_horizontal",
        ["<C-v>"] = "select_vertical",
        ["<C-t>"] = "select_tab",
        ["j"] = "move_selection_next",
        ["k"] = "move_selection_previous",
        ["H"] = "move_to_top",
        ["M"] = "move_to_middle",
        ["L"] = "move_to_bottom",
        ["<Down>"] = "move_selection_next",
        ["<Up>"] = "move_selection_previous",
        ["gg"] = "move_to_top",
        ["G"] = "move_to_bottom",
        ["<C-u>"] = "preview_scrolling_up",
        ["<C-d>"] = "preview_scrolling_down",
      },
    },
  },
  
  -- Picker specific configurations (from original lines 217-227)
  pickers = {
    find_files = {
      hidden = true,  -- Show hidden files (from original config)
    },
    live_grep = {
      additional_args = function(opts)
        return {"--hidden"}  -- Include hidden files in search (from original)
      end
    },
    -- Additional useful picker configurations
    buffers = {
      previewer = false,
      layout_config = {
        width = 80,
      },
    },
    oldfiles = {
      cwd_only = true,
    },
    grep_string = {
      additional_args = function(opts)
        return {"--hidden"}
      end
    },
  },
  
  -- Extensions
  extensions = {
    -- Will be loaded by other configs
  },
})

-- Load useful extensions
pcall(telescope.load_extension, "fzf")

-- Override keymaps from keymaps.lua with proper telescope functions
local builtin = require('telescope.builtin')

-- File finding (enhanced from original keymaps)
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'Commands' })

-- Additional useful telescope mappings
vim.keymap.set('n', '<leader>fs', builtin.grep_string, { desc = 'Grep string under cursor' })
vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = 'Find marks' })
vim.keymap.set('n', '<leader>fj', builtin.jumplist, { desc = 'Find jumplist' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Find keymaps' })
vim.keymap.set('n', '<leader>ft', builtin.filetypes, { desc = 'Find filetypes' })

-- -- vim.notify("✅ Telescope configured successfully", vim.log.levels.DEBUG)