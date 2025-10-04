return {
  -- Flutter tools (manages Dart LSP + run/debug/devices/etc.)
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = { "dart" },
    cmd = {
      "FlutterRun", "FlutterDebug", "FlutterDevices", "FlutterEmulators", "FlutterReload", "FlutterRestart",
      "FlutterQuit", "FlutterAttach", "FlutterDetach", "FlutterOutlineToggle", "FlutterOutlineOpen", "FlutterDevTools",
      "FlutterDevToolsActivate", "FlutterCopyProfilerUrl", "FlutterLspRestart", "FlutterSuper", "FlutterReanalyze",
      "FlutterRename", "FlutterLogClear", "FlutterLogToggle",
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

    -- which-key v3: register groups early
    init = function()
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        wk.add({
          { "<leader>f",  group = "Flutter" },
          { "<leader>fB", group = "BLoC" }, -- nested group for the bloc helper plugin
        })
      end
    end,

    -- v3-friendly keymaps (no sizing here—your global UI sizing handles that)
    keys = {
      { "<leader>fr", "<cmd>FlutterRun<CR>",               desc = "Run Project",                mode = "n", silent = true, noremap = true },
      { "<leader>fd", "<cmd>FlutterDebug<CR>",             desc = "Debug Run (DAP)",            mode = "n", silent = true, noremap = true },
      { "<leader>fv", "<cmd>FlutterDevices<CR>",           desc = "Select Device",              mode = "n", silent = true, noremap = true },
      { "<leader>fe", "<cmd>FlutterEmulators<CR>",         desc = "Select Emulator",            mode = "n", silent = true, noremap = true },
      { "<leader>fl", "<cmd>FlutterReload<CR>",            desc = "Hot Reload",                 mode = "n", silent = true, noremap = true },
      { "<leader>fs", "<cmd>FlutterRestart<CR>",           desc = "Hot Restart",                mode = "n", silent = true, noremap = true },
      { "<leader>fq", "<cmd>FlutterQuit<CR>",              desc = "Quit App",                   mode = "n", silent = true, noremap = true },
      { "<leader>fa", "<cmd>FlutterAttach<CR>",            desc = "Attach to App",              mode = "n", silent = true, noremap = true },
      { "<leader>fx", "<cmd>FlutterDetach<CR>",            desc = "Detach Session",             mode = "n", silent = true, noremap = true },
      { "<leader>fo", "<cmd>FlutterOutlineToggle<CR>",     desc = "Toggle Outline",             mode = "n", silent = true, noremap = true },
      { "<leader>fO", "<cmd>FlutterOutlineOpen<CR>",       desc = "Open Outline",               mode = "n", silent = true, noremap = true },
      { "<leader>ft", "<cmd>FlutterDevTools<CR>",          desc = "Start DevTools",             mode = "n", silent = true, noremap = true },
      { "<leader>fT", "<cmd>FlutterDevToolsActivate<CR>",  desc = "Activate DevTools",          mode = "n", silent = true, noremap = true },
      { "<leader>fc", "<cmd>FlutterCopyProfilerUrl<CR>",   desc = "Copy Profiler URL",          mode = "n", silent = true, noremap = true },
      { "<leader>fL", "<cmd>FlutterLspRestart<CR>",        desc = "Restart Dart LSP",           mode = "n", silent = true, noremap = true },
      { "<leader>fS", "<cmd>FlutterSuper<CR>",             desc = "Go to Super",                mode = "n", silent = true, noremap = true },
      { "<leader>fn", "<cmd>FlutterRename<CR>",            desc = "Rename & Update Imports",    mode = "n", silent = true, noremap = true },
      { "<leader>fu", "<cmd>FlutterReanalyze<CR>",         desc = "Force Reanalyze",            mode = "n", silent = true, noremap = true },
      { "<leader>fC", "<cmd>FlutterLogClear<CR>",          desc = "Clear Logs",                 mode = "n", silent = true, noremap = true },
      { "<leader>fG", "<cmd>FlutterLogToggle<CR>",         desc = "Toggle Logs",                mode = "n", silent = true, noremap = true },

      -- Telescope helpers
      { "<leader>ff", function()
          local ok_t = pcall(require, "telescope")
          if ok_t then require("telescope").extensions.flutter.commands() end
        end, desc = "Telescope: Flutter Commands", mode = "n", silent = true, noremap = true },

      { "<leader>fF", function()
          local ok_t = pcall(require, "telescope")
          if ok_t and require("telescope").extensions.flutter.fvm then
            require("telescope").extensions.flutter.fvm()
          else
            vim.notify("FVM picker unavailable (enable fvm in flutter-tools)", vim.log.levels.INFO)
          end
        end, desc = "Telescope: Flutter FVM", mode = "n", silent = true, noremap = true },
    },

    opts = function()
      return {
        -- tasteful UX extras
        widget_guides = { enabled = true }, -- experimental but handy
        closing_tags  = {
          enabled = true,
          highlight = "Comment",
          prefix = ">",
          priority = 10,
        },
        debugger = { -- integrates with nvim-dap
          enabled = true,
          exception_breakpoints = {},
          evaluate_to_string_in_debug_views = true,
        },
        -- dev_log / outline can be enabled later if desired
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
        dapui.setup()
        require("nvim-dap-virtual-text").setup()

        dap.listeners.after.event_initialized["dapui_flutter"] = function() dapui.open() end
        dap.listeners.before.event_terminated["dapui_flutter"] = function() dapui.close() end
        dap.listeners.before.event_exited["dapui_flutter"]     = function() dapui.close() end
      end
    end,
  },

  -- Flutter BLoC boilerplate generator (code actions + commands)
  {
    "wa11breaker/flutter-bloc.nvim",
    ft = { "dart" },
    dependencies = { "nvimtools/none-ls.nvim" }, -- required for code actions

    init = function()
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        wk.add({ { "<leader>fB", group = "BLoC" } })
      end
    end,

    keys = {
      { "<leader>fBb", function() require("flutter-bloc").create_bloc() end,
        desc = "Create Bloc", mode = "n", silent = true, noremap = true },
      { "<leader>fBc", function() require("flutter-bloc").create_cubit() end,
        desc = "Create Cubit", mode = "n", silent = true, noremap = true },
    },

    opts = {
      bloc_type = "equatable",   -- 'default' | 'equatable' | 'freezed'
      use_sealed_classes = false,
      enable_code_actions = true,
    },
    config = function(_, opts)
      require("flutter-bloc").setup(opts)
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
