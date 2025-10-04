return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "folke/which-key.nvim",
        },

        -- which-key v3: declare group(s) here (never inside `keys`)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>S", group = "Treesitter/Surround" } })
            end
        end,

        opts = {
            ensure_installed = {
                -- core langs
                "bash", "c", "cpp", "cmake", "go", "rust", "python", "lua",
                "vim", "vimdoc", "javascript", "typescript", "tsx", "json",
                "yaml", "html", "xml", "dockerfile", "terraform", "hcl",
                "starlark", "query", "dart",
                -- editing QoL
                "markdown", "markdown_inline",
            },
            auto_install = true,
            highlight = { enable = true, additional_vim_regex_highlighting = false },
            indent = { enable = true },

            -- enable the playground module here
            playground = { enable = true },

            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        ["ap"] = "@parameter.outer",
                        ["ip"] = "@parameter.inner",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]f"] = "@function.outer",
                        ["]c"] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[f"] = "@function.outer",
                        ["[c"] = "@class.outer",
                    },
                },
                swap = {
                    enable = true,
                    swap_next = { ["<leader>Sa"] = "@parameter.inner" },
                    swap_previous = { ["<leader>SA"] = "@parameter.inner" },
                },
            },

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "gnn",
                    node_incremental = "grn",
                    scope_incremental = "grc",
                    node_decremental = "grm",
                },
            },
        },

        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)

            -- Which-Key docs (non-leader + leader helpers)
            local ok, wk = pcall(require, "which-key")
            if not ok then return end

            -- Operator/visual textobjects
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

            -- Motions between objects
            wk.add({
                { "]",  group = "Next object",        mode = "n" },
                { "[",  group = "Prev object",        mode = "n" },
                { "]f", desc = "Next function start", mode = "n" },
                { "]c", desc = "Next class start",    mode = "n" },
                { "[f", desc = "Prev function start", mode = "n" },
                { "[c", desc = "Prev class start",    mode = "n" },
            })

            -- Swaps + incremental selection under <leader>S
            wk.add({
                { "<leader>Sa", desc = "Swap parameter → next" },
                { "<leader>SA", desc = "Swap parameter → prev" },
                { "gnn", desc = "TS: init selection", mode = "n" },
                { "grn", desc = "TS: grow node", mode = "n" },
                { "grm", desc = "TS: shrink node", mode = "n" },
                { "grc", desc = "TS: grow scope", mode = "n" },
            })
        end,
    },

    -- Treesitter Playground (map real keys so Lazy loads on press)
    {
        "nvim-treesitter/playground",
        cmd = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" },
        dependencies = { "folke/which-key.nvim" },

        -- v3 which-key group in init
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>S", group = "Treesitter/Surround" } })
            end
        end,

        keys = {
            { "<leader>Sp", "<cmd>TSPlaygroundToggle<CR>",             desc = "Playground toggle",  mode = "n", silent = true, noremap = true },
            { "<leader>Sc", "<cmd>TSHighlightCapturesUnderCursor<CR>", desc = "Highlight captures", mode = "n", silent = true, noremap = true },
        },
    },

    -- Helm syntax (Tree-sitter doesn't ship an official 'helm' parser)
    {
        "towolf/vim-helm",
        ft = { "helm", "yaml" },
    },
}
