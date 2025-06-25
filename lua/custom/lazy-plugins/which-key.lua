return {
    {
        "folke/which-key.nvim",
        dependencies = { "echasnovski/mini.icons" }, -- Optional dependency
        config = function()
            local wk = require("which-key")

            wk.setup({
                plugins = {
                    spelling = {
                        enabled = true,
                        suggestions = 20,
                    },
                },
                replace = {
                    ["<space>"] = "SPC",
                    ["<cr>"] = "RET",
                    ["<tab>"] = "TAB",
                },
                win = {
                    border = "rounded",
                },
                layout = {
                    align = "center",
                },
            })

            -- Flutter tools keybindings under <leader>f
            wk.register({
                f = {
                    name = "Flutter",
                    r = { ":FlutterRun<CR>", "Run Project" },
                    d = { ":FlutterDebug<CR>", "Debug Run" },
                    v = { ":FlutterDevices<CR>", "Select Device" },
                    e = { ":FlutterEmulators<CR>", "Select Emulator" },
                    l = { ":FlutterReload<CR>", "Hot Reload" },
                    s = { ":FlutterRestart<CR>", "Hot Restart" },
                    q = { ":FlutterQuit<CR>", "Quit Flutter" },
                    a = { ":FlutterAttach<CR>", "Attach to App" },
                    x = { ":FlutterDetach<CR>", "Detach Session" },
                    o = { ":FlutterOutlineToggle<CR>", "Toggle Outline" },
                    O = { ":FlutterOutlineOpen<CR>", "Open Outline" },
                    t = { ":FlutterDevTools<CR>", "Start DevTools" },
                    T = { ":FlutterDevToolsActivate<CR>", "Activate DevTools" },
                    c = { ":FlutterCopyProfilerUrl<CR>", "Copy Profiler URL" },
                    L = { ":FlutterLspRestart<CR>", "Restart Dart LSP" },
                    S = { ":FlutterSuper<CR>", "Go to Super" },
                    n = { ":FlutterRename<CR>", "Rename & Update Imports" },
                    u = { ":FlutterReanalyze<CR>", "Force Reanalyze" },
                    C = { ":FlutterLogClear<CR>", "Clear Logs" },
                    G = { ":FlutterLogToggle<CR>", "Toggle Logs" },
                }
            }, { prefix = "<leader>" })

            -- Molten keybindings under <localleader>m
            wk.register({
                m = {
                    name = "Molten",
                    i = { ":MoltenInit<CR>", "Init Kernel" },
                    o = { ":MoltenEvaluateOperator<CR>", "Run Operator Selection" },
                    l = { ":MoltenEvaluateLine<CR>", "Run Current Line" },
                    c = { ":MoltenReevaluateCell<CR>", "Re-evaluate Cell" },
                    s = { ":MoltenEnterOutput<CR>", "Show Output" },
                    d = { ":MoltenDelete<CR>", "Delete Cell" },
                    h = { ":MoltenHideOutput<CR>", "Hide Output" },
                    e = { ":noautocmd MoltenEnterOutput<CR>", "Enter Output (noautocmd)" },
                }
            }, { prefix = "<leader>" })

            -- Visual mode binding for MoltenEvaluateVisual
            wk.register({
                m = {
                    v = { ":<C-u>MoltenEvaluateVisual<CR>gv", "Run Visual Selection" },
                }
            }, { prefix = "<leader>", mode = "v" })
        end,
    },
}
