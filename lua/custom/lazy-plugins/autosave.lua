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
                trigger_events = { "InsertLeave", }, -- See :h events  add if needed, "TextChanged"
                -- Only save “real” editable buffers

                condition = function(buf)
                    -- buffer must be a valid, listed, modifiable file buffer
                    if type(buf) ~= "number" or not vim.api.nvim_buf_is_valid(buf) then
                        return false
                    end
                    if vim.fn.buflisted(buf) ~= 1 then
                        return false
                    end

                    local function bopt(opt, default)
                        local ok, val = pcall(vim.api.nvim_buf_get_option, buf, opt)
                        return ok and val or default
                    end

                    local mod = bopt("modifiable", false)
                    local ro  = bopt("readonly", false)
                    local bt  = bopt("buftype", "")
                    local ft  = bopt("filetype", "")

                    if not mod or ro then return false end
                    -- only normal/acwrite buffers
                    if bt ~= "" and bt ~= "acwrite" then return false end

                    -- your ignore lists (keep them in scope)
                    local ignore_bt = { "nofile", "prompt", "terminal", "quickfix" }
                    local ignore_ft = {
                        "gitcommit", "gitrebase", "neo-tree", "oil", "aerial",
                        "TelescopePrompt", "lazy", "mason", "snacks_picker_input",
                        "spectre_panel", "help", "Avante", "AvanteInput",
                    }
                    if vim.tbl_contains(ignore_bt, bt) then return false end
                    if vim.tbl_contains(ignore_ft, ft) then return false end

                    -- must have a name (avoid :saveas prompts)
                    local name = vim.api.nvim_buf_get_name(buf) or ""
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
                    -- { "<leader>ua",  group = "AutoSave" },
                    { "<leader>uat", "<cmd>ASToggle<CR>",                       desc = "Toggle AutoSave" },
                    { "<leader>uao", function() require("auto-save").on() end,  desc = "Enable AutoSave" },
                    { "<leader>uax", function() require("auto-save").off() end, desc = "Disable AutoSave" },
                    { "<leader>uas", status,                                    desc = "Show AutoSave Status" },
                    -- Optional: quick writes
                    { "<leader>uaw", "<cmd>write<CR>",                          desc = "Write Current File" },
                    { "<leader>uaW", "<cmd>wall<CR>",                           desc = "Write All Files" },
                }, { mode = "n", silent = true, noremap = true })
            end
        end,
    },
}
