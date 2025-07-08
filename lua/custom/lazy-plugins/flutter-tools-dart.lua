return {
    -- Flutter tools for Neovim
    -- Dart LSP comes with it, dont configure it on Mason.
    {
        'nvim-flutter/flutter-tools.nvim',
        lazy = false,
        dependencies = {
            'nvim-lua/plenary.nvim', -- required
            'stevearc/dressing.nvim', -- optional UI
            'folke/which-key.nvim',
        },
        config = function()
            require("flutter-tools").setup {
                -- your flutter-tools options here
            }

            -- register Flutter commands under <leader>f
            local wk_ok, which_key = pcall(require, "which-key")
            if not wk_ok then return end

            which_key.register({
                f = {
                    name = "Flutter",
                    r = { "<cmd>FlutterRun<CR>", "Run Project" },
                    d = { "<cmd>FlutterDebug<CR>", "Debug Run" },
                    v = { "<cmd>FlutterDevices<CR>", "Select Device" },
                    e = { "<cmd>FlutterEmulators<CR>", "Select Emulator" },
                    l = { "<cmd>FlutterReload<CR>", "Hot Reload" },
                    s = { "<cmd>FlutterRestart<CR>", "Hot Restart" },
                    q = { "<cmd>FlutterQuit<CR>", "Quit Flutter" },
                    a = { "<cmd>FlutterAttach<CR>", "Attach to App" },
                    x = { "<cmd>FlutterDetach<CR>", "Detach Session" },
                    o = { "<cmd>FlutterOutlineToggle<CR>", "Toggle Outline" },
                    O = { "<cmd>FlutterOutlineOpen<CR>", "Open Outline" },
                    t = { "<cmd>FlutterDevTools<CR>", "Start DevTools" },
                    T = { "<cmd>FlutterDevToolsActivate<CR>", "Activate DevTools" },
                    c = { "<cmd>FlutterCopyProfilerUrl<CR>", "Copy Profiler URL" },
                    L = { "<cmd>FlutterLspRestart<CR>", "Restart Dart LSP" },
                    S = { "<cmd>FlutterSuper<CR>", "Go to Super" },
                    n = { "<cmd>FlutterRename<CR>", "Rename & Update Imports" },
                    u = { "<cmd>FlutterReanalyze<CR>", "Force Reanalyze" },
                    C = { "<cmd>FlutterLogClear<CR>", "Clear Logs" },
                    G = { "<cmd>FlutterLogToggle<CR>", "Toggle Logs" },
                },
            }, { prefix = "<leader>" })
        end,
    },

    -- Flutter Bloc boilerplate generator
    {
        'wa11breaker/flutter-bloc.nvim',
        dependencies = { 'nvimtools/none-ls.nvim' },
        config = function()
            require('flutter-bloc').setup({
                bloc_type = 'equatable',
                use_sealed_classes = false,
                enable_code_actions = true,
            })
        end,
    },

    -- Dart data-class generator
    {
        'wa11breaker/dart-data-class-generator.nvim',
        dependencies = { 'nvimtools/none-ls.nvim' },
        ft = 'dart',
        config = function()
            require("dart-data-class-generator").setup({})
        end,
    },
}
