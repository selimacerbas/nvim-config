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

            -- Declare your top-level groups so they appear immediately
            local add = wk.add or function(spec, opts) wk.register(spec, opts) end
            if wk.add then
                -- which-key v3
                add({
                    { "<leader>t", group = "Telescope" },
                    { "<leader>T", group = "Terminal" },
                    { "<leader>z", group = "Todos / Zen" },
                    { "<leader>S", group = "Treesitter" },
                    { "<leader>w", group = "Typr" },
                    { "<leader>g", group = "Git" },
                    { "<leader>h", group = "LazyGit" },
                    { "<leader>v", group = "VimTeX / Vim training" },
                })
            else
                -- which-key v2 fallback
                wk.register({
                    t = { name = "Telescope" },
                    T = { name = "Terminal" },
                    z = { name = "Todos / Zen" },
                    S = { name = "Treesitter" },
                    w = { name = "Typr" },
                    g = { name = "Git / LazyGit" },
                    v = { name = "VimTeX / Vim training" },
                }, { prefix = "<leader>" })
            end
        end,
    },
}
