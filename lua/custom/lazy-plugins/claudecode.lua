return {
    {
        "coder/claudecode.nvim",
        dependencies = {
            "folke/snacks.nvim",
            { "folke/which-key.nvim", version = "^3" }, -- for the group label
        },

        -- Show the group in WhichKey before the plugin loads
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>A", group = "Claude Code" } })
            end
        end,

        -- Minimal setup; adjust opts if you use a local/native claude binary
        config = function()
            require("claudecode").setup({
                -- Example (uncomment if needed):
                -- terminal_cmd = "~/.claude/local/claude", -- or the path from `which claude`
                -- terminal = { provider = "auto" },        -- default
            })
        end,

        -- Keys from the repo’s Installation example
        keys = {
            { "<leader>Ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
            { "<leader>Af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
            { "<leader>Ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
            { "<leader>AC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>Am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
            { "<leader>Ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
            { "<leader>As", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send selection to Claude" },

            -- Add file from file explorers
            {
                "<leader>As",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
            },

            -- Diff management
            { "<leader>Aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>Ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
        },
    },
}
