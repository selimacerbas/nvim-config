-- lua/plugins/dadbod.lua
return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    "tpope/vim-dadbod",
    -- Optional, but highly recommended for completion in SQL buffers
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
  },

  -- You can still trigger loading via commands if you want
  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },

  init = function()
    -- DBUI basic config (safe defaults)
    vim.g.db_ui_use_nerd_fonts = 1

    -- Which-key group (v3 API)
    local ok, wk = pcall(require, "which-key")
    if not ok then
      return
    end

    wk.add({
      { "<leader>D", group = "Database (Dadbod)" },
      -- you *only* need the group here; actual mappings come from `keys`
    })
  end,

  -- All actual keymaps live here so lazy.nvim can lazy-load on keypress
  keys = {
    {
      "<leader>Du",
      "<cmd>DBUIToggle<CR>",
      desc = "Toggle database UI",
      mode = "n",
    },
    {
      "<leader>Do",
      "<cmd>DBUI<CR>",
      desc = "Open database UI",
      mode = "n",
    },
    {
      "<leader>Da",
      "<cmd>DBUIAddConnection<CR>",
      desc = "Add database connection",
      mode = "n",
    },
    {
      "<leader>Df",
      "<cmd>DBUIFindBuffer<CR>",
      desc = "Find DB buffer",
      mode = "n",
    },
    {
      -- helper to start a :DB command quickly (no <CR> on purpose)
      "<leader>DD",
      ":DB ",
      desc = "Run :DB command",
      mode = "n",
    },
  },
}
