-- ============================================================================
-- Markdown Configuration
-- ============================================================================

-- Markdown Preview Configuration
vim.g.mkdp_auto_start = 0                     -- Don't auto start preview
vim.g.mkdp_auto_close = 1                     -- Auto close preview when changing buffer
vim.g.mkdp_refresh_slow = 0                   -- Auto refresh preview
vim.g.mkdp_command_for_global = 0             -- Available for all buffers
vim.g.mkdp_open_to_the_world = 0              -- Don't make preview available to network
vim.g.mkdp_open_ip = ''                       -- Custom IP for preview server
vim.g.mkdp_browser = ''                       -- Use default browser
vim.g.mkdp_echo_preview_url = 0               -- Don't echo preview URL
vim.g.mkdp_browserfunc = ''                   -- Custom browser function
vim.g.mkdp_preview_options = {
  mkit = {},
  katex = {},
  uml = {},
  maid = {},
  disable_sync_scroll = 0,                    -- Enable sync scroll
  sync_scroll_type = 'middle',                -- Sync scroll position
  hide_yaml_meta = 1,                         -- Hide YAML metadata
  sequence_diagrams = {},
  flowchart_diagrams = {},
  content_editable = false,                   -- Disable content editing in preview
  disable_filename = 0,                       -- Show filename in preview
  toc = {}
}

-- Markdown filetype options
vim.g.mkdp_markdown_css = ''                  -- Custom CSS for preview
vim.g.mkdp_highlight_css = ''                 -- Custom highlight CSS
vim.g.mkdp_port = ''                          -- Custom port (empty = auto)
vim.g.mkdp_page_title = '「${name}」'         -- Page title template
vim.g.mkdp_filetypes = { 'markdown' }         -- Recognized filetypes

-- Set markdown preview theme (GitHub-like)
vim.g.mkdp_theme = 'dark'

-- Additional markdown-specific keymaps (buffer-local)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local opts = { buffer = true, silent = true }
    
    -- Header shortcuts (both line and word modes)
    vim.keymap.set('n', '<leader>1', 'I# <esc>', 
                   vim.tbl_extend('force', opts, { desc = 'Make line H1' }))
    vim.keymap.set('n', '<leader>2', 'I## <esc>', 
                   vim.tbl_extend('force', opts, { desc = 'Make line H2' }))
    vim.keymap.set('n', '<leader>3', 'I### <esc>', 
                   vim.tbl_extend('force', opts, { desc = 'Make line H3' }))
    vim.keymap.set('n', '<leader>4', 'I#### <esc>', 
                   vim.tbl_extend('force', opts, { desc = 'Make line H4' }))
    vim.keymap.set('n', '<leader>5', 'I##### <esc>', 
                   vim.tbl_extend('force', opts, { desc = 'Make line H5' }))
    vim.keymap.set('n', '<leader>6', 'I###### <esc>', 
                   vim.tbl_extend('force', opts, { desc = 'Make line H6' }))
    
    -- Alternative: Make current word into header (your original idea improved)
    vim.keymap.set('n', '<leader>h1', 'mzyiwi# <esc>p`z', 
                   vim.tbl_extend('force', opts, { desc = 'Make word H1' }))
    vim.keymap.set('n', '<leader>h2', 'mzyiwi## <esc>p`z', 
                   vim.tbl_extend('force', opts, { desc = 'Make word H2' }))
    vim.keymap.set('n', '<leader>h3', 'mzyiwi### <esc>p`z', 
                   vim.tbl_extend('force', opts, { desc = 'Make word H3' }))
    vim.keymap.set('n', '<leader>h4', 'mzyiwi#### <esc>p`z', 
                   vim.tbl_extend('force', opts, { desc = 'Make word H4' }))
    vim.keymap.set('n', '<leader>h5', 'mzyiwi##### <esc>p`z', 
                   vim.tbl_extend('force', opts, { desc = 'Make word H5' }))
    vim.keymap.set('n', '<leader>h6', 'mzyiwi###### <esc>p`z', 
                   vim.tbl_extend('force', opts, { desc = 'Make word H6' }))

    -- Insert shortcuts
    vim.keymap.set('n', '<leader>ml', 'i[]()', 
                   vim.tbl_extend('force', opts, { desc = 'Insert link' }))
    
    vim.keymap.set('n', '<leader>mi', 'i![]()', 
                   vim.tbl_extend('force', opts, { desc = 'Insert image' }))
    
    vim.keymap.set('n', '<leader>mc', 'i```<cr>```<esc>O', 
                   vim.tbl_extend('force', opts, { desc = 'Insert code block' }))
    
    -- Checkbox shortcuts (works with bullets.vim)
    vim.keymap.set('n', '<leader>mx', 'i- [ ] ', 
                   vim.tbl_extend('force', opts, { desc = 'Insert checkbox' }))
    
    vim.keymap.set('n', '<leader>mX', 'i- [x] ', 
                   vim.tbl_extend('force', opts, { desc = 'Insert checked checkbox' }))
    
    -- Table shortcuts
    vim.keymap.set('n', '<leader>tr', 'i| Header1 | Header2 |<cr>|---------|---------|<cr>| Cell1   | Cell2   |<esc>', 
                   vim.tbl_extend('force', opts, { desc = 'Insert table template' }))
    
    -- Quick formatting
    vim.keymap.set('v', '<leader>mb', 'c**<c-r>"**<esc>', 
                   vim.tbl_extend('force', opts, { desc = 'Bold selection' }))
    
    vim.keymap.set('v', '<leader>mi', 'c*<c-r>"*<esc>', 
                   vim.tbl_extend('force', opts, { desc = 'Italic selection' }))
    
    vim.keymap.set('v', '<leader>mc', 'c`<c-r>"`<esc>', 
                   vim.tbl_extend('force', opts, { desc = 'Code selection' }))
    
    -- Set local options for better markdown editing
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = 'nc'
  end,
  desc = "Markdown specific keymaps and settings",
})

-- Markdown file detection for additional extensions
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.md", "*.markdown", "*.mdown", "*.mkd", "*.mkdn", "*.mdwn" },
  callback = function()
    vim.bo.filetype = "markdown"
  end,
  desc = "Set filetype to markdown for various extensions",
})

-- vim.notify("✅ Markdown configuration loaded", vim.log.levels.DEBUG)