return {
    {
        "nvzone/typr",
        version = "*",
        dependencies = {
            "nvzone/volt",
            "folke/which-key.nvim",
        },
        cmd = { "Typr", "TyprStats" },

        -- which-key v3: show the group in the menu immediately
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>w", group = "Typer / Vim" } })
            end
        end,

        -- v3-friendly real mappings (so Lazy can load on press)
        keys = {
            { "<leader>wt", "<cmd>Typr<CR>",      desc = "Typr: Start practice",  mode = "n", silent = true, noremap = true },
            { "<leader>ws", "<cmd>TyprStats<CR>", desc = "Typr: Stats dashboard", mode = "n", silent = true, noremap = true },
        },

        opts = {},

        config = function(_, opts)
            require("typr").setup(opts)

            -- (optional) keep completion off in Typr buffers
            local ok_cmp, cmp = pcall(require, "cmp")
            if ok_cmp then
                cmp.setup.filetype("typr", { enabled = false })
                cmp.setup.filetype("typrstats", { enabled = false })
            end

            -- Buffer-local which-key hints inside Typr UIs
            local ok, wk = pcall(require, "which-key")
            if not ok or not wk.add then return end

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "typr",
                callback = function(ev)
                    wk.add({
                        { "s", "Toggle symbols",   mode = "n", buffer = ev.buf },
                        { "n", "Toggle numbers",   mode = "n", buffer = ev.buf },
                        { "r", "Randomize text",   mode = "n", buffer = ev.buf },
                        { "1", "Practice 1 line",  mode = "n", buffer = ev.buf },
                        { "2", "Practice 2 lines", mode = "n", buffer = ev.buf },
                        { "3", "Practice 3 lines", mode = "n", buffer = ev.buf },
                        { "4", "Practice 4 lines", mode = "n", buffer = ev.buf },
                        { "5", "Practice 5 lines", mode = "n", buffer = ev.buf },
                        { "6", "Practice 6 lines", mode = "n", buffer = ev.buf },
                        { "7", "Practice 7 lines", mode = "n", buffer = ev.buf },
                        { "8", "Practice 8 lines", mode = "n", buffer = ev.buf },
                        { "9", "Practice 9 lines", mode = "n", buffer = ev.buf },
                    })
                end,
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "typrstats",
                callback = function(ev)
                    wk.add({
                        { "D", "Back to dashboard", mode = "n", buffer = ev.buf },
                        { "H", "History",           mode = "n", buffer = ev.buf },
                        { "K", "Raw keystrokes",    mode = "n", buffer = ev.buf },
                    })
                end,
            })
        end,
    },
}
