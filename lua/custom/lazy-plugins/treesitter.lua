return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
            'folke/which-key.nvim',
        },
        opts = {
            ensure_installed = {
                "rust",
                "go",
                "c",
                "cpp",
                "python",
                "json",
                "yaml",
                "dart",
                "javascript",
                "lua",
                "vimdoc",
                "typescript",
                "vim",
                "query",
                "terraform",
                "dockerfile",
                "bash",
                "cmake",
                "helm",
                "html",
                "xml",
                "hcl",
                "starlark",
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = true,
            },
            playground = {
                enable = true,
                updatetime = 25,
                persist_queries = false,
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ['af'] = '@function.outer',
                        ['if'] = '@function.inner',
                        ['ac'] = '@class.outer',
                        ['ic'] = '@class.inner',
                        ['ap'] = '@parameter.outer',
                        ['ip'] = '@parameter.inner',
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        [']f'] = '@function.outer',
                        [']c'] = '@class.outer',
                    },
                    goto_previous_start = {
                        ['[f'] = '@function.outer',
                        ['[c'] = '@class.outer',
                    },
                },
                swap = {
                    enable        = true,
                    swap_next     = { ['<leader>ta'] = '@parameter.inner' },
                    swap_previous = { ['<leader>tA'] = '@parameter.inner' },
                },
            },
        },
        config = function(_, opts)
            require('nvim-treesitter.configs').setup(opts)

            local ok, which_key = pcall(require, 'which-key')
            if not ok then return end

            -- operator-pending & visual mode: text-object selections
            which_key.register({
                a = {
                    name = "Around Textobj",
                    f = "Function",
                    c = "Class",
                    p = "Parameter",
                },
            }, { mode = { 'o', 'x' }, prefix = 'a' })

            which_key.register({
                i = {
                    name = "Inside Textobj",
                    f = "Function",
                    c = "Class",
                    p = "Parameter",
                },
            }, { mode = { 'o', 'x' }, prefix = 'i' })

            -- normal mode: moves between functions/classes
            which_key.register({
                f = "Next Function Start",
                c = "Next Class Start",
            }, { mode = 'n', prefix = ']' })

            which_key.register({
                f = "Prev Function Start",
                c = "Prev Class Start",
            }, { mode = 'n', prefix = '[' })

            -- normal mode: swap parameters
            which_key.register({
                ta = "Swap Next Parameter",
                tA = "Swap Prev Parameter",
            }, { mode = 'n', prefix = '<leader>' })
        end,
    },

    {
        'nvim-treesitter/playground',
        cmd = {
            'TSHighlightCapturesUnderCursor', -- show which highlight groups apply under the cursor
            'TSPlaygroundToggle',             -- open/close the interactive Tree-sitter playground
        },
        dependencies = { 'folke/which-key.nvim' },
        config = function()
            -- no setup() needed—Playground works out of the box

            -- Which-Key menu under <leader>t (Treesitter)
            local ok, which_key = pcall(require, 'which-key')
            if not ok then return end

            which_key.register({
                t = {
                    name = "Terminal/Telescope/Twilight/Treesitter",
                    p = { "<cmd>TSPlaygroundToggle<CR>", "Toggle Playground" },
                    c = { "<cmd>TSHighlightCapturesUnderCursor<CR>", "Highlight Captures" },
                },
            }, { prefix = "<leader>" })
        end,
    },

    {
        'towolf/vim-helm',
        ft = { 'helm', 'yaml' },
    },
}
