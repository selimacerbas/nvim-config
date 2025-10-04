return {
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        dependencies = { "folke/which-key.nvim" },

        -- which-key v3: declare the group in `init` (not in `keys`)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>S", group = "Treesitter/Surround" } })
            end
        end,

        -- only real leader mapping we add: a quick help opener
        keys = {
            { "<leader>Sh", "<cmd>h nvim-surround.usage<CR>", desc = "Surround: Help / usage", mode = "n", silent = true, noremap = true },
        },

        config = function()
            -- 1) Keep plugin defaults (ys / ds / cs / S / yS / gS ...)
            require("nvim-surround").setup()

            -- 2) Label existing (non-leader) maps for which-key (no extra mappings created)

            if not ok or not wk.add then return end

            wk.add({
                -- Normal mode operators
                { "ys",  desc = "Surround add (ys{motion}{char})",         mode = "n" },
                { "yS",  desc = "Surround line (yS{char})",                mode = "n" },
                { "yss", desc = "Surround current line (yss{char})",       mode = "n" },
                { "ySS", desc = "Surround current line (ySS{char})",       mode = "n" },
                { "ds",  desc = "Surround delete (ds{char})",              mode = "n" },
                { "cs",  desc = "Surround change (cs{old}{new})",          mode = "n" },

                -- Visual mode
                { "S",   desc = "Surround selection (S{char})",            mode = "x" },
                { "gS",  desc = "Surround selection (line-wise gS{char})", mode = "x" },
            })
        end,
    },
}
