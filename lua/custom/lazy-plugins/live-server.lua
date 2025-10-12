-- ~/.config/nvim/lua/custom/lazy-plugins/live-server.lua
return {
  "selimacerbas/live-server.nvim",
  dependencies = {
    "folke/which-key.nvim",
    "nvim-telescope/telescope.nvim",
  },
  init = function()
    local ok, wk = pcall(require, "which-key")
    if ok then wk.add({ { "<leader>L", group = "LiveServer" } }) end
  end,
  opts = {
    default_port = 4070,
    live_reload = { enabled = true, inject_script = true, debounce = 120 },
    directory_listing = { enabled = true, show_hidden = false },
  },
  -- ⬇️ Use Ex-commands, not require(...) at spec time
  keys = {
    { "<leader>Ls", "<cmd>LiveServerStart<cr>",     desc = "Start (pick path & port)" },
    { "<leader>Lo", "<cmd>LiveServerOpen<cr>",      desc = "Open existing port in browser" },
    { "<leader>Lr", "<cmd>LiveServerReload<cr>",    desc = "Force reload (pick port)" },
    { "<leader>Lt", "<cmd>LiveServerToggleLive<cr>",desc = "Toggle live-reload (pick port)" },
    { "<leader>LS", "<cmd>LiveServerStop<cr>",      desc = "Stop one (pick port)" },
    { "<leader>LA", "<cmd>LiveServerStopAll<cr>",   desc = "Stop all" },
  },
  config = function(_, opts)
    require("live_server").setup(opts)
  end,
}
