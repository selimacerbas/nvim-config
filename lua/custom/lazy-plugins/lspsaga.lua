return {
    {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "folke/which-key.nvim",
        },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>l", group = "LSP" } })
            end
        end,

        opts = {
            ui = {
                border = "rounded",  -- match nvim-lspconfig, cmp, lsp_signature
            },
            finder = {
                default = "ref+imp",
                keys = {
                    toggle_or_open = "o",
                    vsplit         = "s",
                    split          = "i",
                    tabe           = "t",
                    tabnew         = "r",
                    quit           = "q",
                    close          = "<C-c>k",
                },
            },
            lightbulb = { enable = false },
            symbols_in_winbar = { enable = true },
            diagnostic = {
                show_code_action = true,
                jump_num_shortcut = true,
                border_follow = true,
                show_layout = "float",
            },
        },

        keys = {
            ---------------------------------------------------------------
            -- g-motions: core navigation (no leader needed)
            ---------------------------------------------------------------
            { "gd", "<cmd>Lspsaga goto_definition<CR>",       desc = "Go to definition",      mode = "n", silent = true, noremap = true },
            { "gD", "<cmd>Lspsaga goto_declaration<CR>",      desc = "Go to declaration",      mode = "n", silent = true, noremap = true },
            { "gp", "<cmd>Lspsaga peek_definition<CR>",       desc = "Peek definition",        mode = "n", silent = true, noremap = true },
            { "gt", "<cmd>Lspsaga peek_type_definition<CR>",  desc = "Peek type definition",   mode = "n", silent = true, noremap = true },
            { "gh", "<cmd>Lspsaga finder<CR>",                desc = "Finder (refs+impl)",     mode = "n", silent = true, noremap = true },
            { "gi", vim.lsp.buf.implementation,                desc = "Go to implementation",   mode = "n", silent = true, noremap = true },
            { "gr", vim.lsp.buf.references,                    desc = "List references",        mode = "n", silent = true, noremap = true },
            { "K",  "<cmd>Lspsaga hover_doc ++silent<CR>",     desc = "Hover doc",              mode = "n", silent = true, noremap = true },

            -- Diagnostics navigation (Saga UI)
            { "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>",  desc = "Next diagnostic",        mode = "n", silent = true, noremap = true },
            { "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>",  desc = "Prev diagnostic",        mode = "n", silent = true, noremap = true },

            ---------------------------------------------------------------
            -- <leader>l: LSP actions (unique, no duplicates of g-motions)
            ---------------------------------------------------------------

            -- Actions
            { "<leader>la", "<cmd>Lspsaga code_action<CR>",   desc = "Code action",            mode = "n", silent = true, noremap = true },
            { "<leader>lA", "<cmd>Lspsaga code_action<CR>",   desc = "Code action (range)",    mode = "v", silent = true, noremap = true },
            { "<leader>lr", "<cmd>Lspsaga rename<CR>",        desc = "Rename symbol",          mode = "n", silent = true, noremap = true },
            { "<leader>lF", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format buffer", mode = "n", silent = true, noremap = true },

            -- Hover / docs
            { "<leader>lh", "<cmd>Lspsaga hover_doc ++keep<CR>", desc = "Hover doc (pin)",     mode = "n", silent = true, noremap = true },

            -- Diagnostics views
            { "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>",      desc = "Line diagnostics",      mode = "n", silent = true, noremap = true },
            { "<leader>lD", "<cmd>Lspsaga show_buf_diagnostics<CR>",       desc = "Buffer diagnostics",    mode = "n", silent = true, noremap = true },
            { "<leader>lw", "<cmd>Lspsaga show_workspace_diagnostics<CR>", desc = "Workspace diagnostics", mode = "n", silent = true, noremap = true },

            -- Type definition
            { "<leader>lt", "<cmd>Lspsaga goto_type_definition<CR>", desc = "Go to type definition", mode = "n", silent = true, noremap = true },

            -- Call hierarchy
            { "<leader>lC", "<cmd>Lspsaga incoming_calls<CR>", desc = "Incoming calls",        mode = "n", silent = true, noremap = true },
            { "<leader>lO", "<cmd>Lspsaga outgoing_calls<CR>", desc = "Outgoing calls",        mode = "n", silent = true, noremap = true },

            -- Outline
            { "<leader>lo", "<cmd>Lspsaga outline<CR>",        desc = "Symbols outline",       mode = "n", silent = true, noremap = true },

            -- Inlay hints
            { "<leader>li", "<cmd>LspToggleInlayHints<CR>",    desc = "Toggle inlay hints",    mode = "n", silent = true, noremap = true },

            -- Info
            { "<leader>lI", "<cmd>LspInfo<CR>",                desc = "LSP info",              mode = "n", silent = true, noremap = true },

            -- Signature help
            { "<leader>ls", function() vim.lsp.buf.signature_help() end,                desc = "Signature help",        mode = "n", silent = true, noremap = true },
            { "<leader>lS", function() require("lsp_signature").toggle_float_win() end, desc = "Toggle signature float", mode = "n", silent = true, noremap = true },
        },

        config = function(_, opts)
            require("lspsaga").setup(opts)
        end,
    },

    {
        "ray-x/lsp_signature.nvim",
        event = "LspAttach",
        dependencies = { "folke/which-key.nvim" },

        opts = {
            bind = true,
            doc_lines = 5,
            max_height = 12,
            wrap = true,
            max_width = function() return math.floor(vim.api.nvim_win_get_width(0) * 0.6) end,

            floating_window = true,
            floating_window_above_cur_line = true,
            floating_window_off_x = 1,
            floating_window_off_y = 0,
            handler_opts = { border = "rounded" },

            hint_enable = true,
            hint_prefix = " ",
            hint_scheme = "String",
            hi_parameter = "LspSignatureActiveParameter",
            hint_inline = function() return "eol" end,

            extra_trigger_chars = { "(", "," },
            always_trigger = false,
            close_timeout = 4000,
            zindex = 200,
            padding = " ",
            transparency = nil,
            shadow_blend = 36,
            shadow_guibg = "Black",

            toggle_key = "<M-s>",
            toggle_key_flip_floatwin_setting = true,
            select_signature_key = "<C-d>",
            move_cursor_key = "<M-p>",
        },

        config = function(_, opts)
            require("lsp_signature").setup(opts)
        end,
    },
}
