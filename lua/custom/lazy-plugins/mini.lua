return {
    {
        "nvim-mini/mini.pick",
        version = false,
        dependencies = {
            "folke/which-key.nvim",
            -- Optional, but gives you nice path/file icons in pickers:
            { "nvim-mini/mini.icons", version = false, optional = true },
        },

        -- Show groups early in which-key
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>M", group = "Mini Pick" },
                })
            end
        end,

        -- Keymaps (lazy-load on first press)
        keys = function()
            return {
                -- Files
                { "<leader>Mf", function() require("my_pick").files_smart() end,         desc = "Files (smart: git/fd/rg)" },
                { "<leader>MF", function() require("my_pick").files_git() end,           desc = "Files (git tracked)" },

                -- Grep
                { "<leader>Mg", function() require("mini.pick").builtin.grep_live() end, desc = "Live grep (rg/git)" },
                { "<leader>MG", function() require("my_pick").grep_prompt() end,         desc = "Grep (prompt)" },
                { "<leader>Mw", function() require("my_pick").grep_word() end,           desc = "Grep word under cursor" },

                -- Misc
                { "<leader>Mb", function() require("mini.pick").builtin.buffers() end,   desc = "Buffers" },
                { "<leader>Mh", function() require("mini.pick").builtin.help() end,      desc = "Help tags" },
                { "<leader>Mr", function() require("mini.pick").builtin.resume() end,    desc = "Resume last picker" },

                -- Extras (auto-detects mini.extra)
                { "<leader>Mo", function() require("my_pick").oldfiles() end,            desc = "Recent files (mini.extra)" },
            }
        end,

        config = function()
            local Pick = require("mini.pick")

            -- Minimal setup (keeps defaults fast & non-blocking; ui.select is set to mini.pick)
            Pick.setup()

            -- Try icons if available (no-op if plugin not installed)
            pcall(function() require("mini.icons").setup() end)

            -- Helpers behind keymaps
            local M = {}

            local function in_git_repo()
                local ok = (vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] or "") == "true"
                return ok
            end

            function M.files_smart()
                local local_opts = {}
                if in_git_repo() then local_opts.tool = "git" end -- prefer tracked files when possible
                Pick.builtin.files(local_opts)
            end

            function M.files_git()
                Pick.builtin.files({ tool = "git" })
            end

            function M.grep_prompt()
                -- Will prompt for a pattern if none is provided
                Pick.builtin.grep({})
            end

            function M.grep_word()
                local word = vim.fn.expand("<cword>")
                if word == nil or word == "" then
                    Pick.builtin.grep({})
                else
                    Pick.builtin.grep({ pattern = word })
                end
            end

            function M.oldfiles()
                local ok, Extra = pcall(require, "mini.extra")
                if not ok then
                    vim.notify("mini.extra not installed (oldfiles picker unavailable)", vim.log.levels.WARN)
                    return
                end
                Extra.pickers.oldfiles()
            end

            package.loaded["my_pick"] = M
        end,
    },
}
