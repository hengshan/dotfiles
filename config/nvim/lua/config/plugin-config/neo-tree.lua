-- ============================================================================
-- Neo-tree Configuration - Minimal Default Setup
-- ============================================================================

local status_ok, neo_tree = pcall(require, "neo-tree")
if not status_ok then
  vim.notify("Neo-tree not found!", vim.log.levels.ERROR)
  return
end

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Neo-tree setup with minimal configuration - use mostly defaults
neo_tree.setup({
  close_if_last_window = false,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  
  window = {
    position = "left",
    width = 35,
    mappings = {
      ["<space>"] = { 
        "toggle_node", 
        nowait = false,
      },
      ["<2-LeftMouse>"] = "open",
      ["<cr>"] = "open",
      ["<esc>"] = "cancel",
      ["P"] = { "toggle_preview", config = { use_float = true } },
      ["S"] = "open_split",
      ["s"] = "open_vsplit",
      ["t"] = "open_tabnew",
      ["w"] = "open_with_window_picker",
      ["C"] = "close_node",
      ["z"] = "close_all_nodes",
      ["Z"] = "expand_all_nodes",
      ["a"] = "add",
      ["A"] = "add_directory",
      ["d"] = "delete",
      ["r"] = "rename",
      ["y"] = "copy_to_clipboard",
      ["x"] = "cut_to_clipboard",
      ["p"] = "paste_from_clipboard",
      ["c"] = "copy",
      ["m"] = "move",
      ["q"] = "close_window",
      ["R"] = "refresh",
      ["?"] = "show_help",
      ["<"] = "prev_source",
      [">"] = "next_source",
    }
  },
  
  filesystem = {
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = true,
      hide_by_name = {
        ".DS_Store",
        "thumbs.db",
        "node_modules"
      },
    },
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },
    group_empty_dirs = true,
    hijack_netrw_behavior = "open_default",
    use_libuv_file_watcher = false,
    window = {
      mappings = {
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
        ["H"] = "toggle_hidden",
        ["/"] = "fuzzy_finder",
        ["f"] = "filter_on_submit",
        ["<c-x>"] = "clear_filter",
      },
    },
  },
  
  buffers = {
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },
    group_empty_dirs = true,
    show_unloaded = true,
    window = {
      mappings = {
        ["bd"] = "buffer_delete",
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
      }
    },
  },
  
  git_status = {
    window = {
      position = "float",
      mappings = {
        ["A"]  = "git_add_all",
        ["gu"] = "git_unstage_file",
        ["ga"] = "git_add_file",
        ["gr"] = "git_revert_file",
        ["gc"] = "git_commit",
        ["gp"] = "git_push",
        ["gg"] = "git_commit_and_push",
      }
    }
  }
})

-- Global keymaps
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<cr>', { desc = 'Toggle file tree' })
vim.keymap.set('n', '<leader>E', '<cmd>Neotree focus<cr>', { desc = 'Focus file tree' })
vim.keymap.set('n', '<leader>ef', '<cmd>Neotree reveal<cr>', { desc = 'Find current file in tree' })
vim.keymap.set('n', '<leader>er', '<cmd>Neotree refresh<cr>', { desc = 'Refresh file tree' })
vim.keymap.set('n', '<leader>eg', '<cmd>Neotree git_status<cr>', { desc = 'Git status tree' })
vim.keymap.set('n', '<leader>eb', '<cmd>Neotree buffers<cr>', { desc = 'Buffer tree' })

-- Auto-open neo-tree when starting nvim with a directory
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Open neo-tree on startup with directory",
  callback = function(data)
    local directory = vim.fn.isdirectory(data.file) == 1
    if not directory then
      return
    end
    vim.cmd.cd(data.file)
    require("neo-tree.command").execute({ action = "show" })
  end
})

-- vim.notify("✅ Neo-tree configured successfully", vim.log.levels.DEBUG)