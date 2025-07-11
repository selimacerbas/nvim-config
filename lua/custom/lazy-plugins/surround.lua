return {
    {
        'kylechui/nvim-surround',
        version      = '*',
        event        = 'VeryLazy',
        dependencies = { 'folke/which-key.nvim' },
        config       = function()
            -- Set up nvim-surround with all defaults
            require('nvim-surround').setup()

            -- Which-Key hints for its default operator-pending mappings
            local ok, which_key = pcall(require, 'which-key')
            if not ok then return end

            -- "ys<motion><char>" to add surrounds
            -- "ds<char>"           to delete surrounds
            -- "cs<old><new>"       to change surrounds
            which_key.register({
                s = {
                    name = "Surround (Desc Only)",
                    -- these are *descriptions* only; the plugin provides the actual keymaps
                    s = { "ys", "Add Surround (ys<motion><char>)" },
                    d = { "ds", "Delete Surround (ds<char>)" },
                    c = { "cs", "Change Surround (cs<old><new>)" },
                    S = { "yS", "Surround Line (yS<char>)" },
                    gS = { "gS", "Add Surround to Selection (gS<char>)" },
                },
            }, { prefix = '<leader>' })
        end,
    },
}
