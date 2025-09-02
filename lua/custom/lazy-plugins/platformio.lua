return {
    {
        "anurag3301/nvim-platformio.lua",
        cmd = {
            "Pioinit", "Piorun", "Piocmdh", "Piocmdf",
            "Piolib", "Piomon", "Piodebug", "Piodb",
        },
        dependencies = {
            "akinsho/toggleterm.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-lua/plenary.nvim",
            "folke/which-key.nvim",
        },
        -- ⬇️ These create real mappings, so <leader>P shows up in WhichKey
        keys = {
            -- Group label (WhichKey v3 will show it)
            { "<leader>P",  desc = "PlatformIO", mode = "n" },

            -- Menu key: try the plugin’s menu if exposed; fall back to help panel
            {
                "<leader>Pm",
                function()
                    local ok, pio = pcall(require, "platformio")
                    if ok and type(pio.menu) == "function" then
                        pio.menu()
                    else
                        vim.cmd("Piocmdh")
                    end
                end,
                desc = "Menu",
                mode = "n",
            },

            -- Common actions
            { "<leader>Pi", "<cmd>Pioinit<CR>",  desc = "Init Project",     mode = "n" },
            { "<leader>Pr", "<cmd>Piorun<CR>",   desc = "Build & Upload",   mode = "n" },
            { "<leader>Pl", "<cmd>Piolib<CR>",   desc = "Manage Libraries", mode = "n" },
            { "<leader>Ps", "<cmd>Piomon<CR>",   desc = "Serial Monitor",   mode = "n" },
            { "<leader>Pd", "<cmd>Piodebug<CR>", desc = "Debug",            mode = "n" },
            { "<leader>Pb", "<cmd>Piodb<CR>",    desc = "Debug DB",         mode = "n" },
            { "<leader>Ph", "<cmd>Piocmdh<CR>",  desc = "Help",             mode = "n" },
            { "<leader>Pf", "<cmd>Piocmdf<CR>",  desc = "Flags / Commands", mode = "n" },
        },
        opts = {
            lsp       = "clangd",     -- or "ccls"
            menu_key  = "<leader>Pm", -- plugin will also bind this after load (harmless if we map it too)
            menu_name = "PlatformIO",
        },
        config = function(_, opts)
            require("platformio").setup(opts)
            pcall(function() require("telescope").load_extension("ui-select") end)

            -- Optional: reinforce WhichKey group (nice in older which-key)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({ { "<leader>P", group = "PlatformIO" } })
            end
        end,
    },
}
