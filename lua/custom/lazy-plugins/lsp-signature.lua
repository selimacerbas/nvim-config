return {
    {
        "ray-x/lsp_signature.nvim",
        event = "LspAttach",
        dependencies = { "folke/which-key.nvim" },
        opts = function()
            return {
                -- core
                bind = true,
                doc_lines = 5,
                wrap = true,
                max_height = 12,
                max_width = function() return math.floor(vim.api.nvim_win_get_width(0) * 0.8) end,

                -- float
                floating_window = true,
                floating_window_above_cur_line = true,
                floating_window_off_x = 1,
                floating_window_off_y = 0,
                handler_opts = { border = "rounded" },

                -- highlights / hints
                hint_enable = true,
                hint_prefix = " ", -- tweak if using Nerd Fonts v3
                hint_scheme = "String",
                hi_parameter = "LspSignatureActiveParameter",

                -- Neovim 0.10+ inline hint placement:
                -- 'eol' keeps the line stable and avoids PUM overlap
                hint_inline = function() return "eol" end, -- true/'inline' | 'eol' | 'right_align' | false :contentReference[oaicite:0]{index=0}

                -- behavior
                extra_trigger_chars = { "(", "," },
                always_trigger = false,
                close_timeout = 4000,
                zindex = 200,
                padding = " ",
                transparency = nil,
                shadow_blend = 36,
                shadow_guibg = "Black",

                -- insert-mode keymaps (handled by the plugin)
                -- NOTE: <C-s> can freeze some terminals; <M-s> is safer.
                toggle_key = "<M-s>",                             -- toggle signature popup on/off
                toggle_key_flip_floatwin_setting = true,          -- persist the float on/off state :contentReference[oaicite:1]{index=1}
                select_signature_key = "<C-d>",                   -- cycle overloads
                move_signature_window_key = { "<C-k>", "<C-j>" }, -- move float up/down
                -- avoid shadowing Insert's native <C-w> delete-word
                move_cursor_key = "<M-p>",                        -- jump between code & float (insert mode) :contentReference[oaicite:2]{index=2}
            }
        end,
        config = function(_, opts)
            require("lsp_signature").setup(opts)

            -- which-key helpers (normal mode)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    -- { "<leader>l",  group = "LSP" },
                    { "<leader>ls", function() vim.lsp.buf.signature_help() end,                desc = "Show Signature Help" },
                    { "<leader>lS", function() require("lsp_signature").toggle_float_win() end, desc = "Toggle Signature Float" },
                }, { mode = "n", silent = true, noremap = true })
            end
        end,
    },
}
