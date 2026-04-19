return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main", -- "main" branch required for Neovim 0.12 compatibility
        lazy = false,
        build = ":TSUpdate",
        dependencies = {
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
            "folke/which-key.nvim",
        },

        -- which-key v3: declare group(s) here (never inside `keys`)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>S", group = "Treesitter/Surround" } })
            end
        end,

        config = function()
            -- main branch moved bundled queries to runtime/queries/ — add it to rtp
            -- so the 329 bundled query sets are visible to Neovim's treesitter runtime
            local plugin_runtime = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime"
            if vim.uv.fs_stat(plugin_runtime) then
                vim.opt.runtimepath:prepend(plugin_runtime)
            end

            -- Install parsers (async, no-op if already installed)
            require("nvim-treesitter").install({
                -- core langs
                "bash", "c", "cpp", "cmake", "go", "rust", "python", "lua",
                "vim", "vimdoc", "javascript", "typescript", "tsx", "json",
                "yaml", "html", "xml", "dockerfile", "terraform", "hcl",
                "starlark", "query", "dart",
                -- editing QoL
                "markdown", "markdown_inline", "regex",
            })

            -- Start treesitter highlighting for any filetype with an available parser.
            -- Neovim 0.12 does NOT auto-enable this for most filetypes on the main branch.
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    if args.match == "latex" then return end -- vimtex handles latex
                    local lang = vim.treesitter.language.get_lang(args.match)
                    if lang and pcall(vim.treesitter.language.add, lang) then
                        pcall(vim.treesitter.start, args.buf, lang)
                    end
                end,
            })

            -- Treesitter-based indentation
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    if vim.tbl_contains({ "latex" }, args.match) then return end
                    local ok, _ = pcall(function()
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end)
                end,
            })

            -- Textobjects setup (new main-branch API)
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
                move = { set_jumps = true },
            })

            local ts_select = require("nvim-treesitter-textobjects.select")
            local ts_move   = require("nvim-treesitter-textobjects.move")
            local ts_swap   = require("nvim-treesitter-textobjects.swap")

            -- Select textobjects
            vim.keymap.set({ "x", "o" }, "af", function() ts_select.select_textobject("@function.outer", "textobjects") end)
            vim.keymap.set({ "x", "o" }, "if", function() ts_select.select_textobject("@function.inner", "textobjects") end)
            vim.keymap.set({ "x", "o" }, "ac", function() ts_select.select_textobject("@class.outer", "textobjects") end)
            vim.keymap.set({ "x", "o" }, "ic", function() ts_select.select_textobject("@class.inner", "textobjects") end)
            vim.keymap.set({ "x", "o" }, "ap", function() ts_select.select_textobject("@parameter.outer", "textobjects") end)
            vim.keymap.set({ "x", "o" }, "ip", function() ts_select.select_textobject("@parameter.inner", "textobjects") end)

            -- Move between textobjects
            vim.keymap.set({ "n", "x", "o" }, "]f", function() ts_move.goto_next_start("@function.outer", "textobjects") end)
            vim.keymap.set({ "n", "x", "o" }, "]c", function() ts_move.goto_next_start("@class.outer", "textobjects") end)
            vim.keymap.set({ "n", "x", "o" }, "[f", function() ts_move.goto_previous_start("@function.outer", "textobjects") end)
            vim.keymap.set({ "n", "x", "o" }, "[c", function() ts_move.goto_previous_start("@class.outer", "textobjects") end)

            -- Swap parameters
            vim.keymap.set("n", "<leader>Sa", function() ts_swap.swap_next("@parameter.inner") end, { desc = "Swap parameter → next" })
            vim.keymap.set("n", "<leader>SA", function() ts_swap.swap_previous("@parameter.inner") end, { desc = "Swap parameter → prev" })

            -- Incremental selection (Neovim 0.12 built-in)
            vim.keymap.set("n", "gnn", function() vim.treesitter.node_at(vim.fn.getpos('.')) end, { desc = "TS: init selection" })

            -- Which-Key docs
            local ok, wk = pcall(require, "which-key")
            if not ok then return end

            wk.add({
                { "a",  group = "Around Textobj",  mode = { "o", "x" } },
                { "af", desc = "Around function",  mode = { "o", "x" } },
                { "ac", desc = "Around class",     mode = { "o", "x" } },
                { "ap", desc = "Around parameter", mode = { "o", "x" } },
                { "i",  group = "Inside Textobj",  mode = { "o", "x" } },
                { "if", desc = "Inside function",  mode = { "o", "x" } },
                { "ic", desc = "Inside class",     mode = { "o", "x" } },
                { "ip", desc = "Inside parameter", mode = { "o", "x" } },
            })

            wk.add({
                { "]",  group = "Next object",        mode = { "n", "x", "o" } },
                { "[",  group = "Prev object",        mode = { "n", "x", "o" } },
                { "]f", desc = "Next function start", mode = { "n", "x", "o" } },
                { "]c", desc = "Next class start",    mode = { "n", "x", "o" } },
                { "[f", desc = "Prev function start", mode = { "n", "x", "o" } },
                { "[c", desc = "Prev class start",    mode = { "n", "x", "o" } },
            })

            wk.add({
                { "<leader>Sa", desc = "Swap parameter → next" },
                { "<leader>SA", desc = "Swap parameter → prev" },
            })
        end,
    },

    -- Treesitter inspection (built-in in Neovim 0.12)
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "folke/which-key.nvim" },
        keys = {
            { "<leader>Sp", "<cmd>InspectTree<CR>", desc = "Inspect Tree (playground)",  mode = "n", silent = true, noremap = true },
            { "<leader>Sc", "<cmd>Inspect<CR>",     desc = "Inspect highlights at cursor", mode = "n", silent = true, noremap = true },
        },
    },

    -- Helm syntax (Tree-sitter doesn't ship an official 'helm' parser)
    {
        "towolf/vim-helm",
        ft = { "helm", "yaml" },
    },
}
