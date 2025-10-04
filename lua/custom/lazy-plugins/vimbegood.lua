return {
    {
        "thePrimeagen/vim-be-good",
        cmd = "VimBeGood",
        dependencies = { "folke/which-key.nvim" },

        -- Show the group in WhichKey (v3) as soon as possible
        init = function()
            local function add_group()
                local ok, wk = pcall(require, "which-key")
                if ok and wk.add then
                    wk.add({ { "<leader>w", group = " Typer / Vim" } })
                end
            end
            if package.loaded["which-key"] then
                add_group()
            else
                vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", callback = add_group })
            end
        end,

        -- v3-friendly real mapping (so Lazy loads on press)
        keys = {
            { "<leader>vb", "<cmd>VimBeGood<CR>", desc = "Play Vim Be Good", mode = "n", silent = true, noremap = true },
        },

        config = function() end,
    },
}
