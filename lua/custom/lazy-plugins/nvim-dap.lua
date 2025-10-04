return {
    -- nvim-dap core + UI + virtual text
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
            "theHamsta/nvim-dap-virtual-text",
            "folke/which-key.nvim",
        },
        event = "VeryLazy",

        -- which-key v3 group label (no v2 fallback, no group entries in `keys`)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>d", group = "Debug (DAP)" } })
            end
        end,

        -- clean keys{} so Lazy loads on first use
        keys = {
            { "<leader>dc", function() require("dap").continue() end,          desc = "Continue/Start",    mode = "n", silent = true, noremap = true },
            { "<leader>do", function() require("dap").step_over() end,         desc = "Step Over",         mode = "n", silent = true, noremap = true },
            { "<leader>di", function() require("dap").step_into() end,         desc = "Step Into",         mode = "n", silent = true, noremap = true },
            { "<leader>dO", function() require("dap").step_out() end,          desc = "Step Out",          mode = "n", silent = true, noremap = true },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint", mode = "n", silent = true, noremap = true },
            {
                "<leader>dB",
                function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
                desc = "Set Conditional Breakpoint",
                mode = "n",
                silent = true,
                noremap = true
            },
            { "<leader>dr", function() require("dap").repl.open() end,        desc = "Open REPL",        mode = "n",          silent = true, noremap = true },
            { "<leader>dx", function() require("dap").terminate() end,        desc = "Terminate",        mode = "n",          silent = true, noremap = true },
            { "<leader>du", function() require("dapui").toggle() end,         desc = "Toggle DAP UI",    mode = "n",          silent = true, noremap = true },
            { "<leader>de", function() require("dapui").eval() end,           desc = "Eval (hover/vis)", mode = { "n", "v" }, silent = true, noremap = true },
            { "<leader>dl", function() require("dap").list_breakpoints() end, desc = "List Breakpoints", mode = "n",          silent = true, noremap = true },
        },

        config = function()
            local dap, dapui = require("dap"), require("dapui")

            -- signs
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", numhl = "" })
            vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint", numhl = "" })

            -- UI + virtual text
            dapui.setup() -- minimal/default layout
            require("nvim-dap-virtual-text").setup()

            -- auto open/close UI around sessions
            dap.listeners.after.event_initialized["dapui_global"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_global"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_global"]     = function() dapui.close() end
        end,
    },
}
