return {
    -- telescope for FuzzyFinder and built-in functions
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }, -- Required dependency
        config = function()
            require("telescope").setup {
                defaults = {
                    -- Your Telescope configuration here
                }
            }
        end,
    },

    -- Add more plugins below as needed
}
