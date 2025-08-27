return {
  {
    "iamcco/markdown-preview.nvim",
    ft  = { "markdown" },
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    -- Use Yarn classic so yarn.lock doesn't get rewritten by Berry (v3/v4)
    build = "cd app && corepack enable && corepack prepare yarn@1.22.22 --activate && yarn install --frozen-lockfile",
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
    dependencies = { "folke/which-key.nvim" },
    config = function()
      local ok, which_key = pcall(require, "which-key")
      if not ok then return end
      which_key.register({
        h = {
          name = "Markdown",
          p = { "<cmd>MarkdownPreviewToggle<CR>", "Toggle Preview" },
          o = { "<cmd>MarkdownPreview<CR>",       "Open Preview" },
          s = { "<cmd>MarkdownPreviewStop<CR>",   "Stop Preview" },
        },
      }, { prefix = "<leader>" })
    end,
  },
}
