-- ============================================================================
-- TreeSitter Configuration - Restored from original config
-- ============================================================================

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  vim.notify("TreeSitter not found!", vim.log.levels.ERROR)
  return
end

-- TreeSitter setup (from original lines 163-183)
configs.setup({
  -- Languages from original config (line 164) + additional ones
  ensure_installed = {
    "markdown", "markdown_inline", "lua", "vim", "bash", "python", 
    "typescript", "tsx", "javascript", "html", "css", "json", "yaml", 
    "toml", "c", "cpp", "asm", "cmake", "make", "dockerfile", 
    "gitignore", "regex", "comment",
    -- Additional useful languages (improvements)
    "rust", "go", "php", "vue", "scss", "graphql", "prisma"
  },
  
  -- Sync install false for faster startup
  sync_install = false,
  auto_install = true,
  
  -- Syntax highlighting (from original config)
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  
  -- Incremental selection (from original lines 169-177)
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  
  -- Smart indentation (from original lines 178-182)
  indent = {
    enable = true,
    -- Disable for Python as original config had specialized Python indent plugins
    disable = { "python" },  -- Python has specialized indent plugins
  },
  
  -- Additional modules for enhanced functionality
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
})

-- Set up fold method for TreeSitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- vim.notify("✅ TreeSitter configured successfully", vim.log.levels.DEBUG)