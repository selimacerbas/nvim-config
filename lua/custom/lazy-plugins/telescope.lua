return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "folke/which-key.nvim",
        },
        config = function()
            -- Telescope setup
            require("telescope").setup {
                defaults = {
                    prompt_prefix   = " ",
                    selection_caret = " ",
                    path_display    = { "smart" },
                    layout_strategy = "horizontal",
                    layout_config   = {
                        prompt_position = "top",
                        preview_width   = 0.55,
                        results_width   = 0.8,
                    },
                    mappings        = {
                        i = {
                            ["<C-j>"] = require("telescope.actions").move_selection_next,
                            ["<C-k>"] = require("telescope.actions").move_selection_previous,
                            ["<C-c>"] = require("telescope.actions").close,
                        },
                        n = {
                            ["q"] = require("telescope.actions").close,
                        },
                    },
                },
                pickers = {
                    find_files  = { hidden = true },
                    live_grep   = {},
                    grep_string = {},
                    buffers     = {},
                    oldfiles    = {},
                    keymaps     = {},
                },
                extensions = {
                    -- e.g. fzf-native
                },
            }

            -- Which-key mappings for Telescope under <leader>t
            local wk_ok, which_key = pcall(require, "which-key")
            if not wk_ok then
                return
            end

            which_key.register({
                t = {
                    name = "Terminal/Telescope/Twilight/Treesitter",
                    f = { "<cmd>Telescope find_files<CR>", "Find Files" },
                    g = { "<cmd>Telescope live_grep<CR>", "Live Grep" },
                    s = { "<cmd>Telescope grep_string<CR>", "Grep String" },
                    b = { "<cmd>Telescope buffers<CR>", "Buffers" },
                    o = { "<cmd>Telescope oldfiles<CR>", "Old Files" },
                    k = { "<cmd>Telescope keymaps<CR>", "Keymaps" },
                    c = { "<cmd>Telescope commands<CR>", "Commands" },
                },
            }, {
                prefix = "<leader>",
            })
        end,
    },
}
