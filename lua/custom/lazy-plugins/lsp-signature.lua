return {
    {
        "ray-x/lsp_signature.nvim",
        event = "LspAttach",
        dependencies = { "folke/which-key.nvim" },
        opts = {
            bind                           = true, -- mandatory to register keymaps
            doc_lines                      = 3,    -- show up to 2 lines of docs
            floating_window                = true, -- use a floating window
            floating_window_above_cur_line = true, -- try to float above the cursor
            wrap                           = true, -- wrap long lines
            max_height                     = 12,
            -- **round down** so width is an integer
            max_width                      = function()
                local w = vim.api.nvim_win_get_width(0)
                return math.floor(w * 0.8)
            end,
            floating_window_off_x          = 1,
            floating_window_off_y          = 0,
            hint_enable                    = true, -- virtual hint below the line
            hint_prefix                    = " ",
            hint_scheme                    = "String",
            hi_parameter                   = "LspSignatureActiveParameter",
            handler_opts                   = { border = "rounded" },

            -- **Ctrl‑key mappings**:
            toggle_key                     = "<C-s>",              -- Ctrl‑s to toggle the floating window
            select_signature_key           = "<C-d>",              -- Ctrl‑d to cycle to next signature
            move_signature_window_key      = { "<C-k>", "<C-j>" }, -- Ctrl‑k / Ctrl‑j move float up/down
            move_cursor_key                = "<C-w>",              -- Ctrl‑p jump between code & float

            extra_trigger_chars            = { "(", "," },         -- trigger on ( and ,
            always_trigger                 = false,
            close_timeout                  = 4000,
            zindex                         = 200,
            padding                        = " ",
            transparency                   = nil,
            shadow_blend                   = 36,
            shadow_guibg                   = "Black",
        },
        config = function(_, opts)
            require("lsp_signature").setup(opts)

            -- Which-Key hint under <leader>lS
            local ok, which_key = pcall(require, "which-key")
            if ok then
                which_key.register({
                    l = {
                        name = "LSP",
                        S = { "<cmd>lua require('lsp_signature').toggle_float_win()<CR>", "Toggle Signature" },
                    },
                }, { prefix = "<leader>" })
            end
        end,
    },
}
