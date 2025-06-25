-- ~/.config/nvim/lua/plugins/avante.lua
return {
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        version = false, -- or use "*" to pin to releases
        build = function()
            if vim.fn.has("win32") == 1 then
                return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
            else
                return "make"
            end
        end,
        config = function(_, opts)
            require("avante_lib").load()
            require("avante").setup(opts)
        end,
        opts = {
            provider = "openai",
            providers = {
                openai = {
                    endpoint = "https://api.openai.com/v1",
                    model = "gpt-4.1",
                    timeout = 30000,
                    extra_request_body = {
                        temperature = 0,
                        max_completion_tokens = 8192,
                    },
                },
                copilot = {}, -- if you're using Copilot
            },
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "echasnovski/mini.pick",
            "nvim-telescope/telescope.nvim",
            "hrsh7th/nvim-cmp",
            "ibhagwan/fzf-lua",
            "nvim-tree/nvim-web-devicons",
            "zbirenbaum/copilot.lua",
            {
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = { insert_mode = true },
                        use_absolute_path = true,
                    },
                },
            },
            {
                "MeanderingProgrammer/render-markdown.nvim",
                ft = { "markdown", "Avante" },
                opts = { file_types = { "markdown", "Avante" } },
            },
        },
    },
}
