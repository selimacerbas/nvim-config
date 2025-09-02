return {
    -- Flutter tools (manages run/debug/devices/outline/logs + Dart LSP setup)
    {
        "nvim-flutter/flutter-tools.nvim",
        ft = { "dart" }, -- load when you open Dart
        cmd = {          -- or when you call any Flutter command from anywhere
            "FlutterRun", "FlutterDebug", "FlutterDevices", "FlutterEmulators",
            "FlutterReload", "FlutterRestart", "FlutterQuit", "FlutterAttach",
            "FlutterDetach", "FlutterOutlineToggle", "FlutterOutlineOpen",
            "FlutterDevTools", "FlutterDevToolsActivate", "FlutterCopyProfilerUrl",
            "FlutterLspRestart", "FlutterSuper", "FlutterReanalyze", "FlutterRename",
            "FlutterLogClear", "FlutterLogToggle",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim",        -- nicer vim.ui.select
            "folke/which-key.nvim",
            "nvim-telescope/telescope.nvim", -- optional: flutter Telescope pickers
        },
        opts = function()
            -- keep defaults; uncomment below to enable tasteful extras
            return {
                -- widget_guides = { enabled = true },      -- subtle guides in Dart buffers
                -- closing_tags = { highlight = "Comment" }, -- closing tag virtual text
                -- debugger = { enabled = true },            -- if you also install nvim-dap
            }
        end,
        config = function(_, opts)
            require("flutter-tools").setup(opts)

            -- Telescope integration (commands & FVM switcher)
            pcall(function()
                require("telescope").load_extension("flutter")
            end)

            -- which-key group
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    { "<leader>f",  group = "Flutter" },
                    { "<leader>fr", "<cmd>FlutterRun<CR>",              desc = "Run Project" },
                    { "<leader>fd", "<cmd>FlutterDebug<CR>",            desc = "Debug Run" },
                    { "<leader>fv", "<cmd>FlutterDevices<CR>",          desc = "Select Device" },
                    { "<leader>fe", "<cmd>FlutterEmulators<CR>",        desc = "Select Emulator" },
                    { "<leader>fl", "<cmd>FlutterReload<CR>",           desc = "Hot Reload" },
                    { "<leader>fs", "<cmd>FlutterRestart<CR>",          desc = "Hot Restart" },
                    { "<leader>fq", "<cmd>FlutterQuit<CR>",             desc = "Quit App" },
                    { "<leader>fa", "<cmd>FlutterAttach<CR>",           desc = "Attach to App" },
                    { "<leader>fx", "<cmd>FlutterDetach<CR>",           desc = "Detach Session" },
                    { "<leader>fo", "<cmd>FlutterOutlineToggle<CR>",    desc = "Toggle Outline" },
                    { "<leader>fO", "<cmd>FlutterOutlineOpen<CR>",      desc = "Open Outline" },
                    { "<leader>ft", "<cmd>FlutterDevTools<CR>",         desc = "Start DevTools" },
                    { "<leader>fT", "<cmd>FlutterDevToolsActivate<CR>", desc = "Activate DevTools" },
                    { "<leader>fc", "<cmd>FlutterCopyProfilerUrl<CR>",  desc = "Copy Profiler URL" },
                    { "<leader>fL", "<cmd>FlutterLspRestart<CR>",       desc = "Restart Dart LSP" },
                    { "<leader>fS", "<cmd>FlutterSuper<CR>",            desc = "Go to Super" },
                    { "<leader>fn", "<cmd>FlutterRename<CR>",           desc = "Rename & Update Imports" },
                    { "<leader>fu", "<cmd>FlutterReanalyze<CR>",        desc = "Force Reanalyze" },
                    { "<leader>fC", "<cmd>FlutterLogClear<CR>",         desc = "Clear Logs" },
                    { "<leader>fG", "<cmd>FlutterLogToggle<CR>",        desc = "Toggle Logs" },
                    -- Telescope helpers (if telescope present)
                    {
                        "<leader>ff",
                        function()
                            local ok_t = pcall(require, "telescope")
                            if ok_t then
                                require("telescope").extensions.flutter.commands()
                            else
                                vim.cmd(
                                    "Telescope flutter commands")
                            end
                        end,
                        desc = "Telescope: Flutter Commands"
                    },
                    {
                        "<leader>fF",
                        function()
                            local ok_t = pcall(require, "telescope")
                            if ok_t then
                                local ext = require("telescope").extensions.flutter
                                if ext.fvm then
                                    ext.fvm()
                                else
                                    vim.notify(
                                        "FVM picker unavailable (enable fvm in flutter-tools)", vim.log.levels.INFO)
                                end
                            end
                        end,
                        desc = "Telescope: Flutter FVM"
                    },
                }, { mode = "n", silent = true, noremap = true })
            end
        end,
    },

    -- Flutter BLoC boilerplate generator (code actions + commands)
    {
        "wa11breaker/flutter-bloc.nvim",
        ft = { "dart" },
        dependencies = { "nvimtools/none-ls.nvim" }, -- required for code actions
        opts = {
            bloc_type = "equatable",                 -- 'default' | 'equatable' | 'freezed'
            use_sealed_classes = false,
            enable_code_actions = true,
        },
        config = function(_, opts)
            require("flutter-bloc").setup(opts)
            -- Optional quick creators under <leader>fB… (kept inside Flutter group)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    { "<leader>fB",  group = "BLoC" },
                    { "<leader>fBb", function() require("flutter-bloc").create_bloc() end,  desc = "Create Bloc" },
                    { "<leader>fBc", function() require("flutter-bloc").create_cubit() end, desc = "Create Cubit" },
                })
            end
        end,
    },

    -- Dart data-class generator (code actions via none-ls)
    {
        "wa11breaker/dart-data-class-generator.nvim",
        ft = { "dart" },
        dependencies = { "nvimtools/none-ls.nvim" }, -- provides the code actions
        config = function()
            require("dart-data-class-generator").setup({})
        end,
    },
}
