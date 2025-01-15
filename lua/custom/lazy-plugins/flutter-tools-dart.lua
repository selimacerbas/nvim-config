return {
    -- Flutter tools for Neovim
    -- Dart LSP comes with it, don't configure it in Mason.
    {
        'nvim-flutter/flutter-tools.nvim',
        lazy = false,
        dependencies = {
            'nvim-lua/plenary.nvim',  -- Required dependency
            'stevearc/dressing.nvim', -- Optional for improved UI selection
        },
        config = function()
            require("flutter-tools").setup {
            }
        end,
    },

    -- Flutter Bloc for Neovim to create boilerplate code
    {
        'wa11breaker/flutter-bloc.nvim',
        dependencies = { 'nvimtools/none-ls.nvim' },
        config = function()
            require('flutter-bloc').setup({
                bloc_type = 'equatable', -- Choose from: 'default', 'equatable', 'freezed'
                use_sealed_classes = false,
                enable_code_actions = true,
            })
        end,
    },
   {
        'wa11breaker/dart-data-class-generator.nvim',
        dependencies = {
            "nvimtools/none-ls.nvim", -- Required for code actions
        },
        ft = 'dart',
        config = function()
            require("dart-data-class-generator").setup({})
        end
    }
}
