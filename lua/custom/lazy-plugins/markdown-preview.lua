return {
    {
        "iamcco/markdown-preview.nvim",
        ft           = { "markdown" },
        cmd          = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" }, -- official commands
        -- Yarn classic (locks to v1) – alternative is mkdp#util#install() per README
        build        = "cd app && corepack enable && corepack prepare yarn@1.22.22 --activate && yarn install --frozen-lockfile",
        init         = function()
            -- Core behavior (from README defaults)
            vim.g.mkdp_auto_start = 0             -- don't auto-open on entering buffer
            vim.g.mkdp_auto_close = 1             -- close preview when leaving md buffer
            vim.g.mkdp_filetypes = { "markdown" } -- restrict commands to markdown
            -- QoL
            vim.g.mkdp_theme = "dark"             -- follow your taste; remove to follow system
            vim.g.mkdp_echo_preview_url = 1       -- print the URL when opening
            vim.g.mkdp_preview_options = {        -- documented rendering toggles
                disable_sync_scroll = 0,
                sync_scroll_type = "middle",
                hide_yaml_meta = 1,
                disable_filename = 0,
                toc = {},
            }
            -- Tip: if you enable combine preview, also set auto_close = 0 (per README)
            -- vim.g.mkdp_combine_preview = 1
            -- vim.g.mkdp_auto_close = 0
        end,
        dependencies = { "folke/which-key.nvim" },
        keys         = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown: Preview Toggle", ft = "markdown" },
            { "<leader>mo", "<cmd>MarkdownPreview<CR>",       desc = "Markdown: Preview Open",   ft = "markdown" },
            { "<leader>ms", "<cmd>MarkdownPreviewStop<CR>",   desc = "Markdown: Preview Stop",   ft = "markdown" },
        },
        config       = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    -- { "<leader>m",  group = "Markdown" },
                    { "<leader>mp", desc = "Preview Toggle" },
                    { "<leader>mo", desc = "Preview Open" },
                    { "<leader>ms", desc = "Preview Stop" },
                })
            end
        end,
    },
}
