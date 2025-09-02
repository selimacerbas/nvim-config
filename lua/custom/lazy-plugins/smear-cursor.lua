return {
    {
        "sphamba/smear-cursor.nvim",
        version = "*",      -- latest release
        event = "VeryLazy", -- after UI is up
        opts = {
            -- basics:
            --   • toggle on/off: <leader>us
            --   • set a fixed color: cursor_color = "#d3cdc3"
            --   • cross-line/buffer trails: smear_between_neighbor_lines = true, smear_between_buffers = true
            -- cursor_color = "#d3cdc3",
            -- smear_between_buffers = true,
            -- smear_between_neighbor_lines = true,
            -- scroll_buffer_space = true,
        },
        keys = {
            { "<leader>us", "<cmd>SmearCursorToggle<CR>", desc = "Toggle Smear Cursor" },
        },
        config = function(_, opts)
            require("smear_cursor").setup(opts)

            -- which-key v3 group label
            local ok, wk = pcall(require, "which-key")
            if ok then
                (wk.add or wk.register)({
                        { "<leader>u", group = "UI / Toggles" },
                    })
            end
        end,
    },
}
