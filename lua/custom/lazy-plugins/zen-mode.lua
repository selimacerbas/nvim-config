return
{
    "folke/zen-mode.nvim",
    opts = {
        window = {
            width = 80, -- or 100 for wide monitors
            options = {
                number = false,
                relativenumber = false,
            },
        },
        plugins = {
            twilight = { enabled = true },
        },
    },
    keys = {
        { "<leader>zz", "<cmd>ZenMode<CR>", desc = "Toggle Zen Mode" },
    },
}
