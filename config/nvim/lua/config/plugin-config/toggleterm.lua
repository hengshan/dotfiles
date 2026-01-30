-- ============================================================================
-- ToggleTerm Terminal Management Configuration
-- ============================================================================

local toggleterm_ok, toggleterm = pcall(require, "toggleterm")
if not toggleterm_ok then
  vim.notify("❌ toggleterm.nvim not available", vim.log.levels.ERROR)
  return
end

-- ============================================================================
-- ToggleTerm Setup
-- ============================================================================

toggleterm.setup({
  -- Size can be a number or function which is passed the current terminal
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,

  open_mapping = [[<c-\>]], -- Default toggle mapping

  -- NOTE: this option takes priority over highlights specified in winhl
  hide_numbers = true, -- Hide line numbers in terminal buffers

  shade_filetypes = {},
  autochdir = false, -- When neovim changes directory, toggleterm will match nvim's pwd

  shading_factor = 2, -- The degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light

  start_in_insert = true,
  insert_mappings = true, -- Whether or not the open mapping applies in insert mode
  terminal_mappings = true, -- Whether or not the open mapping applies in the opened terminals

  persist_size = true,
  persist_mode = true, -- If set to true, the previous terminal mode will be remembered

  direction = 'horizontal', -- 'vertical' | 'horizontal' | 'tab' | 'float'

  close_on_exit = true, -- Close the terminal window when the process exits

  shell = vim.o.shell, -- Change the default shell

  auto_scroll = true, -- Automatically scroll to the bottom on terminal output

  -- This field is only relevant if direction is set to 'float'
  float_opts = {
    -- The border key is *almost* the same as 'nvim_open_win'
    border = 'curved', -- 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    winblend = 0,  -- 0 = no transparency, 100 = fully transparent
    zindex = 50,
    title_pos = 'center', -- 'left' | 'center' | 'right'
  },

  winbar = {
    enabled = false,
    name_formatter = function(term) -- Term object
      return term.name
    end
  },

  -- Highlights which map to a highlight group name and a table of it's values
  highlights = {
    -- Highlights which map to a highlight group name and a table of it's values
    Normal = {
      guibg = "#1e1e2e",
    },
    NormalFloat = {
      link = 'Normal'
    },
    FloatBorder = {
      guifg = "#89b4fa",
      guibg = "#1e1e2e",
    },
  },
})

-- ============================================================================
-- Terminal Management Functions
-- ============================================================================

-- Function to set terminal keymaps
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- Apply keymaps to terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*toggleterm#*",
  callback = function()
    set_terminal_keymaps()
  end,
  desc = "Set terminal keymaps for toggleterm"
})

-- ============================================================================
-- Custom Terminal Commands
-- ============================================================================

local Terminal = require('toggleterm.terminal').Terminal

-- Lazygit terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  dir = "git_dir",
  direction = "float",
  float_opts = {
    border = "curved",
    width = math.floor(vim.o.columns * 0.9),
    height = math.floor(vim.o.lines * 0.9),
    winblend = 0,  -- No transparency for better readability
  },
  -- Function to run on opening the terminal
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
  end,
  -- Function to run on closing the terminal
  on_close = function(term)
    vim.cmd("startinsert!")
  end,
})

-- Node.js REPL
local node = Terminal:new({
  cmd = "node",
  direction = "float",
  float_opts = {
    border = "curved",
  },
})

-- Python REPL
local python = Terminal:new({
  cmd = "python3",
  direction = "float",
  float_opts = {
    border = "curved",
  },
})

-- GDB Debug Terminal
local gdb = Terminal:new({
  cmd = "gdb",
  direction = "horizontal",
  close_on_exit = false,
})

-- Build terminal for make/cmake
local build_term = Terminal:new({
  direction = "horizontal",
  close_on_exit = false,
})

-- ============================================================================
-- Terminal Toggle Functions
-- ============================================================================

function _G.toggle_lazygit()
  lazygit:toggle()
end

function _G.toggle_node()
  node:toggle()
