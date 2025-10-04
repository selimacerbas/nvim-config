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

    -- which-key v3: group label here (not in `keys`)
    init = function()
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        wk.add({ { "<leader>P", group = "PlatformIO" } })
      end
    end,

    -- real mappings only (no group entries)
    keys = {
      {
        "<leader>Pm",
        function()
          local ok, pio = pcall(require, "platformio")
          if ok and type(pio.menu) == "function" then pio.menu() else vim.cmd("Piocmdh") end
        end,
        desc = "Menu",
        mode = "n",
        silent = true, noremap = true,
      },
      { "<leader>Pi", "<cmd>Pioinit<CR>",  desc = "Init Project",     mode = "n", silent = true, noremap = true },
      { "<leader>Pr", "<cmd>Piorun<CR>",   desc = "Build & Upload",   mode = "n", silent = true, noremap = true },
      { "<leader>Pl", "<cmd>Piolib<CR>",   desc = "Manage Libraries", mode = "n", silent = true, noremap = true },
      { "<leader>Ps", "<cmd>Piomon<CR>",   desc = "Serial Monitor",   mode = "n", silent = true, noremap = true },
      { "<leader>Pd", "<cmd>Piodebug<CR>", desc = "Debug",            mode = "n", silent = true, noremap = true },
      { "<leader>Pb", "<cmd>Piodb<CR>",    desc = "Debug DB",         mode = "n", silent = true, noremap = true },
      { "<leader>Ph", "<cmd>Piocmdh<CR>",  desc = "Help",             mode = "n", silent = true, noremap = true },
      { "<leader>Pf", "<cmd>Piocmdf<CR>",  desc = "Flags / Commands", mode = "n", silent = true, noremap = true },
    },

    opts = {
      lsp       = "clangd",     -- or "ccls"
      menu_key  = "<leader>Pm", -- plugin may also set this; harmless duplicate
      menu_name = "PlatformIO",
    },

    config = function(_, opts)
      require("platformio").setup(opts)
      pcall(function() require("telescope").load_extension("ui-select") end)
      -- no which-key here (group added in init; key descs handled via `keys`)
    end,
  },
}
