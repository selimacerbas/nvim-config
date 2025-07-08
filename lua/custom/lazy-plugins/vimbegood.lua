return {
    {
        "thePrimeagen/vim-be-good",
        cmd = "VimBeGood",
        dependencies = { "folke/which-key.nvim" },
        config = function()
            -- setup the plugin
            require("VimBeGood").setup({})

            -- which-key mapping under <leader>v
            local ok, which_key = pcall(require, "which-key")
            if not ok then return end

            which_key.register({
                v = {
                    name = "VimTex/VimBeGood",
                    b = { "<cmd>VimBeGood<CR>", "Play 'Vim Be Good'" },
                },
            }, { prefix = "<leader>" })
        end,
    },
}
