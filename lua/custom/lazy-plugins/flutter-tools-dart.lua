return {
    -- Flutter tools (manages Dart LSP + run/debug/devices/etc.)
    {
        "nvim-flutter/flutter-tools.nvim",
        ft = { "dart" },
        cmd = {
            "FlutterRun", "FlutterDebug", "FlutterDevices", "FlutterEmulators", "FlutterReload", "FlutterRestart",
            "FlutterQuit",
            "FlutterAttach", "FlutterDetach", "FlutterOutlineToggle", "FlutterOutlineOpen", "FlutterDevTools",
            "FlutterDevToolsActivate",
            "FlutterCopyProfilerUrl", "FlutterLspRestart", "FlutterSuper", "FlutterReanalyze", "FlutterRename",
            "FlutterLogClear", "FlutterLogToggle",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim",
            "folke/which-key.nvim",
            "nvim-telescope/telescope.nvim",
            -- DAP stack
            "mfussenegger/nvim-dap",
            { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
            "theHamsta/nvim-dap-virtual-text",
        },
        opts = function()
            return {
                -- tasteful UX extras
                widget_guides = { enabled = true }, -- experimental but handy
                closing_tags  = {                   -- annotate closing widgets
                    enabled = true,
                    highlight = "Comment",
                    prefix = ">",
                    priority = 10,
                },
                debugger      = {               -- integrates with nvim-dap
                    enabled = true,
                    exception_breakpoints = {}, -- keep default (none)
                    evaluate_to_string_in_debug_views = true,
                    -- You can also add register_configurations here if you want custom flavors/targets later
                },
                -- you can enable these later if you like:
                -- dev_log = { enabled = true },
                -- outline = { auto_open = false },
            }
        end,
        config = function(_, opts)
            require("flutter-tools").setup(opts)

            -- Telescope extension
            pcall(function() require("telescope").load_extension("flutter") end)

            -- DAP UI & virtual text
            local dap_ok, dap = pcall(require, "dap")
            if dap_ok then
                local dapui = require("dapui")
                require("dapui").setup()
                require("nvim-dap-virtual-text").setup() -- inline values

                -- auto-open/close UI on session start/stop
                dap.listeners.after.event_initialized["dapui_flutter"] = function() dapui.open() end
                dap.listeners.before.event_terminated["dapui_flutter"] = function() dapui.close() end
                dap.listeners.before.event_exited["dapui_flutter"]     = function() dapui.close() end
            end

            -- which-key: Flutter group (keeps your previous layout)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    { "<leader>f",  group = "Flutter" },
                    { "<leader>fr", "<cmd>FlutterRun<CR>",              desc = "Run Project" },
                    { "<leader>fd", "<cmd>FlutterDebug<CR>",            desc = "Debug Run (DAP)" },
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
                    -- Telescope helpers
                    {
                        "<leader>ff",
                        function()
                            local ok_t = pcall(require, "telescope")
                            if ok_t then require("telescope").extensions.flutter.commands() end
                        end,
                        desc = "Telescope: Flutter Commands"
                    },
                    {
                        "<leader>fF",
                        function()
                            local ok_t = pcall(require, "telescope")
                            if ok_t and require("telescope").extensions.flutter.fvm then
                                require("telescope").extensions.flutter.fvm()
                            else
                                vim.notify("FVM picker unavailable (enable fvm in flutter-tools)", vim.log.levels.INFO)
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
