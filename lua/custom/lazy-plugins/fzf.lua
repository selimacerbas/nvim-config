return {
    {
        "ibhagwan/fzf-lua",
        -- optional icons (pick one you use elsewhere)
        dependencies = {
            "folke/which-key.nvim",
            -- "nvim-tree/nvim-web-devicons",
            -- OR if you already use mini.icons:
            -- "nvim-mini/mini.icons",
        },

        -- which-key groups first, so they show before load
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>F",  group = "FZF" },
                    { "<leader>Fs", group = "Search" },
                    { "<leader>Fg", group = "Git" },
                    { "<leader>Fl", group = "LSP" },
                })
            end
        end,

        -- keys: pressing any will lazy-load fzf-lua
        keys = function()
            local map = function(lhs, rhs, desc) return { lhs, rhs, desc = desc } end
            return {
                -- Files / Buffers / History
                map("<leader>Ff", function() require("fzf-lua").files() end, "Files"),
                map("<leader>FF", function() require("fzf-lua").git_files() end, "Git files"),
                map("<leader>Fb", function() require("fzf-lua").buffers() end, "Buffers"),
                map("<leader>Fo", function() require("fzf-lua").oldfiles() end, "Recent files"),
                map("<leader>F/", function() require("fzf-lua").blines() end, "Lines (current buffer)"),
                map("<leader>F?", function() require("fzf-lua").lines() end, "Lines (all buffers)"),
                map("<leader>Fr", function() require("fzf-lua").resume() end, "Resume last picker"),

                -- Search (Fs…)
                map("<leader>Fsg", function() require("fzf-lua").live_grep_native() end, "Live grep (native)"),
                map("<leader>Fsp", function() require("fzf-lua").grep_project() end, "Grep project (Rg style)"),
                map("<leader>Fsw", function() require("fzf-lua").grep_cword() end, "Grep word under cursor"),
                map("<leader>Fsl", function() require("fzf-lua").lgrep_curbuf() end, "Live grep current buffer"),

                -- Git (Fg…)
                map("<leader>Fgs", function() require("fzf-lua").git_status() end, "Git status"),
                map("<leader>Fgc", function() require("fzf-lua").git_commits() end, "Git commits (project)"),
                map("<leader>FgC", function() require("fzf-lua").git_bcommits() end, "Git commits (buffer)"),
                map("<leader>Fgf", function() require("fzf-lua").git_files() end, "Git files"),
                map("<leader>Fgh", function() require("fzf-lua").git_hunks() end, "Git hunks"),
                map("<leader>FgB", function() require("fzf-lua").git_branches() end, "Git branches"),

                -- LSP (Fl…)
                map("<leader>Flr", function() require("fzf-lua").lsp_references() end, "LSP references"),
                map("<leader>Fld", function() require("fzf-lua").lsp_definitions() end, "LSP definitions"),
                map("<leader>Fli", function() require("fzf-lua").lsp_implementations() end, "LSP implementations"),
                map("<leader>Fls", function() require("fzf-lua").lsp_document_symbols() end, "Symbols (document)"),
                map("<leader>FlS", function() require("fzf-lua").lsp_workspace_symbols() end, "Symbols (workspace)"),
                map("<leader>Fle", function() require("fzf-lua").diagnostics_document() end, "Diagnostics (document)"),
                map("<leader>FlE", function() require("fzf-lua").diagnostics_workspace() end, "Diagnostics (workspace)"),

                -- Misc goodies
                map("<leader>Fh", function() require("fzf-lua").helptags() end, "Help tags"),
                map("<leader>Fk", function() require("fzf-lua").keymaps() end, "Keymaps"),
                map("<leader>Fc", function() require("fzf-lua").commands() end, "Commands"),
                map("<leader>FG", function() require("fzf-lua").global() end, "Global (files/$buffers/@/#symbols)"),
            }
        end,

        opts = function()
            -- Keep mini.pick as your ui.select provider; do NOT register fzf-lua for ui.select.
            -- Pick a profile for better previews; combine with "hide" for nice <Esc> behavior.
            return {
                { "fzf-native", "hide" }, -- profiles: native preview + hide-on-Esc
                fzf_colors = true, -- auto-derive colors from your colorscheme
                winopts = {
                    border = "rounded",
                    width = 0.80,
                    height = 0.85,
                    row = 0.35,
                    col = 0.50,
                    backdrop = 60,
                    preview = { default = "builtin" }, -- auto-uses bat if present in fzf-native
                },
                -- You can tweak per-picker settings here if you like, e.g.:
                -- files = { fd_opts = "--hidden --strip-cwd-prefix" },
            }
        end,
    },
}
