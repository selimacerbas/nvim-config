return {
    {
        "folke/twilight.nvim",
        dependencies = { "folke/which-key.nvim" },
        opts = {
            -- keep defaults but make behavior a bit nicer out of the box
            dimming    = { alpha = 0.25 }, -- default; subtle dim
            context    = 10,               -- keep ~10 lines of context around cursor
            treesitter = true,             -- better context detection
            expand     = { "function", "method", "table", "if_statement", "block", "loop" },
            -- don't dim these UIs/filetypes
            exclude    = {
                "alpha", "help", "lazy", "mason", "lspinfo", "checkhealth",
                "neo-tree", "Trouble", "TelescopePrompt",
            },
        },
        config = function(_, opts)
            require("twilight").setup(opts)

            -- safe map helper (won’t override if user already mapped)
            local function safe_map(lhs, rhs, desc)
                if vim.fn.maparg(lhs, "n") == "" then
                    vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
                end
            end

            -- Put Twilight under <leader>z… to avoid your <leader>t (Telescope) space
            safe_map("<leader>zw", "<cmd>Twilight<CR>", "Twilight: toggle")
            safe_map("<leader>zE", "<cmd>TwilightEnable<CR>", "Twilight: enable")
            safe_map("<leader>zD", "<cmd>TwilightDisable<CR>", "Twilight: disable")

            -- Which-Key labels (we don’t rename the <leader>z group to avoid clobbering your Todo group)
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>zw", desc = "Twilight: toggle" },
                    { "<leader>zE", desc = "Twilight: enable" },
                    { "<leader>zD", desc = "Twilight: disable" },
                })
            end
        end,
    },
}
