return {
    {
        "Pocco81/auto-save.nvim",
        event = "VeryLazy", -- load after UI is ready; autosave still runs on its own events
        dependencies = { "folke/which-key.nvim" },
        opts = function()
            -- Filetypes/buftypes we generally don't want to auto-save
            local ignore_ft = {
                "gitcommit", "gitrebase", "neo-tree", "oil", "aerial",
                "TelescopePrompt", "lazy", "mason", "snacks_picker_input",
                "spectre_panel", "help",
            }
            local ignore_bt = { "nofile", "prompt", "terminal", "quickfix" }

            return {
                enabled = true,
                execution_message = {
                    message = function()
                        return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
                    end,
                    dim = 0.18,
                    cleaning_interval = 800, -- a bit snappier than default
                },
                -- Save on typical IDE-like moments; these are the plugin defaults
                trigger_events = { "InsertLeave", "TextChanged" }, -- See :h events
                -- Only save “real” editable buffers
                condition = function(buf)
                    local fn, bo = vim.fn, vim.bo[buf]
                    if bo == nil then return false end
                    -- valid, modifiable file with no special buftype and not ignored filetype
                    if bo.modifiable ~= true then return false end
                    if bo.buftype ~= "" and not vim.tbl_contains({ "acwrite" }, bo.buftype) then
                        return false
                    end
                    if vim.tbl_contains(ignore_bt, bo.buftype) then return false end
                    if vim.tbl_contains(ignore_ft, bo.filetype) then return false end
                    -- file exists on disk or we’ve set a name (so we don’t spam :saveas prompts)
                    local name = fn.bufname(buf)
                    if name == "" then return false end
                    return true
                end,
                write_all_buffers = false,
                debounce_delay = 135, -- keep your preferred debounce
                callbacks = {
                    -- Example hook: you can plug something here later if wanted
                    -- after_saving = function() end,
                },
            }
        end,
        config = function(_, opts)
            local autosave = require("auto-save")
            autosave.setup(opts)

            -- Helpers
            local function is_running()
                local ok, ac = pcall(vim.api.nvim_get_autocmds, { group = "AutoSave" })
                return ok and #ac > 0
            end
            local function status()
                vim.notify("AutoSave: " .. (is_running() and "ON" or "OFF"))
            end

            -- which-key: tuck everything under <leader>ua (UI → AutoSave) to avoid conflicts
            local ok, wk = pcall(require, "which-key")
            if ok then
                local register = wk.add or wk.register
                register({
                    { "<leader>u",  group = "AutoSave" },
                    { "<leader>ut", "<cmd>ASToggle<CR>",                       desc = "Toggle AutoSave" },
                    { "<leader>uo", function() require("auto-save").on() end,  desc = "Enable AutoSave" },
                    { "<leader>ux", function() require("auto-save").off() end, desc = "Disable AutoSave" },
                    { "<leader>us", status,                                    desc = "Show AutoSave Status" },
                    -- Optional: quick writes
                    { "<leader>uw", "<cmd>write<CR>",                          desc = "Write Current File" },
                    { "<leader>uW", "<cmd>wall<CR>",                           desc = "Write All Files" },
                }, { mode = "n", silent = true, noremap = true })
            end
        end,
    },
}
