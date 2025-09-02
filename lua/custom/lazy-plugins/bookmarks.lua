return {
    {
        "crusj/bookmarks.nvim",
        branch = "main",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-telescope/telescope.nvim",
            "folke/which-key.nvim",
        },

        -- Lazy-load on first key use
        keys = {
            { "<leader>bt", function() require("bookmarks").toggle_bookmarks() end,    mode = "n", desc = "Toggle Bookmark List" },
            { "<leader>ba", function() require("bookmarks").add_bookmarks(false) end,  mode = "n", desc = "Add Bookmark" },
            { "<leader>bA", function() require("bookmarks").add_bookmarks(true) end,   mode = "n", desc = "Add Global Bookmark" }, -- shows in all projects
            { "<leader>bd", function() require("bookmarks.list").delete_on_virt() end, mode = "n", desc = "Delete Bookmark (on line)" },
            { "<leader>bs", function() require("bookmarks.list").show_desc() end,      mode = "n", desc = "Show Bookmark Description" },
            { "<leader>bf", "<cmd>Telescope bookmarks<CR>",                            mode = "n", desc = "Find Bookmarks (Telescope)" },
        },

        opts = {
            -- turn off plugin’s own keymaps so we don’t collide with <Tab><Tab>, \z, etc.
            -- (we’re providing our own leader keymaps above)
            mappings_enabled = false, -- see README defaults & keymap table. :contentReference[oaicite:1]{index=1}

            -- UI taste: keep the defaults but you can tweak these any time
            border_style = "single",
            hl = { border = "TelescopeBorder", cursorline = "guibg=Gray guifg=White" },
            -- leave virt_text empty to use bookmark descriptions in the gutter
            virt_text = "",
            sign_icon = "󰃃",
            -- keep the safer default for line-fix (author marks it experimental) :contentReference[oaicite:2]{index=2}
            fix_enable = false,
        },

        config = function(_, opts)
            require("bookmarks").setup(opts)
            -- Telescope extension provided by the plugin; command: :Telescope bookmarks :contentReference[oaicite:3]{index=3}
            pcall(function() require("telescope").load_extension("bookmarks") end)

            -- which-key group header (v2/v3 compatible)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local register = wk.add or wk.register
                register({ { "<leader>b", group = "Bookmarks" } }, { mode = "n" })
            end
        end,
    },
}
