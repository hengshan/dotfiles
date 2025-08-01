-- ============================================================================
-- Git Integration Plugins Configuration
-- ============================================================================

-- ============================================================================
-- Diffview.nvim Configuration (from original config - was missing!)
-- ============================================================================
local diffview_ok, diffview = pcall(require, "diffview")
if diffview_ok then
    diffview.setup({
        diff_binaries = false,    -- Show diffs for binaries
        enhanced_diff_hl = true,   -- Use enhanced diff highlighting
        git_cmd = { "git" },       -- The git executable
        use_icons = true,          -- Requires nvim-web-devicons
        
        -- File panel settings
        file_panel = {
            listing_style = "tree",  -- One of 'list' or 'tree'
            tree_options = {
                flatten_dirs = true,   -- Flatten dirs that only contain one single dir
                folder_statuses = "only_folded",  -- One of 'never', 'only_folded' or 'always'
            },
            win_config = {
                position = "left",     -- One of 'left', 'right', 'top', 'bottom'
                width = 35,           -- Only applies when position is 'left' or 'right'
                height = 10,          -- Only applies when position is 'top' or 'bottom'
            },
        },
        
        -- File history panel settings
        file_history_panel = {
            log_options = {
                git = {
                    single_file = {
                        diff_merges = "combined",
                    },
                    multi_file = {
                        diff_merges = "first-parent",
                    },
                },
            },
            win_config = {
                position = "bottom",
                height = 16,
            },
        },
        
        -- Commit log panel settings
        commit_log_panel = {
            win_config = {
                position = "bottom",
                height = 16,
            }
        },
        
        -- Default arguments for git commands
        default_args = {
            DiffviewOpen = {},
            DiffviewFileHistory = {},
        },
        
        -- Keymaps in diffview mode
        keymaps = {
            disable_defaults = false,
            view = {
                ["<tab>"]      = "select_next_entry",
                ["<s-tab>"]    = "select_prev_entry",
                ["gf"]         = "goto_file",
                ["<C-w><C-f>"] = "goto_file_split",
                ["<C-w>gf"]    = "goto_file_tab",
                ["<leader>e"]  = "focus_files",
                ["<leader>b"]  = "toggle_files",
            },
            file_panel = {
                ["j"]             = "next_entry",
                ["<down>"]        = "next_entry",
                ["k"]             = "prev_entry",
                ["<up>"]          = "prev_entry",
                ["<cr>"]          = "select_entry",
                ["o"]             = "select_entry",
                ["<2-LeftMouse>"] = "select_entry",
                ["-"]             = "toggle_stage_entry",
                ["S"]             = "stage_all",
                ["U"]             = "unstage_all",
                ["X"]             = "restore_entry",
                ["R"]             = "refresh_files",
                ["L"]             = "open_commit_log",
                ["<c-b>"]         = "scroll_view(-0.25)",
                ["<c-f>"]         = "scroll_view(0.25)",
                ["<tab>"]         = "select_next_entry",
                ["<s-tab>"]       = "select_prev_entry",
                ["gf"]            = "goto_file",
                ["<C-w><C-f>"]    = "goto_file_split",
                ["<C-w>gf"]       = "goto_file_tab",
                ["i"]             = "listing_style",
                ["f"]             = "toggle_flatten_dirs",
                ["<leader>e"]     = "focus_files",
                ["<leader>b"]     = "toggle_files",
            },
            file_history_panel = {
                ["g!"]            = "options",
                ["<C-A-d>"]       = "open_in_diffview",
                ["y"]             = "copy_hash",
                ["L"]             = "open_commit_log",
                ["zR"]            = "open_all_folds",
                ["zM"]            = "close_all_folds",
                ["j"]             = "next_entry",
                ["<down>"]        = "next_entry",
                ["k"]             = "prev_entry",
                ["<up>"]          = "prev_entry",
                ["<cr>"]          = "select_entry",
                ["o"]             = "select_entry",
                ["<2-LeftMouse>"] = "select_entry",
                ["<c-b>"]         = "scroll_view(-0.25)",
                ["<c-f>"]         = "scroll_view(0.25)",
                ["<tab>"]         = "select_next_entry",
                ["<s-tab>"]       = "select_prev_entry",
                ["gf"]            = "goto_file",
                ["<C-w><C-f>"]    = "goto_file_split",
                ["<C-w>gf"]       = "goto_file_tab",
                ["<leader>e"]     = "focus_files",
                ["<leader>b"]     = "toggle_files",
            },
            option_panel = {
                ["<tab>"] = "select_entry",
                ["q"]     = "close",
            },
        },
    })

    -- Diffview keymaps
    vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = 'Open diffview' })
    vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory<cr>', { desc = 'File history' })
    vim.keymap.set('n', '<leader>gc', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' })
    vim.keymap.set('n', '<leader>gr', '<cmd>DiffviewRefresh<cr>', { desc = 'Refresh diffview' })
    
    vim.notify("✅ Diffview.nvim configured", vim.log.levels.INFO)
end

-- ============================================================================
-- Additional Git Keymaps (to complement GitSigns from ui.lua)
-- ============================================================================

-- Git commands via vim commands
vim.keymap.set('n', '<leader>gs', ':Git status<CR>', { desc = 'Git status' })
vim.keymap.set('n', '<leader>ga', ':Git add .<CR>', { desc = 'Git add all' })
vim.keymap.set('n', '<leader>gA', ':Git add %<CR>', { desc = 'Git add current file' })
vim.keymap.set('n', '<leader>gci', ':Git commit<CR>', { desc = 'Git commit' })
vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { desc = 'Git push' })
vim.keymap.set('n', '<leader>gl', ':Git pull<CR>', { desc = 'Git pull' })
vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { desc = 'Git blame' })
vim.keymap.set('n', '<leader>gL', ':Git log --oneline<CR>', { desc = 'Git log' })

vim.notify("✅ Git integration configured successfully", vim.log.levels.INFO)