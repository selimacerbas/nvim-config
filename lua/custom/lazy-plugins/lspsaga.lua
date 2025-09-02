return {
    {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "folke/which-key.nvim",
            -- "nvim-treesitter/nvim-treesitter", -- optional but recommended by Saga docs
        },
        opts = {
            -- your finder keys (these match Saga’s documented defaults)
            finder = {
                keys = {
                    toggle_or_open = "o",
                    vsplit         = "s",
                    split          = "i",
                    tabe           = "t",
                    tabnew         = "r",
                    quit           = "q",
                    close          = "<C-c>k",
                    -- shuttle = "[w", -- default; switch focus between panes if you want
                },
            },
            lightbulb = { enable = false },

            -- Required for Outline to work (breadcrumbs in winbar)
            symbols_in_winbar = { enable = true },
            -- outline = { layout = "normal" }, -- defaults are fine; switch to "float" if you prefer
        },

        config = function(_, opts)
            require("lspsaga").setup(opts)

            local map = vim.keymap.set

            -- Core motions (keep your choices; no conflict with earlier groups)
            map('n', 'gh', '<cmd>Lspsaga finder<CR>', { silent = true, desc = 'Saga: Finder' })
            map('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', { silent = true, desc = 'Saga: Definition' })
            map('n', 'gD', '<cmd>Lspsaga goto_declaration<CR>', { silent = true, desc = 'Saga: Declaration' })
            map('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', { silent = true, desc = 'Saga: Peek Definition' })

            -- Diagnostics: non-conflicting with gitsigns ([c ]c)
            map('n', ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>', { silent = true, desc = 'Diagnostics: Next' })
            map('n', '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>', { silent = true, desc = 'Diagnostics: Prev' })

            -- Hover: toggle by default; use ++keep to pin (optional helper under <leader>lH)
            -- map('n', 'K', '<cmd>Lspsaga hover_doc<CR>', { silent = true, desc = 'Saga: Hover Doc' })

            -- Which-key group under <leader>l (LSP UI via Saga)
            local ok, wk = pcall(require, 'which-key')
            if ok then
                local add = wk.add or wk.register
                add({
                    { '<leader>l',  group = 'LSP' },

                    { '<leader>lh', '<cmd>Lspsaga hover_doc<CR>',                        desc = 'Hover Doc' },
                    { '<leader>lH', '<cmd>Lspsaga hover_doc ++keep<CR>',                 desc = 'Hover (pin)' },

                    { '<leader>lf', '<cmd>Lspsaga finder<CR>',                           desc = 'Finder / References' },
                    { '<leader>lg', '<cmd>Lspsaga goto_definition<CR>',                  desc = 'Go to Definition' },
                    { '<leader>lD', '<cmd>Lspsaga goto_declaration<CR>',                 desc = 'Go to Declaration' },
                    { '<leader>lp', '<cmd>Lspsaga peek_definition<CR>',                  desc = 'Peek Definition' },

                    { '<leader>la', '<cmd>Lspsaga code_action<CR>',                      desc = 'Code Action' },
                    { '<leader>lr', '<cmd>Lspsaga rename<CR>',                           desc = 'Rename Symbol' },

                    { '<leader>lR', '<cmd>Lspsaga show_line_diagnostics<CR>',            desc = 'Line Diagnostics' },
                    { '<leader>ld', '<cmd>Lspsaga show_cursor_diagnostics<CR>',          desc = 'Cursor Diagnostics' },

                    { '<leader>li', '<cmd>Lspsaga incoming_calls<CR>',                   desc = 'Incoming Calls' },
                    { '<leader>lO', '<cmd>Lspsaga outgoing_calls<CR>',                   desc = 'Outgoing Calls' },

                    { '<leader>lo', '<cmd>Lspsaga outline<CR>',                          desc = 'Symbols Outline' },

                    { '<leader>lF', function() vim.lsp.buf.format({ async = true }) end, desc = 'Format Buffer' },
                }, { mode = 'n', silent = true, noremap = true })
            end

            -- (Optional) If you *do* pin Hover, closing it is easy:
            -- :Lspsaga hover_doc (toggles), or use q inside the window.
        end,
    },
}
