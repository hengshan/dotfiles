-- ============================================================================
-- Completion System Configuration - Restored from original config
-- ============================================================================

-- ============================================================================
-- LuaSnip Configuration (from original lines 523-700)
-- ============================================================================
local luasnip_ok, luasnip = pcall(require, "luasnip")
if not luasnip_ok then
    vim.notify("LuaSnip not found!", vim.log.levels.ERROR)
    return
end

-- LuaSnip config setup from original (lines 525-529)
luasnip.config.setup({
    history = true,
    update_events = 'TextChanged,TextChangedI',
    delete_check_events = "TextChanged",
})

-- ============================================================================
-- Smart Friendly-snippets Loading (from original lines 532-565)
-- ============================================================================

-- Method 1: Auto-find friendly-snippets (from original)
local function find_friendly_snippets()
    -- Common plugin manager paths (from original lines 534-539)
    local possible_paths = {
        vim.fn.stdpath("data") .. "/plugged/friendly-snippets",           -- vim-plug
        vim.fn.stdpath("data") .. "/lazy/friendly-snippets",              -- lazy.nvim  
        vim.fn.stdpath("data") .. "/site/pack/packer/start/friendly-snippets", -- packer
        "~/.local/share/nvim/plugged/friendly-snippets",                  -- manual install
    }
    
    for _, path in ipairs(possible_paths) do
        local expanded_path = vim.fn.expand(path)
        if vim.fn.isdirectory(expanded_path) == 1 then
            return expanded_path
        end
    end
    
    -- friendly-snippets not found in common locations
    return nil
end

-- Method 2: Smart loading (from original lines 553-565)
local function smart_load_snippets()
    -- First try default loading (let LuaSnip find it itself)
    require('luasnip.loaders.from_vscode').lazy_load()
    
    -- Then try manual path
    local snippets_path = find_friendly_snippets()
    if snippets_path then
        require('luasnip.loaders.from_vscode').lazy_load({paths = {snippets_path}})
    end
end

-- Load snippets
smart_load_snippets()

-- ============================================================================
-- LuaSnip Keymaps (from original lines 568-584)
-- ============================================================================

-- Snippet navigation keymaps (from original config)
vim.keymap.set({"i"}, "<C-K>", function() 
    if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
    end
end, {silent = true, desc = "Expand or jump forward in snippet"})

vim.keymap.set({"i", "s"}, "<C-L>", function() 
    if luasnip.jumpable(1) then
        luasnip.jump(1)
    end
end, {silent = true, desc = "Jump forward in snippet"})

vim.keymap.set({"i", "s"}, "<C-J>", function() 
    if luasnip.jumpable(-1) then
        luasnip.jump(-1)
    end
end, {silent = true, desc = "Jump backward in snippet"})

-- ============================================================================
-- Snippet Management Keymaps (from original lines 587-699)
-- ============================================================================

