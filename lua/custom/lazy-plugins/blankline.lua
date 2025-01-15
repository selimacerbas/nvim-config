return {

  -- Add indentation guide plugin
  {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    config = function()
      require("ibl").setup {
        indent = { char = '|' },  -- Character for the vertical line
        scope = { show_start = true, show_end = true },  -- Highlight current context
      }
    end
  },

  
}
