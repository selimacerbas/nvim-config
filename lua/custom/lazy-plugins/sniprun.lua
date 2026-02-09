return {
    {
        "michaelb/sniprun",
        build = "sh install.sh",
        cmd = { "SnipRun", "SnipInfo", "SnipReset", "SnipClose", "SnipLive", "SnipReplMemoryClean" },
        dependencies = { "folke/which-key.nvim" },

        -- which-key v3: declare the group here (never inside `keys`)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>x", group = "Run/REPL (SnipRun)" } })
            end
        end,

        keys = function()
            local function run_buffer()
                local view = vim.fn.winsaveview()
                vim.cmd(":%SnipRun")
                vim.fn.winrestview(view)
            end
            return {
                -- Run
                { "<leader>xr", "<Plug>SnipRun",                mode = { "n", "x" }, desc = "Run line/selection",         remap = true, silent = true },
                { "<leader>xo", "<Plug>SnipRunOperator",        mode = "n",          desc = "Run with motion (operator)", remap = true, silent = true },
                { "<leader>xR", run_buffer,                     mode = "n",          desc = "Run entire file (%)",        silent = true },

                -- Info / control
                { "<leader>xi", "<cmd>SnipInfo<CR>",            mode = "n",          desc = "SnipInfo (current ft)",      silent = true },
                { "<leader>xs", "<cmd>SnipReset<CR>",           mode = "n",          desc = "Stop/Reset runners",         silent = true },
                { "<leader>xc", "<cmd>SnipClose<CR>",           mode = "n",          desc = "Close SnipRun windows",      silent = true },

                -- Live mode toggle (we enable the feature below)
                { "<leader>xl", "<cmd>SnipLive<CR>",            mode = "n",          desc = "Toggle Live mode",           silent = true },
                { "<leader>xm", "<cmd>SnipReplMemoryClean<CR>", mode = "n",          desc = "Clean REPL memory",          silent = true },
            }
        end,

        opts = function()
            return {
                -- Clean, readable outputs
                display = { "Classic", "VirtualTextOk", "Terminal" },
                -- ⚠️ No explicit width/height: let your global UI sizing (us*/uh*) handle it
                display_options = {
                    terminal_position = "vertical",
                    -- terminal_width / terminal_height intentionally omitted
                },
                ansi_escape = true,
                inline_messages = false,

                -- Live mode can be toggled on demand
                live_mode_toggle = "enable",
                live_display = { "VirtualText" },

                -- Your choice: FIFO Python REPL (no klepto)
                selected_interpreters = { "Python3_fifo" },
                repl_enable = { "Python3_fifo", "Lua_nvim", "JS_TS_Deno" },

                -- Optional: lock FIFO to a venv
                -- interpreter_options = { Python3_fifo = { venv = { ".venv" } } },
            }
        end,

        config = function(_, opts)
            require("sniprun").setup(opts)
            -- which-key: no need to add labels for each key; `desc` in keys[] handles it.
        end,
    },
}