-- List current filetype snippets (from original lines 587-597)
vim.keymap.set('n', '<leader>sl', function()
    local filetype = vim.bo.filetype
    local snippets = luasnip.get_snippets(filetype)
    
    print("=== Snippets for " .. filetype .. " ===")
    for _, snippet in ipairs(snippets) do
        local desc = snippet.name or snippet.dscr or "No description"
        print("  " .. snippet.trigger .. " → " .. desc)
    end
    print("Total: " .. #snippets .. " snippets")
end, { desc = "List current filetype snippets" })

-- List all available snippets (from original lines 600-618)
vim.keymap.set('n', '<leader>sL', function()
    local all_snippets = luasnip.get_snippets()
    
    print("=== All Available Snippets ===")
    for ft, snippets in pairs(all_snippets) do
        if #snippets > 0 then
            print(ft .. " (" .. #snippets .. " snippets):")
            for i, snippet in ipairs(snippets) do
                if i <= 5 then -- Show only first 5
                    print("  " .. snippet.trigger)
                end
            end
            if #snippets > 5 then
                print("  ... and " .. (#snippets - 5) .. " more")
            end
            print("")
        end
    end
end, { desc = "List all snippets" })

-- Search specific snippet (from original lines 621-643)
vim.keymap.set('n', '<leader>sf', function()
    local search_term = vim.fn.input("Search snippet: ")
    if search_term == "" then return end
    
    local filetype = vim.bo.filetype
    local snippets = luasnip.get_snippets(filetype)
    
    print("=== Search Results for '" .. search_term .. "' ===")
    local found = 0
    for _, snippet in ipairs(snippets) do
        if string.find(snippet.trigger:lower(), search_term:lower()) or 
           (snippet.name and string.find(snippet.name:lower(), search_term:lower())) then
            print("  " .. snippet.trigger .. " → " .. (snippet.name or ""))
            found = found + 1
        end
    end
    
    if found == 0 then
        print("No snippets found matching '" .. search_term .. "'")
    else
        print("Found " .. found .. " matching snippets")
    end
end, { desc = "Search snippets" })

-- Quick add snippet (from original lines 646-664)
vim.keymap.set('n', '<leader>sa', function()
    local filetype = vim.bo.filetype
    local trigger = vim.fn.input("Snippet trigger: ")
    if trigger == "" then return end
    
    local description = vim.fn.input("Description: ")
    local content = vim.fn.input("Content: ")
    
    -- Create simple snippet
    luasnip.add_snippets(filetype, {
        luasnip.snippet(trigger, {
            luasnip.text_node(content),
            luasnip.insert_node(0)
        })
    })
    
    print("✓ Added snippet '" .. trigger .. "' for " .. filetype)
end, { desc = "Add simple snippet" })

-- Open snippets editing file (from original lines 667-688)
vim.keymap.set('n', '<leader>se', function()
    local snippets_file = vim.fn.stdpath("config") .. "/lua/snippets/init.lua"
    
    -- Create basic template if file doesn't exist
    if vim.fn.filereadable(snippets_file) == 0 then
        local template = [[-- Custom snippets
local luasnip = require('luasnip')
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node

-- Add your custom snippets here
luasnip.add_snippets("python", {
  -- Example snippet here
})
]]
        vim.fn.mkdir(vim.fn.fnamemodify(snippets_file, ":h"), "p")
        vim.fn.writefile(vim.split(template, '\n'), snippets_file)
    end
    
    vim.cmd("edit " .. snippets_file)
end, { desc = "Edit custom snippets" })

-- Reload snippets (from original lines 691-699)
vim.keymap.set('n', '<leader>sr', function()
    package.loaded["snippets"] = nil
    local ok, err = pcall(require, "snippets")
    if ok then
        print("✓ Snippets reloaded successfully")
    else
        print("✗ Error reloading snippets: " .. err)
    end
end, { desc = "Reload snippets" })

-- ============================================================================
-- nvim-cmp Configuration (from original lines 702-775)
-- ============================================================================
local cmp_ok, cmp = pcall(require, "cmp")
local lspkind_ok, lspkind = pcall(require, "lspkind")

if not cmp_ok then
    vim.notify("nvim-cmp not found!", vim.log.levels.ERROR)
    return
end

-- Setup nvim-cmp (from original config)
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)  -- From original line 708
        end,
    },
    
    -- Window configuration (from original lines 711-714)
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    
    -- Mapping configuration (from original lines 715-735)
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),  -- From original
        ['<C-f>'] = cmp.mapping.scroll_docs(4),   -- From original
        ['<C-Space>'] = cmp.mapping.complete(),   -- From original
        ['<C-e>'] = cmp.mapping.abort(),          -- From original
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- From original
        
        -- Tab mapping from original (lines 721-735)
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
        
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    
    -- Sources configuration (from original lines 736-741)
    sources = cmp.config.sources({
        { name = 'nvim_lsp', priority = 1000 },   -- From original
        { name = 'luasnip', priority = 750 },     -- From original  
        { name = 'buffer', priority = 500 },      -- From original
        { name = 'path', priority = 250 },        -- From original
    }),
    
    -- Formatting with lspkind (from original lines 742-748)
    formatting = lspkind_ok and {
        format = lspkind.cmp_format({
            mode = 'symbol_text',     -- From original
            maxwidth = 50,           -- From original
            ellipsis_char = '...',   -- From original
        })
    } or {
        format = function(entry, vim_item)
            vim_item.menu = ({
                nvim_lsp = '[LSP]',
                luasnip = '[Snippet]',
                buffer = '[Buffer]',
                path = '[Path]',
            })[entry.source.name]
            return vim_item
        end
    }
})

-- Command line completion (from original lines 751-768)
-- Use buffer source for `/` and `?` (from original lines 752-757)
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for `:` (from original lines 760-767) 
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }  -- From original
})

-- ============================================================================
-- Integrate autopairs with cmp (from original lines 771-775)
-- ============================================================================
local cmp_autopairs_ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
if cmp_autopairs_ok then
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end

vim.notify("✅ Completion system configured successfully", vim.log.levels.INFO)