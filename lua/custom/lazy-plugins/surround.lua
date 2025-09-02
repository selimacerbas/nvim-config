return {
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        dependencies = { "folke/which-key.nvim" },
        config = function()
            -- 1) Use plugin defaults (ys / ds / cs / S / yS / gS ...)
            require("nvim-surround").setup()

            -- 2) Describe *existing* non-leader maps with Which-Key (no new maps!)
            local ok, wk = pcall(require, "which-key")
            if not ok then return end

            -- Which-Key v3 style: add specs for mappings that aren't ours (plugin-defined)
            -- This makes Which-Key show proper labels when you hit these keys.
            wk.add({
                -- Normal mode "operators" from nvim-surround
                { "ys",         desc = "Surround add (ys{motion}{char})",         mode = "n" },
                { "yS",         desc = "Surround line (yS{char})",                mode = "n" },
                { "yss",        desc = "Surround current line (yss{char})",       mode = "n" },
                { "ySS",        desc = "Surround current line (ySS{char})",       mode = "n" },
                { "ds",         desc = "Surround delete (ds{char})",              mode = "n" },
                { "cs",         desc = "Surround change (cs{old}{new})",          mode = "n" },

                -- Visual mode
                { "S",          desc = "Surround selection (S{char})",            mode = "x" },
                { "gS",         desc = "Surround selection (line-wise gS{char})", mode = "x" },

                -- 3) A tiny leader group so the plugin shows up in <leader> menus too
                { "<leader>s",  group = "Surround" },
                { "<leader>sh", "<cmd>h nvim-surround.usage<cr>",                 desc = "Help / usage" },
            })
        end,
    },
}
