return {
    {
        "sphamba/smear-cursor.nvim",
        version = "*",
        event = "VeryLazy",

        -- which-key v3: put group in init (not in keys)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>u", group = "UI / Toggles" } })
            end
        end,

        opts = {
            -- cursor_color = "#d3cdc3",
            -- smear_between_buffers = true,
            -- smear_between_neighbor_lines = true,
            -- scroll_buffer_space = true,
        },

        keys = {
            { "<leader>us", "<cmd>SmearCursorToggle<CR>", desc = "Toggle Smear Cursor", mode = "n", silent = true, noremap = true },
        },

        config = function(_, opts)
            require("smear_cursor").setup(opts)
        end,
    },
}
