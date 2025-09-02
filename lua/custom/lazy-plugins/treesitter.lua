return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "folke/which-key.nvim",
        },
        opts = {
            ensure_installed = {
                -- core langs
                "bash", "c", "cpp", "cmake", "go", "rust", "python", "lua", "vim", "vimdoc",
                "javascript", "typescript", "tsx", "json", "yaml", "html", "xml", "dockerfile",
                "terraform", "hcl", "starlark", "query", "dart",
                -- editing QoL
                "markdown", "markdown_inline",
            },
            auto_install = true, -- install missing parsers when entering buffer
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
            -- Treesitter Playground is configured via its own plugin below
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- jump forward to nearest textobj
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
                    enable        = true,
                    -- use <leader>S… (capital S group) to stay clear of Telescope (<leader>t…)
                    swap_next     = { ["<leader>Sa"] = "@parameter.inner" },
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

            -- Which-Key docs (no new leader conflicts)
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
                { "<leader>S", group = "Treesitter" },
                { "<leader>Sa", desc = "Swap parameter → next" },
                { "<leader>SA", desc = "Swap parameter → prev" },
                { "gnn", desc = "TS: init selection", mode = "n" },
                { "grn", desc = "TS: grow node", mode = "n" },
                { "grm", desc = "TS: shrink node", mode = "n" },
                { "grc", desc = "TS: grow scope", mode = "n" },
            })
        end,
    },

    -- Treesitter Playground (separate plugin)
    {
        "nvim-treesitter/playground",
        cmd = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" },
        dependencies = { "folke/which-key.nvim" },
        config = function()
            -- Keymaps under <leader>S to avoid Telescope (<leader>t…)
            local function safe_map(lhs, rhs, desc)
                if vim.fn.maparg(lhs, "n") == "" then
                    vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
                end
            end
            safe_map("<leader>Sp", "<cmd>TSPlaygroundToggle<CR>", "Playground toggle")
            safe_map("<leader>Sc", "<cmd>TSHighlightCapturesUnderCursor<CR>", "Highlight captures")

            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    -- { "<leader>S",  group = "Treesitter" },
                    { "<leader>Sp", desc = "Playground toggle" },
                    { "<leader>Sc", desc = "Highlight captures" },
                })
            end
        end,
    },

    -- Helm syntax (Tree-sitter doesn't ship an official 'helm' parser)
    {
        "towolf/vim-helm",
        ft = { "helm", "yaml" },
    },
}
