return {
    {
        "gutsavgupta/nvim-gemini-companion",
        -- Hard dep per README
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "folke/which-key.nvim", version = "^3" }, -- ensure v3 API is present
        },

        -- Show the group in WhichKey before the plugin loads
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>G", group = "Gemini Companion" } })
            end
        end,

        -- Lazy-load on first keypress; all maps get proper which-key labels
        keys = {
            -- Core lifecycle
            { "<leader>Gt", "<cmd>GeminiToggle<CR>",             desc = "Toggle Sidebar / Start CLI" }, -- README: :GeminiToggle
            { "<leader>Gc", "<cmd>GeminiClose<CR>",              desc = "Close CLI Process" },       -- README: :GeminiClose

            -- Diagnostics → agent
            { "<leader>GD", "<cmd>GeminiSendFileDiagnostic<CR>", desc = "Send File Diagnostics" }, -- README: :GeminiSendFileDiagnostic
            { "<leader>Gd", "<cmd>GeminiSendLineDiagnostic<CR>", desc = "Send Line Diagnostics" }, -- README: :GeminiSendLineDiagnostic

            -- Sidebar layout
            { "<leader>Gs", "<cmd>GeminiSwitchSidebarStyle<CR>", desc = "Cycle Sidebar Style" }, -- README: :GeminiSwitchSidebarStyle

            -- Send selected text + prompt (visual mode)
            { "<leader>GS", "<cmd>GeminiSend<CR>",               mode = "v",                         desc = "Send Selection to Agent" }, -- README: :GeminiSend (visual)

            -- Diff controls
            { "<leader>Ga", "<cmd>GeminiAccept<CR>",             desc = "Accept Diff Changes" }, -- README: :GeminiAccept
            { "<leader>Gr", "<cmd>GeminiReject<CR>",             desc = "Reject Diff Changes" }, -- README: :GeminiReject

            -- Announcements helper
            { "<leader>G?", "<cmd>GeminiAnnouncement<CR>",       desc = "Show Latest Announcement" }, -- README: :GeminiAnnouncement [arg]
        },

        -- Minimal setup; customize as you like
        config = function()
            require("gemini").setup({
                -- Use both agents if available; the plugin auto-detects in PATH
                -- cmds = { "gemini", "qwen" },
                -- Window presets: "right-fixed" (default) | "left-fixed" | "bottom-fixed" | "floating"
                -- win = { preset = "right-fixed" },
            })
        end,

        -- Load gently
        event = "VeryLazy",
    },
}
