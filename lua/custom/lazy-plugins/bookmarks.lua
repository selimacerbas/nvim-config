return {
  {
    "crusj/bookmarks.nvim",
    branch = "main",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope.nvim",
      "folke/which-key.nvim",
    },

    -- which-key v3: register the group early
    init = function()
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        wk.add({ { "<leader>b", group = "Bookmarks" } })
      end
    end,

    -- Lazy-load on first key use
    keys = {
      { "<leader>bt", function() require("bookmarks").toggle_bookmarks() end,
        desc = "Toggle Bookmark List", mode = "n", silent = true, noremap = true },

      { "<leader>ba", function() require("bookmarks").add_bookmarks(false) end,
        desc = "Add Bookmark", mode = "n", silent = true, noremap = true },

      { "<leader>bA", function() require("bookmarks").add_bookmarks(true) end,
        desc = "Add Global Bookmark", mode = "n", silent = true, noremap = true },

      { "<leader>bd", function() require("bookmarks.list").delete_on_virt() end,
        desc = "Delete Bookmark (on line)", mode = "n", silent = true, noremap = true },

      { "<leader>bs", function() require("bookmarks.list").show_desc() end,
        desc = "Show Bookmark Description", mode = "n", silent = true, noremap = true },

      { "<leader>bf", "<cmd>Telescope bookmarks<CR>",
        desc = "Find Bookmarks (Telescope)", mode = "n", silent = true, noremap = true },
    },

    opts = {
      -- disable plugin's own keymaps; we'll use our leader maps
      mappings_enabled = false,

      -- UI
      border_style = "single",
      hl = { border = "TelescopeBorder", cursorline = "guibg=Gray guifg=White" },
      virt_text = "",    -- use bookmark descriptions in the gutter
      sign_icon = "󰃃",
      fix_enable = false,
    },

    config = function(_, opts)
      require("bookmarks").setup(opts)
      pcall(function() require("telescope").load_extension("bookmarks") end)
      -- no extra which-key registration needed; group handled in init and key descs come from keys{}
    end,
  },
}
