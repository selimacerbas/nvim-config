return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        dependencies = { "folke/which-key.nvim" },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({
                    { "<leader>c", group = "Copilot" },
                })
            end
            -- default: keep copilot-cmp off until you enable it
            if vim.g.copilot_cmp_enabled == nil then
                vim.g.copilot_cmp_enabled = false
            end
        end,

        keys = {
            -- Suggestion controls (2-step keys)
            { "<leader>cn", function() require("copilot.suggestion").next() end,                desc = "Next suggestion" },
            { "<leader>cp", function() require("copilot.suggestion").prev() end,                desc = "Prev suggestion" },
            { "<leader>cd", function() require("copilot.suggestion").dismiss() end,             desc = "Dismiss" },
            { "<leader>ca", function() require("copilot.suggestion").toggle_auto_trigger() end, desc = "Auto-trigger toggle" },

            -- Panel (2-step keys)
            { "<leader>ct", function() require("copilot.panel").toggle() end,  desc = "Panel toggle" },
            { "<leader>cr", function() require("copilot.panel").refresh() end, desc = "Panel refresh" },

            -- Auth / status (2-step keys)
            { "<leader>cs", "<cmd>Copilot status<cr>", desc = "Status" },
            { "<leader>cA", "<cmd>Copilot auth<cr>",   desc = "Authenticate" },

            -- CMP integration (capital letters to avoid conflicts)
            { "<leader>ce", function() require("my_copilot_cmp").enable() end,  desc = "CMP enable" },
            { "<leader>cD", function() require("my_copilot_cmp").disable() end, desc = "CMP disable" },
            { "<leader>cT", function() require("my_copilot_cmp").toggle() end,  desc = "CMP toggle" },
            { "<leader>cS", function() require("my_copilot_cmp").status() end,  desc = "CMP status" },
        },

        opts = {
            panel = {
                enabled = true,
                auto_refresh = false,
                keymap = {
                    jump_prev = "[[",
                    jump_next = "]]",
                    accept = "<CR>",
                    refresh = "gr",
                    open = "<M-CR>",
                },
                layout = { position = "bottom", ratio = 0.4 },
            },
            suggestion = {
                enabled = true,
                auto_trigger = false,
                hide_during_completion = true,
                debounce = 75,
                trigger_on_accept = true,
                keymap = {
                    accept = "<M-l>",
                    accept_word = "<M-k>",  -- accept word-by-word
                    accept_line = "<M-j>",  -- accept line-by-line
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            filetypes = {
                ["*"] = true,
                TelescopePrompt = false,
                DressingInput = false,
                ["neo-tree-popup"] = false,
            },
            should_attach = function(_, bufname)
                -- Don't attach to .env files
                if string.match(vim.fs.basename(bufname or ""), "^%.env") then return false end
                return vim.bo.buflisted and vim.bo.buftype == ""
            end,
            copilot_node_command = "node",
        },

        config = function(_, opts)
            require("copilot").setup(opts)

            -- Hide inline ghost text while nvim-cmp menu is open
            pcall(function()
                local cmp = require("cmp")
                cmp.event:on("menu_opened", function() vim.b.copilot_suggestion_hidden = true end)
                cmp.event:on("menu_closed", function() vim.b.copilot_suggestion_hidden = false end)
            end)

            --------------------------------------------------------------------------
            -- Runtime copilot-cmp switch (add/remove "copilot" source in nvim-cmp)
            --------------------------------------------------------------------------
            local M = {}

            local function ensure_copilot_cmp_loaded()
                if package.loaded["copilot_cmp"] then return true end
                local ok_lazy, lazy = pcall(require, "lazy")
                if ok_lazy then pcall(lazy.load, { plugins = { "copilot-cmp" } }) end
                local ok = pcall(require, "copilot_cmp")
                if ok then pcall(function() require("copilot_cmp").setup() end) end
                return ok
            end

            local function set_enabled(enabled)
                local ok_cmp, cmp = pcall(require, "cmp")
                if not ok_cmp then
                    vim.notify("nvim-cmp not available", vim.log.levels.WARN)
                    return
                end
                if enabled and not ensure_copilot_cmp_loaded() then
                    vim.notify("copilot-cmp not installed/loaded", vim.log.levels.ERROR)
                    return
                end

                local cfg = cmp.get_config()
                local sources = vim.deepcopy(cfg.sources or {})
                local idx
                for i, src in ipairs(sources) do
                    if src.name == "copilot" then idx = i; break end
                end

                if enabled and not idx then
                    table.insert(sources, 1, { name = "copilot", group_index = 2 })
                elseif not enabled and idx then
                    table.remove(sources, idx)
                end
                cmp.setup({ sources = sources })
                vim.g.copilot_cmp_enabled = enabled
                vim.notify("Copilot CMP: " .. (enabled and "ON" or "OFF"))
            end

            function M.enable() set_enabled(true) end
            function M.disable() set_enabled(false) end
            function M.toggle() set_enabled(not vim.g.copilot_cmp_enabled) end
            function M.status()
                vim.notify("Copilot CMP: " .. (vim.g.copilot_cmp_enabled and "ON" or "OFF"))
            end

            -- Apply initial state (off by default)
            set_enabled(vim.g.copilot_cmp_enabled)

            package.loaded["my_copilot_cmp"] = M
        end,
    },

    -- copilot-cmp: provides completion source
    {
        "zbirenbaum/copilot-cmp",
        event = "InsertEnter",
        dependencies = { "zbirenbaum/copilot.lua", "hrsh7th/nvim-cmp" },
        config = function()
            local ok, copilot_cmp = pcall(require, "copilot_cmp")
            if ok then copilot_cmp.setup() end
        end,
    },
}
