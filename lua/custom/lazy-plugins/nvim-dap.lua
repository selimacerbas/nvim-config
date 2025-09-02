return
-- nvim-dap core + UI + virtual text + which-key group under <leader>d
{
    "mfussenegger/nvim-dap",
    dependencies = {
        { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
        "theHamsta/nvim-dap-virtual-text",
        "folke/which-key.nvim",
    },
    event = "VeryLazy",
    config = function()
        local dap, dapui = require("dap"), require("dapui")

        -- signs (simple + theme friendly)
        vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", numhl = "" })
        vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", numhl = "" })
        vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint", numhl = "" })

        -- ensure UI opens/closes even when Flutter isn't the launcher
        dap.listeners.after.event_initialized["dapui_global"] = function() dapui.open() end
        dap.listeners.before.event_terminated["dapui_global"] = function() dapui.close() end
        dap.listeners.before.event_exited["dapui_global"]     = function() dapui.close() end

        require("nvim-dap-virtual-text").setup()

        -- which-key for DAP (no conflicts with your other groups)
        local ok, wk = pcall(require, "which-key")
        if ok then
            local add = wk.add or wk.register
            add({
                { "<leader>d",  group = "Debug (DAP)" },
                { "<leader>dc", function() dap.continue() end,          desc = "Continue/Start" },
                { "<leader>do", function() dap.step_over() end,         desc = "Step Over" },
                { "<leader>di", function() dap.step_into() end,         desc = "Step Into" },
                { "<leader>dO", function() dap.step_out() end,          desc = "Step Out" },
                { "<leader>db", function() dap.toggle_breakpoint() end, desc = "Toggle Breakpoint" },
                {
                    "<leader>dB",
                    function()
                        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
                    end,
                    desc = "Set Conditional Breakpoint"
                },
                { "<leader>dr", function() dap.repl.open() end,           desc = "Open REPL" },
                { "<leader>dx", function() dap.terminate() end,           desc = "Terminate" },
                { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
                { "<leader>de", function() require("dapui").eval() end,   desc = "Eval (hover/visual)", mode = { "n", "v" } },
                { "<leader>dl", function() dap.list_breakpoints() end,    desc = "List Breakpoints" },
            }, { mode = { "n", "v" }, silent = true, noremap = true })
        end
    end,
}
