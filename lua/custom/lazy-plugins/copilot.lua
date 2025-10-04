return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        dependencies = { "folke/which-key.nvim" },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>c",  group = "Copilot" },
                    { "<leader>cp", group = "Panel" },
                    { "<leader>cs", group = "Suggest" },
                    { "<leader>cA", group = "Auth" },
                    { "<leader>cC", group = "Completion (Copilot-cmp)" }, -- NEW group
                })
            end
            -- default: keep copilot-cmp off until you enable it
            if vim.g.copilot_cmp_enabled == nil then
                vim.g.copilot_cmp_enabled = false
            end
        end,

        keys = function()
            return {
                -- Suggestion controls
                { "<leader>csn", function() require("copilot.suggestion").next() end,                desc = "Next suggestion" },
                { "<leader>csp", function() require("copilot.suggestion").prev() end,                desc = "Prev suggestion" },
                { "<leader>csd", function() require("copilot.suggestion").dismiss() end,             desc = "Dismiss suggestion" },
                { "<leader>csa", function() require("copilot.suggestion").toggle_auto_trigger() end, desc = "Toggle auto-trigger (buf)" },

                -- Panel
                { "<leader>cpt", function() require("copilot.panel").toggle() end,                   desc = "Panel toggle" },
                { "<leader>cpr", function() require("copilot.panel").refresh() end,                  desc = "Panel refresh" },

                -- Auth / status
                { "<leader>cAs", "<cmd>Copilot status<cr>",                                          desc = "Status" },
                { "<leader>cAl", "<cmd>Copilot auth<cr>",                                            desc = "Authenticate" },

                -- NEW: copilot-cmp switchers (runtime, no restart needed)
                { "<leader>cCe", function() require("my_copilot_cmp").enable() end,                  desc = "CMP: Enable copilot source" },
                { "<leader>cCd", function() require("my_copilot_cmp").disable() end,                 desc = "CMP: Disable copilot source" },
                { "<leader>cCt", function() require("my_copilot_cmp").toggle() end,                  desc = "CMP: Toggle copilot source" },
                { "<leader>cCs", function() require("my_copilot_cmp").status() end,                  desc = "CMP: Status" },
            }
        end,

        opts = {
            panel = {
                enabled = true,
                auto_refresh = false,
                keymap = { jump_prev = "[[", jump_next = "]]", accept = "<CR>", refresh = "gr", open = "<M-CR>" },
                layout = { position = "bottom", ratio = 0.35 },
            },
            suggestion = {
                enabled = true,
                auto_trigger = false,
                hide_during_completion = true,
                debounce = 75,
                trigger_on_accept = true,
                keymap = {
                    accept = "<M-l>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            should_attach = function(_, bufname)
                if string.match(vim.fs.basename(bufname or ""), '^%.env') then return false end
                return vim.bo.buflisted and vim.bo.buftype == ""
            end,
            copilot_node_command = "node",
            filetypes = { TelescopePrompt = false, ["*"] = true },
        },

        config = function(_, opts)
            require("copilot").setup(opts)

            -- Hide inline ghost text while nvim-cmp menu is open (if you use cmp)
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
                -- If copilot-cmp isn't loaded yet, lazy-load it and set up once.
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
                    vim.notify("nvim-cmp not available; cannot toggle copilot-cmp", vim.log.levels.WARN)
                    return
                end
                if enabled then
                    -- make sure the plugin is present
                    if not ensure_copilot_cmp_loaded() then
                        vim.notify("copilot-cmp not installed/loaded", vim.log.levels.ERROR)
                        return
                    end
                end

                local cfg = cmp.get_config()
                local sources = vim.deepcopy(cfg.sources or {})
                local idx
                for i, src in ipairs(sources) do
                    if src.name == "copilot" then
                        idx = i
                        break
                    end
                end

                if enabled and not idx then
                    table.insert(sources, 1, { name = "copilot", group_index = 2 })
                elseif not enabled and idx then
                    table.remove(sources, idx)
                end
                cmp.setup({ sources = sources })
                vim.g.copilot_cmp_enabled = enabled and true or false
                vim.notify("Copilot CMP: " .. (enabled and "ENABLED" or "DISABLED"))
            end

            function M.enable() set_enabled(true) end

            function M.disable() set_enabled(false) end

            function M.toggle() set_enabled(not vim.g.copilot_cmp_enabled) end

            function M.status()
                vim.notify("Copilot CMP is " .. ((vim.g.copilot_cmp_enabled and "ENABLED") or "DISABLED"))
            end

            -- apply default on startup
            M.toggle() -- toggles to the opposite; we want to *apply* current state, not flip.
            -- Fix: apply without flipping
            if vim.g.copilot_cmp_enabled then M.enable() else M.disable() end

            package.loaded["my_copilot_cmp"] = M
        end,
    },

    -- Keep this plugin present; it will only affect cmp when you enable it via the switch.
    {
        "zbirenbaum/copilot-cmp",
        event = "InsertEnter",
        dependencies = { "zbirenbaum/copilot.lua", "hrsh7th/nvim-cmp" },
        config = function()
            -- Safe to call repeatedly; our switch will add/remove the source from cmp.
            local ok, copilot_cmp = pcall(require, "copilot_cmp")
            if ok then copilot_cmp.setup() end
        end,
    },
}
