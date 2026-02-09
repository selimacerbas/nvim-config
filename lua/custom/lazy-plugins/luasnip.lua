return {
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "folke/which-key.nvim",
        },
        build = "make install_jsregexp",
        event = "InsertEnter",

        -- which-key group goes here (v3-friendly)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>s", group = "Snippets" } })
            end
        end,

        opts = {
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = false,
        },

        keys = {
            -- Insert/Select: expand & navigate
            {
                "<M-k>",
                function()
                    local ls = require("luasnip")
                    if ls.expand_or_jumpable() then ls.expand_or_jump() end
                end,
                mode = { "i", "s" },
                desc = "Snippet: Expand / Jump",
            },
            {
                "<M-j>",
                function()
                    local ls = require("luasnip")
                    if ls.jumpable(-1) then ls.jump(-1) end
                end,
                mode = { "i", "s" },
                desc = "Snippet: Jump Back",
            },
            {
                "<M-l>",
                function()
                    local ls = require("luasnip")
                    if ls.choice_active() then ls.change_choice(1) end
                end,
                mode = { "i", "s" },
                desc = "Snippet: Next Choice",
            },
            {
                "<M-h>",
                function()
                    local ls = require("luasnip")
                    if ls.choice_active() then ls.change_choice(-1) end
                end,
                mode = { "i", "s" },
                desc = "Snippet: Prev Choice",
            },

            -- Normal-mode helpers under <leader>s
            { "<leader>se", function() require("luasnip").expand() end,         desc = "Snippets: Expand (if available)" },
            { "<leader>su", function() require("luasnip").unlink_current() end, desc = "Snippets: Unlink current" },
        },

        config = function(_, opts)
            local ls = require("luasnip")
            ls.config.set_config(opts)

            -- Community VSCode snippets
            require("luasnip.loaders.from_vscode").lazy_load()

            -- Optional: user Lua snippets at ~/.config/nvim/lua/snippets
            local user_snips = vim.fn.stdpath("config") .. "/lua/snippets"
            if vim.uv.fs_stat(user_snips) then
                require("luasnip.loaders.from_lua").lazy_load({ paths = user_snips })
            end
        end,
    },

    -- friendly-snippets
    {
        "rafamadriz/friendly-snippets",
        event = "InsertEnter",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "folke/which-key.nvim",
        },

        -- Show the group in which-key even before load
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>s",  group = "Snippets" },
                    { "<leader>sl", group = "List / Preview" },
                })
            end
        end,

        -- All leader-key maps live here; pressing any will lazy-load snippets
        keys = function()
            return {
                { "<leader>sr",  function() require("my_snip").reload() end,              desc = "Reload snippets (VSCode/Lua)" },
                { "<leader>sc",  function() require("my_snip").edit_current_ft() end,     desc = "Edit user snippets (current ft)" },
                { "<leader>slc", function() require("my_snip").list_current_ft() end,     desc = "List snippets (current ft)" },
                { "<leader>sla", function() require("my_snip").list_all_ft() end,         desc = "List snippets (all fts)" },
                { "<leader>sa",  function() require("my_snip").toggle_autosnippets() end, desc = "Toggle autosnippets" },
            }
        end,

        config = function()
            local ls = require("luasnip")

            -- Load the VSCode-style snippets (friendly-snippets) lazily
            require("luasnip.loaders.from_vscode").lazy_load()
            -- If you keep local Lua snippets, load them too (no-op if not present)
            pcall(function() require("luasnip.loaders.from_lua").lazy_load() end)

            -- Sensible LuaSnip behaviour
            ls.config.set_config({
                history = true,
                updateevents = "TextChanged,TextChangedI",
                region_check_events = "CursorMoved,CursorHold,InsertEnter",
                delete_check_events = "TextChanged",
                enable_autosnippets = false, -- start quiet; you can toggle with <leader>sa
            })

            -- Helper utils behind the leader keymaps
            local M = {}

            function M.reload()
                require("luasnip.loaders.from_vscode").lazy_load()
                pcall(function() require("luasnip.loaders.from_lua").lazy_load() end)
                vim.notify("Snippets reloaded")
            end

            function M.edit_current_ft()
                local ft = (vim.bo.filetype ~= "" and vim.bo.filetype) or "all"
                -- Opens/creates your user snippets file for this filetype
                vim.cmd(("LuaSnipEdit %s"):format(ft))
            end

            local function list_for_ft(ft)
                local items = {}
                local ok_get, get = pcall(require, "luasnip").get_snippets
                if ok_get then
                    local list = get(ft, { type = "snippets" }) or {}
                    for _, snip in ipairs(list) do
                        local trig = snip.trigger or (snip.name or "?")
                        local name = snip.name and (" — " .. snip.name) or ""
                        table.insert(items, trig .. name)
                    end
                else
                    -- Older LuaSnip fallback
                    local snips = require("luasnip").snippets or {}
                    for _, snip in ipairs(snips[ft] or {}) do
                        local trig = snip.trigger or (snip.name or "?")
                        local name = snip.name and (" — " .. snip.name) or ""
                        table.insert(items, trig .. name)
                    end
                end
                return items
            end

            function M.list_current_ft()
                local ft = vim.bo.filetype
                local items = list_for_ft(ft)
                if #items == 0 then
                    vim.notify(("No snippets loaded for filetype: %s"):format(ft), vim.log.levels.WARN)
                    return
                end
                vim.ui.select(items, { prompt = ("Snippets for %s"):format(ft) }, function(_) end)
            end

            function M.list_all_ft()
                local fts = {}
                local seen = {}
                -- Gather filetypes that actually have loaded snippets
                local ok_get, get = pcall(require, "luasnip").get_snippets
                if ok_get then
                    -- iterate through known filetypes from runtime
                    for _, ft in ipairs(vim.fn.getcompletion("", "filetype")) do
                        local items = list_for_ft(ft)
                        if #items > 0 then
                            table.insert(fts, ("%s  (%d)"):format(ft, #items))
                            seen[ft] = true
                        end
                    end
                else
                    local snips = require("luasnip").snippets or {}
                    for ft, list in pairs(snips) do
                        table.insert(fts, ("%s  (%d)"):format(ft, #list))
                        seen[ft] = true
                    end
                end
                table.sort(fts)
                if #fts == 0 then
                    vim.notify("No snippets loaded.", vim.log.levels.WARN)
                    return
                end
                vim.ui.select(fts, { prompt = "Filetypes with snippets" }, function(choice)
                    if not choice then return end
                    local ft = choice:match("^(%S+)")
                    if ft then
                        local items = list_for_ft(ft)
                        vim.ui.select(items, { prompt = ("Snippets for %s"):format(ft) }, function(_) end)
                    end
                end)
            end

            function M.toggle_autosnippets()
                local cur = ls.config._config.enable_autosnippets
                ls.config.setup({ enable_autosnippets = not cur })
                vim.notify("Autosnippets: " .. ((not cur) and "ON" or "OFF"))
            end

            package.loaded["my_snip"] = M
        end,
    },
}
