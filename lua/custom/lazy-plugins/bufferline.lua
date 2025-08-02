return {
    {
        "akinsho/bufferline.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "folke/which-key.nvim",
        },
        event = "BufWinEnter",
        opts = {
            options = {
                numbers                 = "none",
                diagnostics             = "nvim_lsp",
                separator_style         = "slant",
                show_buffer_close_icons = true,
                show_close_icon         = false,
                always_show_bufferline  = false, -- ↓ only when you have more than one tab
                mode                    = "tabs", -- ↓ switch to tabline mode :contentReference[oaicite:0]{index=0}
            },
        },
        keys = {
            { "<leader>bn", "<cmd>BufferLineCycleNext<CR>",   desc = "Buffers: Next" },
            { "<leader>bp", "<cmd>BufferLineCyclePrev<CR>",   desc = "Buffers: Prev" },
            { "<leader>bk", "<cmd>BufferLinePick<CR>",        desc = "Buffers: Pick" },
            { "<leader>bK", "<cmd>BufferLinePickClose<CR>",   desc = "Buffers: Pick to Close" },
            { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Buffers: Close Others" },
            { "<leader>bl", "<cmd>BufferLineCloseLeft<CR>",   desc = "Buffers: Close Left" },
            { "<leader>br", "<cmd>BufferLineCloseRight<CR>",  desc = "Buffers: Close Right" },
            { "<leader>bm", "<cmd>BufferLineMoveNext<CR>",    desc = "Buffers: Move Next" },
            { "<leader>bM", "<cmd>BufferLineMovePrev<CR>",    desc = "Buffers: Move Prev" },
        },
        config = function(_, opts)
            require("bufferline").setup(opts)
            local ok, which_key = pcall(require, "which-key")
            if not ok then return end

            which_key.register({
                b = {
                    name = "Buffers/Bookmarks",
                    n = { "<cmd>BufferLineCycleNext<CR>", "Next Buffer" },
                    p = { "<cmd>BufferLineCyclePrev<CR>", "Prev Buffer" },
                    k = { "<cmd>BufferLinePick<CR>", "Pick Buffer" },
                    K = { "<cmd>BufferLinePickClose<CR>", "Pick to Close" },
                    o = { "<cmd>BufferLineCloseOthers<CR>", "Close Others" },
                    l = { "<cmd>BufferLineCloseLeft<CR>", "Close Left" },
                    r = { "<cmd>BufferLineCloseRight<CR>", "Close Right" },
                    m = { "<cmd>BufferLineMoveNext<CR>", "Move Next" },
                    M = { "<cmd>BufferLineMovePrev<CR>", "Move Prev" },
                },
            }, { prefix = "<leader>" })
        end,
    },
}
