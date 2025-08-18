-- ~/.config/nvim/lua/plugins/smear-cursor.lua
return {
    {
        "sphamba/smear-cursor.nvim",
        version = "*",  -- use latest release
        event = "VeryLazy", -- load after UI starts
        opts = {
            -- defaults are good; tweak if you like:
            -- cursor_color = "#d3cdc3", -- force smear color (helps if your terminal overrides cursor color)
            -- smear_between_buffers = true,
            -- smear_between_neighbor_lines = true,
            -- scroll_buffer_space = true,
            -- legacy_computing_symbols_support = false,
        },
        keys = {
            { "<leader>us", "<cmd>SmearCursorToggle<CR>", desc = "Toggle Smear Cursor" },
        },
    },
}
