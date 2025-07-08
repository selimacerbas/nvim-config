return {
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        dependencies = { 'folke/which-key.nvim' },
        config = function()
            -- setup indent-blankline
            require('ibl').setup {
                indent = { char = '|' },
                scope  = { show_start = true, show_end = true },
            }

            -- which-key mappings under <leader>i
            local wk_ok, which_key = pcall(require, 'which-key')
            if not wk_ok then return end

            which_key.register({
                i = {
                    name = "Indent",
                    t = { "<cmd>IBLToggle<CR>", "Toggle Guides" },
                    e = { "<cmd>IBLEnable<CR>", "Enable Guides" },
                    d = { "<cmd>IBLDisable<CR>", "Disable Guides" },
                },
            }, { prefix = "<leader>" })
        end,
    },
}
