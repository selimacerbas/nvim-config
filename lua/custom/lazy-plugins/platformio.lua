return {
    {
        "anurag3301/nvim-platformio.lua",
        cmd = {
            "Pioinit", "Piorun", "Piocmdh", "Piocmdf",
            "Piolib", "Piomon", "Piodebug", "Piodb",
        },
        dependencies = {
            "akinsho/nvim-toggleterm.lua",
            "nvim-telescope/telescope.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-lua/plenary.nvim",
            "folke/which-key.nvim",
        },
        opts = {
            lsp      = "clangd", -- or "ccls"
            menu_key = "<leader>p", -- key to open the PlatformIO menu
        },
        config = function(_, opts)
            -- initialize PlatformIO support
            require("platformio").setup(opts)

            -- which-key mappings under <leader>p
            local ok, which_key = pcall(require, "which-key")
            if not ok then return end

            which_key.register({
                p = {
                    name = "PlatformIO",
                    i = { "<cmd>Pioinit<CR>", "Init Project" },
                    r = { "<cmd>Piorun<CR>", "Build & Upload" },
                    h = { "<cmd>Piocmdh<CR>", "Show Help" },
                    f = { "<cmd>Piocmdf<CR>", "Show Flags" },
                    l = { "<cmd>Piolib<CR>", "Manage Libraries" },
                    m = { "<cmd>Piomon<CR>", "Serial Monitor" },
                    d = { "<cmd>Piodebug<CR>", "Debug" },
                    b = { "<cmd>Piodb<CR>", "Debug DB" },
                },
            }, { prefix = "<leader>" })
        end,
    },
}
