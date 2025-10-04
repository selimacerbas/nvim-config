return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        dependencies = { "echasnovski/mini.icons" }, -- optional, for nice symbols
        config = function()
            local wk = require("which-key")

            wk.setup({
                plugins = {
                    spelling = { enabled = true, suggestions = 20 }, -- shows z= suggestions nicely
                },
                -- Show prettier labels for these keys in the popup
                replace = {
                    ["<space>"] = "SPC",
                    ["<cr>"]    = "RET",
                    ["<tab>"]   = "TAB",
                },
                win = {
                    border = "rounded",
                    no_overlap = true, -- avoid covering the statusline/cmdline if possible
                },
                layout = {
                    align = "center",
                },
                icons = {
                    breadcrumb = "»",
                    separator  = "➜",
                    group      = "+",
                },
                show_help = false, -- popup stays clean; use :h which-key for docs
            })

            -- -- Declare your top-level groups so they appear immediately
            -- local add = wk.add or function(spec, opts) wk.register(spec, opts) end
            -- if wk.add then
            --     -- which-key v3
            --     add({
            --         { "<leader>a",  group = "Avante" },
            --         { "<leader>b",  group = "Bookmark",              mode = "n" },
            --         { "<leader>c",  group = "Comment",               mode = "n" },
            --         { "<leader>d",  group = "DAP" },
            --         { "<leader>t",  group = "Terminal" },
            --         { "<leader>T",  group = "Telescope" },
            --         { "<leader>n",  group = "Nvimtree" },
            --         { "<leader>r",  group = "Refactor" },
            --         { "<leader>k",  group = "KeyAnalyzer" },
            --         { "<leader>l",  group = "LSP" },
            --         { "<leader>m",  group = "Markdown" },
            --         { "<leader>j",  group = "Jupyter/Pyrola" },
            --         { "<leader>z",  group = "Todos" },
            --         { "<leader>Z",  group = "Zen" },
            --         { "<leader>s",  group = "Snippets" },
            --         { "<leader>S",  group = "Treesitter" },
            --         { "<leader>w",  group = "Typr" },
            --         { "<leader>e",  group = "Tabs" },
            --         { "<leader>h",  group = "MCPHub" },
            --         { "<leader>H",  group = "Hardtime" },
            --         { "<leader>g",  group = "Git" },
            --         { "<leader>gf", group = "Git: Find (Telescope)", mode = "n" },
            --         { "<leader>u",  group = "UI / Toggles" },
            --         { "<leader>o",  group = "Pipeline" },
            --         { "<leader>ui", group = "Indent Guides" },
            --         { "<leader>ua", group = "AutoSave" },
            --         { "<leader>ut", group = "Theme" },
            --         { "<leader>v",  group = "VimTeX / Vim training" },
            --         { '<leader>p',  group = 'Pairs' },
            --     })
            -- else
            --     -- which-key v2 fallback
            --     wk.register({
            --         a = { name = "Avante" },
            --         b = { name = "Bookmark", mode = "n" },
            --         c = { name = "Comment", mode = "n" },
            --         d = { name = "DAP" },
            --         t = { name = "Terminal" },
            --         T = { name = "Telescope" },
            --         n = { name = "Nvimtree" },
            --         r = { name = "Refactor" },
            --         j = { name = "Jupyter/Pyrola" },
            --         k = { name = "KeyAnalyzer" },
            --         l = { name = "LSP" },
            --         m = { name = "Markdown" },
            --         z = { name = "Todos" },
            --         Z = { name = "Zen" },
            --         s = { name = "Snippets" },
            --         S = { name = "Treesitter" },
            --         w = { name = "Typr" },
            --         e = { name = "Tabs" },
            --         h = { name = "MCPHub" },
            --         H = { name = "Hardtime" },
            --         g = { name = "Git" },
            --         gf = { name = "Git: Find (Telescope)", mode = "n" },
            --         u = { name = "UI / Toggles" },
            --         o = { name = "Pipeline" },
            --         ui = { name = "Indent Guides" },
            --         ua = { name = "AutoSave" },
            --         ut = { name = "Theme" },
            --         v = { name = "VimTeX / Vim training" },
            --         p = { name = "Pairs" },
            --     }, { prefix = "<leader>" })
            -- end
        end,
    },
}
