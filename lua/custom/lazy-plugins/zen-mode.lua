return {
    {
        "folke/zen-mode.nvim",
        opts = {
            window = {
                width   = 80, -- or 100 for wide monitors
                options = {
                    number         = false,
                    relativenumber = false,
                },
            },
            plugins = {
                twilight = { enabled = true },
            },
        },
        config = function(_, opts)
            require("zen-mode").setup(opts)

            local wk_ok, which_key = pcall(require, "which-key")
            if not wk_ok then return end

            which_key.register({
                z = {
                    name = "Todo/Zen",
                    z = { "<cmd>ZenMode<CR>", "Toggle Zen Mode" },
                },
            }, { prefix = "<leader>" })
        end,
    },
}
