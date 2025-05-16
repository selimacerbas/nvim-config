-- ~/.config/nvim/lua/plugins/avante.lua
return {
    {
        "yetone/avante.nvim",
        event        = "VeryLazy",
        version      = false,  -- always use the latest commit
        build        = "make", -- builds the native helper; you can do:
        -- build = "make BUILD_FROM_SOURCE=true"
        -- if you want to force a source build
        opts         = {
            provider = "openai",

            copilot  = {
                -- no extra config needed if you're already running copilot.lua;
                -- Avante will ask copilot.lua for suggestions directly.
            },

            openai   = {
                endpoint              = "https://api.openai.com/v1",
                model                 = "gpt-4o", -- or "gpt-4", etc.
                timeout               = 30000,    -- ms
                temperature           = 0,
                max_completion_tokens = 8192,
            },
            -- you can also configure copilot, anthropic, file_selector, etc.
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "echasnovski/mini.pick",         -- optional file selector
            "nvim-telescope/telescope.nvim", -- optional file selector
            "hrsh7th/nvim-cmp",              -- optional completion
            "ibhagwan/fzf-lua",              -- optional file selector
            "nvim-tree/nvim-web-devicons",
            "zbirenbaum/copilot.lua",        -- if you want Copilot provider
            {
                "HakonHarnes/img-clip.nvim", -- for image pasting
                event = "VeryLazy",
                opts = {                     -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                "MeanderingProgrammer/render-markdown.nvim",
                ft   = { "markdown", "Avante" },
                opts = {
                    file_types = { "markdown", "Avante" },
                },
            },
        },
    },
}
