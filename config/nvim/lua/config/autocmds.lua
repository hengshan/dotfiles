-- ============================================================================
-- Autocommands and Filetype Configuration - Restored from original
-- ============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ============================================================================
-- General Settings
-- ============================================================================
local general_group = augroup("General", { clear = true })

-- Highlight on yank
autocmd("TextYankPost", {
  group = general_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
  desc = "Highlight yanked text",
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = general_group,
  pattern = "*",
  command = "%s/\\s\\+$//e",
  desc = "Remove trailing whitespace",
})

-- Auto resize windows when vim is resized
autocmd("VimResized", {
  group = general_group,
  pattern = "*",
  command = "tabdo wincmd =",
  desc = "Auto resize windows",
})

-- Auto-create directories when saving (already in options.lua but keeping here for completeness)
autocmd("BufWritePre", {
  group = general_group,
  pattern = "*",
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
  desc = "Auto-create directories when saving",
})

-- ============================================================================
-- File Type Specific Settings (from original lines 2525-2526)
-- ============================================================================
local filetype_group = augroup("FileTypeSettings", { clear = true })

-- Python settings (from original config)
autocmd("FileType", {
  group = filetype_group,
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    -- vim.opt_local.colorcolumn = "88"  -- Commented out: PEP 8 line length guide
  end,
  desc = "Python specific settings",
})

-- JavaScript/TypeScript settings (from original config)
autocmd("FileType", {
  group = filetype_group,
  pattern = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
  desc = "JS/TS specific settings",
})

-- HTML/CSS/Vue settings
autocmd("FileType", {
  group = filetype_group,
  pattern = { "html", "css", "scss", "sass", "vue" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
  desc = "HTML/CSS specific settings",
})

-- Lua settings
autocmd("FileType", {
  group = filetype_group,
  pattern = "lua",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
  desc = "Lua specific settings",
})

-- YAML settings
autocmd("FileType", {
  group = filetype_group,
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
  desc = "YAML specific settings",
})

-- Go settings
autocmd("FileType", {
  group = filetype_group,
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 0
    vim.opt_local.expandtab = false  -- Go uses tabs
  end,
  desc = "Go specific settings",
})

-- Rust settings
autocmd("FileType", {
  group = filetype_group,
  pattern = "rust",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    -- vim.opt_local.colorcolumn = "100"  -- Commented out: line length guide
  end,
  desc = "Rust specific settings",
})

-- C/C++ settings
autocmd("FileType", {
  group = filetype_group,
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    -- vim.opt_local.colorcolumn = "80"  -- Commented out: line length guide
  end,
  desc = "C/C++ specific settings",
})

-- Assembly settings (from original config)
autocmd("FileType", {
  group = filetype_group,
  pattern = { "asm", "nasm" },
  callback = function()
    vim.opt_local.tabstop = 8
    vim.opt_local.shiftwidth = 8
    vim.opt_local.softtabstop = 8
    vim.opt_local.expandtab = false  -- Assembly uses tabs
    vim.opt_local.commentstring = '; %s'  -- Assembly comment format
  end,
  desc = "Assembly specific settings",
})

-- Assembly file detection (from original lines 2484-2490)
autocmd({ "BufNewFile", "BufRead" }, {
  group = filetype_group,
  pattern = { "*.nasm", "*.inc", "*.s" },
  callback = function()
    vim.bo.filetype = "asm"
  end,
  desc = "Set filetype to asm for additional assembly file extensions",
})

-- Markdown settings
autocmd("FileType", {
  group = filetype_group,
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
  end,
  desc = "Markdown specific settings",
})

-- ============================================================================
-- Terminal Settings
-- ============================================================================
local terminal_group = augroup("TerminalSettings", { clear = true })

-- Terminal settings
autocmd("TermOpen", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
  desc = "Terminal specific settings",
})

-- Auto enter insert mode in terminal
autocmd("BufEnter", {
  group = terminal_group,
  pattern = "term://*",
  command = "startinsert",
  desc = "Auto enter insert mode in terminal",
})

-- ============================================================================
-- Cursor Position and Navigation
-- ============================================================================
local cursor_group = augroup("CursorSettings", { clear = true })

-- Restore cursor position
autocmd("BufReadPost", {
  group = cursor_group,
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 1 and line <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
  desc = "Restore cursor position",
})

-- ============================================================================
-- Special File Type Behaviors
-- ============================================================================
local special_group = augroup("SpecialFileTypes", { clear = true })

-- Close certain filetypes with q
autocmd("FileType", {
  group = special_group,
  pattern = { "qf", "help", "man", "lspinfo", "spectre_panel" },
  callback = function()
    vim.keymap.set("n", "q", ":close<CR>", { buffer = true, silent = true })
  end,
  desc = "Close special filetypes with q",
})

-- ============================================================================
-- Plugin Specific Autocommands (from original config)
-- ============================================================================
local plugin_group = augroup("PluginAutocommands", { clear = true })

-- Auto-open nvim-tree when starting with a directory (from original lines 2533-2534)
autocmd("VimEnter", {
  group = plugin_group,
  callback = function()
    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv()[0]) ~= 0 and not vim.g.started_by_firenvim then
      vim.cmd("NvimTreeToggle")
      vim.cmd("wincmd p")
      vim.cmd("ene")
      vim.cmd("cd " .. vim.fn.argv()[0])
    end
  end,
  desc = "Auto-open nvim-tree when starting with directory",
})

-- Close nvim-tree if it's the last window (from original line 2537)
autocmd("BufEnter", {
  group = plugin_group,
  callback = function()
    if vim.fn.winnr('$') == 1 and vim.fn.exists('b:NvimTree') ~= 0 and vim.api.nvim_buf_get_var(0, 'NvimTree').isTabTree then
      vim.cmd("quit")
    end
  end,
  desc = "Close nvim-tree if it's the last window",
})