end

function _G.toggle_python()
  python:toggle()
end

function _G.toggle_gdb()
  gdb:toggle()
end

function _G.run_build_command(cmd)
  build_term.cmd = cmd
  build_term:open()
end

-- ============================================================================
-- Enhanced Keymaps and Commands
-- ============================================================================

-- Lazygit integration
vim.keymap.set("n", "<leader>G", "<cmd>lua toggle_lazygit()<CR>", { desc = "Toggle Lazygit", silent = true })

-- Language REPLs
vim.keymap.set("n", "<leader>tn", "<cmd>lua toggle_node()<CR>", { desc = "Toggle Node.js REPL", silent = true })
vim.keymap.set("n", "<leader>tp", "<cmd>lua toggle_python()<CR>", { desc = "Toggle Python REPL", silent = true })

-- Debug terminal
vim.keymap.set("n", "<leader>td", "<cmd>lua toggle_gdb()<CR>", { desc = "Toggle GDB Terminal", silent = true })

-- Multiple terminal management
vim.keymap.set("n", "<leader>t1", "<cmd>1ToggleTerm<CR>", { desc = "Toggle Terminal 1", silent = true })
vim.keymap.set("n", "<leader>t2", "<cmd>2ToggleTerm<CR>", { desc = "Toggle Terminal 2", silent = true })
vim.keymap.set("n", "<leader>t3", "<cmd>3ToggleTerm<CR>", { desc = "Toggle Terminal 3", silent = true })

-- Terminal size management
vim.keymap.set("n", "<leader>ts", "<cmd>ToggleTermSetName<CR>", { desc = "Set Terminal Name", silent = true })
vim.keymap.set("n", "<leader>ta", "<cmd>ToggleTermToggleAll<CR>", { desc = "Toggle All Terminals", silent = true })

-- ============================================================================
-- User Commands
-- ============================================================================

-- Build commands using terminals
vim.api.nvim_create_user_command('TermBuild', function(opts)
  local cmd = opts.args ~= "" and opts.args or "make"
  run_build_command(cmd)
end, {
  nargs = '?',
  desc = 'Run build command in terminal',
  complete = function()
    return { "make", "make clean", "cmake --build build", "ninja" }
  end
})

-- Quick compile current file
vim.api.nvim_create_user_command('TermCompile', function()
  local file = vim.fn.expand('%:p')
  local file_stem = vim.fn.expand('%:t:r')
  local is_cpp = file:match("%.cpp$") or file:match("%.cxx$") or file:match("%.cc$")
  local compiler = is_cpp and "g++" or "gcc"
  local std_flag = is_cpp and "-std=c++17" or ""

  local cmd = string.format("%s -g -O0 -Wall %s -o %s %s && ./%s",
    compiler, std_flag, file_stem, file, file_stem)

  run_build_command(cmd)
end, { desc = 'Compile and run current file in terminal' })

-- Send command to specific terminal
vim.api.nvim_create_user_command('TermSend', function(opts)
  local parts = vim.split(opts.args, " ", { plain = true })
  local term_id = tonumber(parts[1])
  local cmd = table.concat(parts, " ", 2)

  if term_id and cmd then
    vim.cmd(string.format("ToggleTermSendCurrentLine %d", term_id))
  else
    vim.notify("Usage: TermSend <terminal_id> <command>", vim.log.levels.ERROR)
  end
end, {
  nargs = '+',
  desc = 'Send command to specific terminal'
})

-- ============================================================================
-- Integration with existing terminal workflow
-- ============================================================================

-- Keep the original <leader>t for compatibility
vim.keymap.set("n", "<leader>T", ":belowright split | terminal<CR>", { desc = "Open built-in terminal (legacy)" })

-- Enhance the experience
vim.notify("✅ ToggleTerm configured with enhanced terminal management", vim.log.levels.DEBUG)
vim.notify("Key mappings: <C-\\> (toggle), <leader>tf (float), <leader>gg (lazygit)", vim.log.levels.DEBUG)
