return {
    {
        "sudo-tee/opencode.nvim",
        cmd = "Opencode",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MeanderingProgrammer/render-markdown.nvim",
            "folke/snacks.nvim",
            "folke/which-key.nvim",
        },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({
                    { "<leader>O", group = "OpenCode" },
                })
            end
        end,

        keys = {
            -- Core controls
            { "<leader>Ot", "<cmd>Opencode toggle<cr>",         desc = "Toggle" },
            { "<leader>Oi", "<cmd>Opencode input<cr>",          desc = "Input window" },
            { "<leader>Oo", "<cmd>Opencode output<cr>",         desc = "Output window" },

            -- Session management
            { "<leader>Os", "<cmd>Opencode session_select<cr>", desc = "Select session" },
            { "<leader>On", "<cmd>Opencode session_new<cr>",    desc = "New session" },
            { "<leader>Or", "<cmd>Opencode session_rename<cr>", desc = "Rename session" },
            { "<leader>OT", "<cmd>Opencode timeline<cr>",       desc = "Timeline picker" },

            -- Diff operations
            { "<leader>Od", "<cmd>Opencode diff_open<cr>",      desc = "Diff open" },

            -- Quick chat (normal & visual)
            { "<leader>Oq", "<cmd>Opencode quick_chat<cr>",     desc = "Quick chat",      mode = { "n", "v" } },

            -- Interrupt
            { "<leader>Oc", "<cmd>Opencode cancel<cr>",         desc = "Cancel request" },
        },

        opts = {
            -- UI settings
            ui = {
                position = "right",
                width = 0.4,
                show_model_name = true,
                show_context_size = true,
                icons = "nerdfonts", -- "nerdfonts" or "text"
            },

            -- Context settings
            context = {
                auto_capture = true,
                include_diagnostics = true,
                diagnostics_min_severity = vim.diagnostic.severity.WARN,
                include_current_file = true,
                include_selection = true,
                include_git_diff = false,
            },

            -- Use existing plugins
            preferred_picker = "snacks", -- auto, telescope, fzf, snacks, mini
            preferred_completion = "nvim-cmp", -- blink, nvim-cmp, vim_complete

            -- Override default keymap prefix (we use custom keys above)
            keymap_prefix = "<leader>O",
        },

        config = function(_, opts)
            require("opencode").setup(opts)
        end,
    },
}
