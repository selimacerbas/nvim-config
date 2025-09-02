return {
    {
        "nvim-tree/nvim-web-devicons",
        -- Keep it lazy; plugins like nvim-tree / bufferline will pull it in as a dependency.
        lazy = true,

        opts = {
            color_icons = true, -- colored glyphs
            default     = true, -- fall back to a generic icon if no match
            strict      = true, -- only use defined icons; unknowns use `default`

            -- Uncomment & extend these to tailor specific files/extensions:
            -- override_by_filename = {
            --   ["Dockerfile"]        = { icon = "", color = "#2496ED", name = "Dockerfile" },
            --   [".dockerignore"]     = { icon = "", color = "#2496ED", name = "DockerIgnore" },
            --   ["Makefile"]          = { icon = "", color = "#6e9f18", name = "Makefile" },
            --   ["LICENSE"]           = { icon = "󰿃", color = "#d0cfcc", name = "License" },
            -- },
            -- override_by_extension = {
            --   mdx = { icon = "", color = "#519aba", name = "Mdx" },
            --   tf  = { icon = "󱁢", color = "#7B42BC", name = "Terraform" },
            -- },
        },

        config = function(_, opts)
            require("nvim-web-devicons").setup(opts)
        end,
    },
}
