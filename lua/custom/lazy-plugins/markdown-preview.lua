return {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install", -- Use npm to install dependencies
    ft = { "markdown" },             -- Load only for Markdown files
    init = function()
        vim.g.mkdp_auto_start = 1    -- Automatically start preview on opening a Markdown file
        vim.g.mkdp_auto_close = 1    -- Automatically close preview when the file is closed
    end,
}
