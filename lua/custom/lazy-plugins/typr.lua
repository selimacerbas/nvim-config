return {
    {
        "nvzone/typr",
        version = "*",
        dependencies = {
            "nvzone/volt",
            "folke/which-key.nvim",
        },
        cmd = { "Typr", "TyprStats" },
        keys = {
            { "<leader>wt", "<cmd>Typr<CR>",      desc = "Typr: Start practice" },
            { "<leader>ws", "<cmd>TyprStats<CR>", desc = "Typr: Stats dashboard" },
        },

        -- 🔧 Make the <leader>w "Typr" group visible immediately
        init = function()
            local ok, wk = pcall(require, "which-key")
            if not ok then return end
            if wk.add then
                -- which-key v3
                -- wk.add({ { "<leader>w", group = "Typr" } })
            elseif wk.register then
                -- which-key v2
                -- wk.register({ w = { name = "Typr" } }, { prefix = "<leader>" })
            end
        end,

        opts = {},
        config = function(_, opts)
            require("typr").setup(opts)

            -- (optional) keep completion off in Typr buffers
            local ok_cmp, cmp = pcall(require, "cmp")
            if ok_cmp then
                cmp.setup.filetype("typr", { enabled = false })
                cmp.setup.filetype("typrstats", { enabled = false })
            end

            -- Buffer-local which-key hints inside Typr
            local ok, wk = pcall(require, "which-key"); if not ok then return end
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
