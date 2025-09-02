return {
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "folke/which-key.nvim",
        },
        build = "make install_jsregexp",
        event = "InsertEnter",
        opts = {
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = false,
        },
        keys = {
            -- Insert/Select: expand & navigate snippets (Alt keys to avoid conflicts)
            {
                "<M-k>",
                function()
                    local ls = require("luasnip")
                    if ls.expand_or_jumpable() then ls.expand_or_jump() end
                end,
                mode = { "i", "s" },
                desc = "Snippet: Expand / Jump",
            },
            {
                "<M-j>",
                function()
                    local ls = require("luasnip")
                    if ls.jumpable(-1) then ls.jump(-1) end
                end,
                mode = { "i", "s" },
                desc = "Snippet: Jump Back",
            },
            {
                "<M-l>",
                function()
                    local ls = require("luasnip")
                    if ls.choice_active() then ls.change_choice(1) end
                end,
                mode = { "i", "s" },
                desc = "Snippet: Next Choice",
            },
            {
                "<M-h>",
                function()
                    local ls = require("luasnip")
                    if ls.choice_active() then ls.change_choice(-1) end
                end,
                mode = { "i", "s" },
                desc = "Snippet: Prev Choice",
            },

            -- Normal-mode helpers under <leader>s
            { "<leader>se", function() require("luasnip").expand() end,         desc = "Snippets: Expand (if available)" },
            { "<leader>su", function() require("luasnip").unlink_current() end, desc = "Snippets: Unlink current" },
            {
                "<leader>sr",
                function()
                    local ls = require("luasnip")
                    ls.cleanup()
                    require("luasnip.loaders.from_vscode").lazy_load()
                    vim.notify("LuaSnip: snippets reloaded")
                end,
                desc = "Snippets: Reload",
            },
        },
        config = function(_, opts)
            local ls = require("luasnip")
            ls.config.set_config(opts)

            -- Load community VSCode snippets
            require("luasnip.loaders.from_vscode").lazy_load()

            -- Optionally load user Lua snippets if you have ~/.config/nvim/lua/snippets
            local user_snips = vim.fn.stdpath("config") .. "/lua/snippets"
            if vim.loop.fs_stat(user_snips) then
                require("luasnip.loaders.from_lua").lazy_load({ paths = user_snips })
            end

            -- which-key labels (normal + insert/select)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    -- { "<leader>s",  group = "Snippets" },
                    { "<leader>se", desc = "Expand (normal)" },
                    { "<leader>su", desc = "Unlink current" },
                    { "<leader>sr", desc = "Reload snippets" },
                }, { mode = "n" })

                add({
                    { "<M-k>", desc = "Snippet: Expand / Jump" },
                    { "<M-j>", desc = "Snippet: Jump Back" },
                    { "<M-l>", desc = "Snippet: Next Choice" },
                    { "<M-h>", desc = "Snippet: Prev Choice" },
                }, { mode = { "i", "s" } })
            end
        end,
    },
}
