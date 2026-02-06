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
    open_on_start = true,
    notify = true,
    notify_on_reload = false,
    cors = false,
    live_reload = {
      enabled = true,
      inject_script = true,
      debounce = 120,
      css_inject = true,
    },
    directory_listing = { enabled = true, show_hidden = false },
  },
  keys = {
    { "<leader>Ls", "<cmd>LiveServerStart<cr>",      desc = "Start (pick path & port)" },
    { "<leader>Lo", "<cmd>LiveServerOpen<cr>",        desc = "Open in browser" },
    { "<leader>Lr", "<cmd>LiveServerReload<cr>",      desc = "Force reload" },
    { "<leader>Lt", "<cmd>LiveServerToggleLive<cr>",  desc = "Toggle live-reload" },
    { "<leader>Li", "<cmd>LiveServerStatus<cr>",      desc = "Status" },
    { "<leader>LS", "<cmd>LiveServerStop<cr>",        desc = "Stop one" },
    { "<leader>LA", "<cmd>LiveServerStopAll<cr>",     desc = "Stop all" },
  },
  config = function(_, opts)
    require("live_server").setup(opts)
  end,
}
