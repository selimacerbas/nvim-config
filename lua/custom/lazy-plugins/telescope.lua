return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope", -- lazy-load on :Telescope or the keys below
        dependencies = {
            "nvim-lua/plenary.nvim",
            "folke/which-key.nvim",
            { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
            { "nvim-telescope/telescope-fzf-native.nvim",     build = "make" },
        },

        -- 1) Make the <leader>t group visible as soon as which-key loads
        init = function()
            local ok, wk = pcall(require, "which-key")
            if not ok then return end
            if wk.add then
                wk.add({ { "<leader>t", group = "Telescope" } })                     -- which-key v3
            else
                wk.register({ t = { name = "Telescope" } }, { prefix = "<leader>" }) -- v2
            end
        end,

        -- 2) Real keymaps are created by lazy.nvim (with desc), so they always exist
        keys = {
            { "<leader>tt", function() require("telescope.builtin").builtin() end,                                 desc = "Pickers list" },
            { "<leader>tr", function() require("telescope.builtin").resume() end,                                  desc = "Resume last picker" },
            { "<leader>tf", function() require("telescope.builtin").find_files({ hidden = true }) end,             desc = "Find files" },
            { "<leader>tg", function() require("telescope.builtin").live_grep() end,                               desc = "Live grep" },
            { "<leader>tS", function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor() end, desc = "Grep word (args)" },
            {
                "<leader>t.",
                function()
                    require("telescope").extensions.live_grep_args.live_grep_args({
                        search_dirs = { vim.fn.expand("%:p:h") },
                    })
                end,
                desc = "Live grep (this dir)"
            },
            { "<leader>tG", function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "Live grep (args)" },
            { "<leader>ts", function() require("telescope.builtin").grep_string() end,                      desc = "Grep string" },
            { "<leader>tb", function() require("telescope.builtin").buffers() end,                          desc = "Buffers" },
            { "<leader>to", function() require("telescope.builtin").oldfiles() end,                         desc = "Old files (cwd)" },
            { "<leader>tk", function() require("telescope.builtin").keymaps() end,                          desc = "Keymaps" },
            { "<leader>tc", function() require("telescope.builtin").commands() end,                         desc = "Commands" },
            { "<leader>th", function() require("telescope.builtin").help_tags() end,                        desc = "Help tags" },
        },

        config = function()
            local telescope   = require("telescope")
            local actions     = require("telescope.actions")
            local lga_actions = require("telescope-live-grep-args.actions")

            telescope.setup({
                defaults = {
                    prompt_prefix        = " ",
                    selection_caret      = " ",
                    path_display         = { "smart" },
                    sorting_strategy     = "ascending",
                    layout_strategy      = "horizontal",

                    -- ✅ strategy-specific layout config
                    layout_config        = {
                        -- your usual layout
                        horizontal = {
                            prompt_position = "top",
                            preview_width   = 0.55,
                            results_width   = 0.8,
                            height          = function(_, _, rows) return math.floor(rows * 0.95) end,
                            width           = function(_, cols, _) return math.floor(cols * 0.95) end,
                        },

                        -- used by lots of plugins (e.g. model pickers)
                        center = {
                            prompt_position = "top",
                            preview_cutoff  = 1, -- show preview if there is room
                            height          = function(_, _, rows) return math.min(20, rows - 4) end,
                            width           = function(_, cols, _) return math.min(100, cols - 8) end,
                        },

                        cursor = {
                            preview_cutoff = 1,
                            height         = function(_, _, rows) return math.min(20, math.floor(rows * 0.4)) end,
                            width          = function(_, cols, _) return math.min(120, math.floor(cols * 0.5)) end,
                        },

                        vertical = {
                            prompt_position = "top",
                            preview_height  = 0.5,
                            height          = function(_, _, rows) return math.floor(rows * 0.95) end,
                            width           = function(_, cols, _) return math.floor(cols * 0.95) end,
                        },

                        -- Bottom pane (some extensions might use it)
                        bottom_pane = {
                            prompt_position = "top",
                            preview_cutoff  = 1,
                            height          = function(_, _, rows) return math.min(15, rows - 4) end,
                        },
                    },

                    vimgrep_arguments    = {
                        "rg", "--color=never", "--no-heading", "--with-filename",
                        "--line-number", "--column", "--smart-case",
                        "--hidden", "--glob", "!**/.git/*", "--glob", "!**/node_modules/*",
                    },
                    file_ignore_patterns = { "%.git/", "node_modules/" },

                    mappings             = {
                        i = {
                            ["<C-j>"] = require("telescope.actions").move_selection_next,
                            ["<C-k>"] = require("telescope.actions").move_selection_previous,
                            ["<C-n>"] = require("telescope.actions").cycle_history_next,
                            ["<C-p>"] = require("telescope.actions").cycle_history_prev,
                            ["<C-u>"] = require("telescope.actions").preview_scrolling_up,
                            ["<C-d>"] = require("telescope.actions").preview_scrolling_down,
                            ["<C-c>"] = require("telescope.actions").close,
                            ["<Esc>"] = require("telescope.actions").close,
                        },
                        n = {
                            ["q"]     = require("telescope.actions").close,
                            ["<Esc>"] = require("telescope.actions").close,
                        },
                    },
                },

                pickers = {
                    find_files  = { hidden = true },
                    live_grep   = {},
                    grep_string = {},
                    buffers     = {
                        sort_lastused = true,
                        ignore_current_buffer = true,
                        mappings = {
                            i = { ["<C-x>"] = require("telescope.actions").delete_buffer },
                            n = { ["x"] = require("telescope.actions").delete_buffer },
                        },
                    },
                    oldfiles    = { only_cwd = true },
                    keymaps     = {},
                },
                extensions = {
                    -- Live Grep Args: tiny cheat sheet for the prompt
                    --   foo -w                  -- word match
                    --   "foo bar" -F            -- literal phrase (fixed strings)
                    --   foo --no-ignore         -- search ignored files too
                    --   foo -t js -t ts         -- only JS & TS types
                    --   foo --iglob **/tests/** -- only paths matching glob
                    --   foo -g '!**/dist/**'    -- exclude dist
                    --   foo -L                  -- follow symlinks
                    live_grep_args = {
                        auto_quoting = true,
                        mappings = {
                            i = {
                                ["<C-q>"]     = lga_actions.quote_prompt(),
                                ["<C-g>"]     = lga_actions.quote_prompt({ postfix = " --iglob " }),
                                ["<C-Space>"] = lga_actions.to_fuzzy_refine,
                            },
                        },
                    },
                },
            })

            pcall(telescope.load_extension, "fzf")
            pcall(telescope.load_extension, "live_grep_args")
        end,
    },
}

-- return {
--     {
--         "nvim-telescope/telescope.nvim",
--         dependencies = {
--             "nvim-lua/plenary.nvim",
--             "folke/which-key.nvim",
--             { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" }, -- LGA
--             { "nvim-telescope/telescope-fzf-native.nvim",     build = "make" },     -- optional
--         },
--         config = function()
--             local telescope   = require("telescope")
--             local actions     = require("telescope.actions")
--             local lga_actions = require("telescope-live-grep-args.actions")
--
--             telescope.setup({
--                 defaults = {
--                     prompt_prefix        = " ",
--                     selection_caret      = " ",
--                     path_display         = { "smart" },
--                     sorting_strategy     = "ascending",
--                     layout_strategy      = "horizontal",
--                     layout_config        = {
--                         prompt_position = "top",
--                         preview_width   = 0.55,
--                         results_width   = 0.8,
--                     },
--                     vimgrep_arguments    = {
--                         "rg", "--color=never", "--no-heading", "--with-filename",
--                         "--line-number", "--column", "--smart-case",
--                         "--hidden", "--glob", "!**/.git/*", "--glob", "!**/node_modules/*",
--                     },
--                     file_ignore_patterns = { "%.git/", "node_modules/" },
--                     mappings             = {
--                         i = {
--                             ["<C-j>"] = actions.move_selection_next,
--                             ["<C-k>"] = actions.move_selection_previous, -- keep your nav
--                             ["<C-n>"] = actions.cycle_history_next,
--                             ["<C-p>"] = actions.cycle_history_prev,
--                             ["<C-u>"] = actions.preview_scrolling_up,
--                             ["<C-d>"] = actions.preview_scrolling_down,
--                             ["<C-c>"] = actions.close,
--                             ["<Esc>"] = actions.close,
--                         },
--                         n = {
--                             ["q"] = actions.close,
--                             ["<Esc>"] = actions.close,
--                         },
--                     },
--                 },
--                 pickers = {
--                     find_files  = { hidden = true },
--                     live_grep   = {},
--                     grep_string = {},
--                     buffers     = {
--                         sort_lastused = true,
--                         ignore_current_buffer = true,
--                         mappings = {
--                             i = { ["<C-x>"] = actions.delete_buffer },
--                             n = { ["x"] = actions.delete_buffer },
--                         },
--                     },
--                     oldfiles    = { only_cwd = true },
--                     keymaps     = {},
--                 },
--                 extensions = {
--                     -- ── Live Grep Args configuration ─────────────────────────────────────
--                     -- Mini cheat sheet (copy/paste into the prompt):
--                     --   foo -w                    -- word match
--                     --   "foo bar" -F              -- literal phrase (fixed strings)
--                     --   foo --no-ignore           -- search ignored files too
--                     --   foo -t js -t ts           -- only JS & TS types
--                     --   foo --iglob **/tests/**   -- only in paths matching glob
--                     --   foo -g '!**/dist/**'      -- exclude dist directory
--                     --   foo -L                    -- follow symlinks
--                     -- Keys inside the LGA prompt:
--                     --   <C-q>      quote current prompt
--                     --   <C-g>      quote + add " --iglob " (then type a glob)
--                     --   <C-Space>  refine current results (fuzzy on the current set)
--
--                     live_grep_args = {
--                         auto_quoting = true, -- lets us type bare text and quote on demand
--                         mappings = {
--                             i = {
--                                 ["<C-q>"]     = lga_actions.quote_prompt(),                          -- quote current prompt
--                                 ["<C-g>"]     = lga_actions.quote_prompt({ postfix = " --iglob " }), -- quote + add --iglob
--                                 ["<C-Space>"] = lga_actions.to_fuzzy_refine,                         -- refine current results
--                             },
--                         },
--                     },
--                 },
--             })
--
--             -- Load extensions (no-op if missing)
--             pcall(telescope.load_extension, "fzf")
--             pcall(telescope.load_extension, "live_grep_args") -- exposes .extensions.live_grep_args.live_grep_args
--
--             -- Which-Key launcher keys (Telescope namespace)
--             local ok, wk = pcall(require, "which-key"); if not ok then return end
--             local b   = require("telescope.builtin")
--             local lga = telescope.extensions.live_grep_args
--
--             wk.add({
--                 -- { "<leader>t",  group = "Telescope" },
--                 { "<leader>tt", b.builtin,                                      desc = "Pickers list" },
--                 { "<leader>tr", b.resume,                                       desc = "Resume last picker" },
--                 { "<leader>tf", function() b.find_files({ hidden = true }) end, desc = "Find files" },
--                 { "<leader>tg", b.live_grep,                                    desc = "Live grep" },
--                 { "<leader>tG", lga.live_grep_args,                             desc = "Live grep (args)" },
--                 {
--                     "<leader>tS",
--                     function()
--                         require("telescope-live-grep-args.shortcuts").grep_word_under_cursor()
--                     end,
--                     desc = "Grep word (args)"
--                 },
--                 {
--                     "<leader>t.",
--                     function()
--                         lga.live_grep_args({ search_dirs = { vim.fn.expand("%:p:h") } })
--                     end,
--                     desc = "Live grep (this dir)"
--                 },
--                 { "<leader>ts", b.grep_string, desc = "Grep string" },
--                 { "<leader>tb", b.buffers,     desc = "Buffers" },
--                 { "<leader>to", b.oldfiles,    desc = "Old files (cwd)" },
--                 { "<leader>tk", b.keymaps,     desc = "Keymaps" },
--                 { "<leader>tc", b.commands,    desc = "Commands" },
--                 { "<leader>th", b.help_tags,   desc = "Help tags" },
--             }, { mode = "n" })
--         end,
--     },
-- }
