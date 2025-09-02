return {
    {
        "thePrimeagen/vim-be-good",
        cmd = "VimBeGood",
        dependencies = { "folke/which-key.nvim" },

        -- Make the <leader>v group visible right away
        init = function()
            local function register_group()
                local ok, wk = pcall(require, "which-key")
                if not ok then return end
                if wk.add then
                    -- wk.add({ { "<leader>v", group = "Vim training" } })                     -- which-key v3
                else
                    wk.register({ v = { name = "Vim training" } }, { prefix = "<leader>" }) -- v2
                end
            end
            if package.loaded["which-key"] then
                register_group()
            else
                vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", callback = register_group })
            end
        end,

        keys = {
            { "<leader>vb", "<cmd>VimBeGood<CR>", desc = "Play Vim Be Good" },
        },

        -- No setup function for this plugin; it’s pure Vimscript commands
        config = function()
            -- nothing to configure
        end,
    },
}
