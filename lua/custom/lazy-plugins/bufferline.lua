return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "folke/which-key.nvim",
        },
        opts = {
            options = {
                mode = "tabs",            -- show Neovim *tabpages* instead of buffers
                numbers = "none",
                diagnostics = "nvim_lsp", -- show LSP counts on tabs
                separator_style = "slant",
                show_buffer_close_icons = true,
                show_close_icon = false,
                always_show_bufferline = false, -- hide when only one tab
                -- keep sidebars tidy so the tabline doesn't jump around
                offsets = {
                    { filetype = "neo-tree", text = "Explorer",  highlight = "Directory", separator = true },
                    { filetype = "NvimTree", text = "Explorer",  highlight = "Directory", separator = true },
                    { filetype = "undotree", text = "Undo Tree", highlight = "Directory", separator = true },
                },
                -- optional hover UI (requires Neovim ≥0.8)
                hover = { enabled = true, delay = 200, reveal = { "close" } },
            },
        },
        keys = {
            -- Put everything under <leader>t… (Tabs) to avoid <leader>b… (Bookmarks) conflicts
            { "<leader>en", "<cmd>BufferLineCycleNext<CR>",   desc = "Tabs: Next" },
            { "<leader>ep", "<cmd>BufferLineCyclePrev<CR>",   desc = "Tabs: Prev" },
            { "<leader>ek", "<cmd>BufferLinePick<CR>",        desc = "Tabs: Pick" },
            { "<leader>eK", "<cmd>BufferLinePickClose<CR>",   desc = "Tabs: Pick to Close" },
            { "<leader>eo", "<cmd>BufferLineCloseOthers<CR>", desc = "Tabs: Close Others" },
            { "<leader>el", "<cmd>BufferLineCloseLeft<CR>",   desc = "Tabs: Close Left" },
            { "<leader>er", "<cmd>BufferLineCloseRight<CR>",  desc = "Tabs: Close Right" },
            { "<leader>em", "<cmd>BufferLineMoveNext<CR>",    desc = "Tabs: Move Next" },
            { "<leader>eM", "<cmd>BufferLineMovePrev<CR>",    desc = "Tabs: Move Prev" },
        },
        config = function(_, opts)
            require("bufferline").setup(opts)

            -- which-key group (v2/v3 compatible)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local register = wk.add or wk.register
                register({
                    -- { "<leader>e",  group = "Tabs" },
                    { "<leader>en", desc = "Tabs: Next" },
                    { "<leader>ep", desc = "Tabs: Prev" },
                    { "<leader>ek", desc = "Tabs: Pick" },
                    { "<leader>eK", desc = "Tabs: Pick to Close" },
                    { "<leader>eo", desc = "Tabs: Close Others" },
                    { "<leader>el", desc = "Tabs: Close Left" },
                    { "<leader>er", desc = "Tabs: Close Right" },
                    { "<leader>em", desc = "Tabs: Move Next" },
                    { "<leader>eM", desc = "Tabs: Move Prev" },
                }, { mode = "n", silent = true, noremap = true })
            end
        end,
    },
}
