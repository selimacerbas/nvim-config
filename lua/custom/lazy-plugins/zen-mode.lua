return {
    {
        "folke/zen-mode.nvim",
        dependencies = { "folke/which-key.nvim" },
        opts = {
            window = {
                width = 80, -- default preset
                options = {
                    number = false,
                    relativenumber = false,
                },
            },
            plugins = {
                twilight = { enabled = true }, -- pairs with your twilight setup
            },
            -- Optional UX polish: temporarily tweak buffer-local opts
            on_open = function(win)
                pcall(function()
                    vim.opt_local.colorcolumn = ""
                    vim.opt_local.cursorline  = false
                end)
            end,
            on_close = function()
                -- nothing to restore (keep it simple and non-invasive)
            end,
        },
        config = function(_, opts)
            local zen = require("zen-mode")
            zen.setup(opts)

            -- safe map helper to avoid overriding user maps
            local function safe_map(lhs, rhs, desc)
                if vim.fn.maparg(lhs, "n") == "" then
                    vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
                end
            end

            -- Toggle + quick presets (stay within <leader>z namespace)
            safe_map("<leader>Zz", function() zen.toggle() end, "Zen: toggle")
            safe_map("<leader>Z1", function() zen.toggle({ window = { width = 80 } }) end, "Zen: 80 cols")
            safe_map("<leader>Z2", function() zen.toggle({ window = { width = 100 } }) end, "Zen: 100 cols")
            safe_map("<leader>Z3", function() zen.toggle({ window = { width = 120 } }) end, "Zen: 120 cols")

            -- Which-Key labels (don’t rename the group; you already use <leader>z for Todos/Zen)
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>Zz", desc = "Zen: toggle" },
                    { "<leader>Z1", desc = "Zen: 80 cols" },
                    { "<leader>Z2", desc = "Zen: 100 cols" },
                    { "<leader>Z3", desc = "Zen: 120 cols" },
                })
            end
        end,
    },
}
