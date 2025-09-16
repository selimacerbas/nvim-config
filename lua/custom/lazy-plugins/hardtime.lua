return {
    {
        "m4xshen/hardtime.nvim",
        lazy = false, -- enable from startup as recommended
        dependencies = {
            "MunifTanjim/nui.nvim",
            -- we’ll register key labels if which-key is present
            { "folke/which-key.nvim", optional = true },
        },
        opts = {
            -- keep defaults where sensible; tweak a few edges for a smoother start
            max_time = 1000,           -- ms window to consider repeats
            max_count = 3,             -- allow up to 3 repeats before acting
            restriction_mode = "hint", -- start by *hinting* instead of blocking
            hint = true,
            notification = true,
            disable_mouse = false, -- don't be too strict on mouse at first
            allow_different_key = true,
            enabled = true,        -- on by default
            -- reduce friction in UI panes & special buffers
            disabled_filetypes = {
                help = true,
                qf = true,
                lazy = true,
                mason = true,
                ["dapui*"] = true,
                ["dap-repl"] = true,
                TelescopePrompt = true,
                NvimTree = true,
                neotree = true,
                aerial = true,
                toggleterm = true,
                alpha = true,
                starter = true,
            },
            -- let arrow keys exist (hardtime disables some by default; set to false to
            -- remove them from the default disabled list)
            disabled_keys = {
                ["<Up>"] = false,
                ["<Down>"] = false,
                ["<Left>"] = false,
                ["<Right>"] = false,
            },
            -- use Neovim’s notify; if you use nvim-notify, we’ll auto-route to it below
            callback = function(msg)
                local ok, notify = pcall(require, "notify")
                if ok then notify(msg) else vim.notify(msg) end
            end,
            ui = {
                border = "rounded",
                width = 60,
                row = 0.15,
            },
        },
        config = function(_, opts)
            -- If you want hints to also show in INSERT/Visual, disable 'showmode'
            -- (lualine/other statuslines already show mode)  — see README.  :contentReference[oaicite:1]{index=1}
            vim.opt.showmode = false

            require("hardtime").setup(opts)

            -- ── Keymaps (with which-key v3 if available, else plain keymaps) ─────────
            local maps = {
                { "<leader>H",  group = "Hardtime" },
                { "<leader>Ht", "<cmd>Hardtime toggle<CR>",  desc = "Toggle Hardtime" },
                { "<leader>He", "<cmd>Hardtime enable<CR>",  desc = "Enable Hardtime" },
                { "<leader>Hd", "<cmd>Hardtime disable<CR>", desc = "Disable Hardtime" },
                { "<leader>Hr", "<cmd>Hardtime report<CR>",  desc = "Show habits report" },
                {
                    "<leader>Hs",
                    function()
                        vim.cmd("Hardtime disable")
                        vim.notify("Hardtime snoozed for 10s")
                        vim.defer_fn(function() vim.cmd("Hardtime enable") end, 10000)
                    end,
                    desc = "Snooze Hardtime (10s)",
                },
                {
                    "<leader>Hl",
                    function()
                        local log = vim.fn.stdpath("state") .. "/hardtime.nvim.log"
                        vim.cmd("vsplit " .. vim.fn.fnameescape(log))
                    end,
                    desc = "Open Hardtime log",
                },
            }

            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add(maps) -- which-key v3 API
            else
                -- fallback: regular keymaps still show in which-key via desc
                local map = vim.keymap.set
                for _, m in ipairs(maps) do
                    local lhs, rhs, desc = m[1], m[2], m.desc
                    if type(rhs) == "string" or type(rhs) == "function" then
                        map("n", lhs, rhs, { silent = true, noremap = true, desc = desc })
                    end
                end
            end
        end,
    },
}
