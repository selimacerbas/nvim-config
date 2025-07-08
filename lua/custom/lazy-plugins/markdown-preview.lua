return {
  {
    "iamcco/markdown-preview.nvim",
    ft    = { "markdown" },
    cmd   = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_auto_start  = 0  -- don’t auto-start preview
      vim.g.mkdp_auto_close  = 1  -- auto-close on buffer close
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

