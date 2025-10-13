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
            { "<leader>Gc", "<cmd>GeminiClose<CR>",              desc = "Close CLI Process" },          -- README: :GeminiClose

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
            -- ⬇️ Add inside your existing config() for the gemini plugin
            -- Very Important to be able to use movements within the GEMINI.
            local grp = vim.api.nvim_create_augroup("GeminiWordJump", { clear = true })
            vim.api.nvim_create_autocmd("TermOpen", {
                group = grp,
                pattern = "term://*gemini*",
                callback = function(ev)
                    -- helper: send bytes to the terminal job (this buffer only)
                    local function send(s)
                        local job = vim.b.terminal_job_id
                        if job then vim.fn.chansend(job, s) end
                    end

                    -- Alt+Left / Alt+Right → word left/right (CSI 1;3D / 1;3C)
                    vim.keymap.set("t", "<A-Left>", function() send("\x1b[1;3D") end,
                        { buffer = ev.buf, silent = true, desc = "Gemini: word-left" })
                    vim.keymap.set("t", "<A-Right>", function() send("\x1b[1;3C") end,
                        { buffer = ev.buf, silent = true, desc = "Gemini: word-right" })

                    -- Fallbacks: many CLIs also accept M-b / M-f for word jumps
                    vim.keymap.set("t", "<M-b>", function() send("\x1bb") end,
                        { buffer = ev.buf, silent = true })
                    vim.keymap.set("t", "<M-f>", function() send("\x1bf") end,
                        { buffer = ev.buf, silent = true })
                end,
            })
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
