return {
    {
        "MunifTanjim/nui.nvim",
        lazy = true,
        dependencies = { "folke/which-key.nvim" },

        -- which-key groups early, so they show up even before first load
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>u",  group = "UI / Toggles" },
                    { "<leader>ui", group = "Nui (UI)" },
                })
            end
        end,

        -- Keymaps live here so pressing one will lazy-load nui.nvim
        keys = {
            -- --- UI/Toggles (plain Neovim options) ---
            { "<leader>uw",  function() require("my_nui_ui").toggle_wrap() end,              desc = "Toggle wrap" },
            { "<leader>un",  function() require("my_nui_ui").toggle_number() end,            desc = "Toggle line numbers" },
            { "<leader>ur",  function() require("my_nui_ui").toggle_relativenumber() end,    desc = "Toggle relative numbers" },
            { "<leader>ul",  function() require("my_nui_ui").toggle_list() end,              desc = "Toggle listchars" },
            { "<leader>us",  function() require("my_nui_ui").toggle_spell() end,             desc = "Toggle spell" },
            { "<leader>uc",  function() require("my_nui_ui").toggle_colorcolumn() end,       desc = "Toggle colorcolumn 80" },
            { "<leader>ug",  function() require("my_nui_ui").toggle_signcolumn() end,        desc = "Toggle signcolumn" },
            { "<leader>ud",  function() require("my_nui_ui").toggle_diag_virtual_text() end, desc = "Toggle diagnostics virtual text" },

            -- --- Nui demos (ui<key>) ---
            { "<leader>uip", function() require("my_nui_ui").popup_scratch() end,            desc = "Nui: popup scratch buffer" },
            { "<leader>uii", function() require("my_nui_ui").input_prompt() end,             desc = "Nui: input prompt" },
            { "<leader>uim", function() require("my_nui_ui").menu_toggles() end,             desc = "Nui: toggles menu" },
            { "<leader>uil", function() require("my_nui_ui").layout_demo() end,              desc = "Nui: 2-pane layout demo" },
        },

        -- Define small helpers that use Nui components
        config = function()
            local M = {}

            -- ----- core toggles -----
            local function notify(key, on)
                vim.notify(string.format("%s: %s", key, on and "ON" or "OFF"))
            end

            function M.toggle_wrap()
                vim.wo.wrap = not vim.wo.wrap
                notify("wrap", vim.wo.wrap)
            end

            function M.toggle_number()
                vim.wo.number = not vim.wo.number
                notify("number", vim.wo.number)
            end

            function M.toggle_relativenumber()
                vim.wo.relativenumber = not vim.wo.relativenumber
                notify("relativenumber", vim.wo.relativenumber)
            end

            function M.toggle_list()
                vim.wo.list = not vim.wo.list
                notify("list", vim.wo.list)
            end

            function M.toggle_spell()
                vim.wo.spell = not vim.wo.spell
                notify("spell", vim.wo.spell)
            end

            function M.toggle_colorcolumn()
                local cc = vim.wo.colorcolumn
                if cc == "" or cc == "0" then
                    vim.wo.colorcolumn = "80"
                else
                    vim.wo.colorcolumn = ""
                end
                notify("colorcolumn", vim.wo.colorcolumn ~= "")
            end

            function M.toggle_signcolumn()
                vim.wo.signcolumn = (vim.wo.signcolumn == "no" or vim.wo.signcolumn == "auto") and "yes" or "auto"
                notify("signcolumn", vim.wo.signcolumn ~= "no")
            end

            function M.toggle_diag_virtual_text()
                local cfg = vim.diagnostic.config()
                local cur = cfg.virtual_text
                local enabled = (cur == nil) or (cur == true) or (type(cur) == "table")
                vim.diagnostic.config({ virtual_text = not enabled })
                notify("diagnostics virtual_text", not enabled)
            end

            -- ----- Nui helpers -----
            local event = require("nui.utils.autocmd").event

            function M.popup_scratch()
                local Popup = require("nui.popup")
                local popup = Popup({
                    enter = true,
                    focusable = true,
                    border = {
                        style = "rounded",
                        text = { top = "Nui Scratch", top_align = "center" },
                    },
                    position = "50%",
                    size = { width = "80%", height = "60%" },
                    win_options = { winhighlight = "Normal:Normal,FloatBorder:FloatBorder" },
                })
                popup:mount()

                -- close helpers
                popup:map("n", "q", function() popup:unmount() end, { noremap = true, nowait = true })
                popup:map("n", "<Esc>", function() popup:unmount() end, { noremap = true, nowait = true })
                popup:on(event.BufLeave, function() popup:unmount() end)

                vim.bo[popup.bufnr].buftype = "nofile"
                vim.bo[popup.bufnr].bufhidden = "wipe"
                vim.bo[popup.bufnr].filetype = "markdown"
                vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {
                    "# Scratch",
                    "",
                    "This is a floating scratch buffer created with Nui Popup.",
                    "Press `q` or `<Esc>` to close.",
                })
            end

            function M.input_prompt()
                local Input = require("nui.input")
                local input = Input({
                    position = "50%",
                    size = { width = 50 },
                    border = {
                        style = "rounded",
                        text = { top = "Nui Input", top_align = "center" },
                    },
                }, {
                    prompt = "   ",
                    default_value = "",
                    on_close = function() vim.notify("Input closed") end,
                    on_submit = function(val)
                        vim.notify("You typed: " .. (val == "" and "<empty>" or val))
                    end,
                })
                input:mount()
                input:map("n", "<Esc>", function() input:unmount() end, { noremap = true })
            end

            function M.menu_toggles()
                local Menu = require("nui.menu")
                local menu = Menu({
                    position = "50%",
                    size = { width = 40, height = 10 },
                    border = {
                        style = "rounded",
                        text = { top = "UI Toggles", top_align = "center" },
                    },
                }, {
                    lines = {
                        Menu.item("wrap"),
                        Menu.item("number"),
                        Menu.item("relativenumber"),
                        Menu.item("list"),
                        Menu.item("spell"),
                        Menu.item("colorcolumn"),
                        Menu.item("diagnostics virtual_text"),
                        Menu.item("signcolumn"),
                    },
                    max_width = 40,
                    keymap = {
                        focus_next = { "j", "<Down>" },
                        focus_prev = { "k", "<Up>" },
                        close      = { "<Esc>", "q" },
                        submit     = { "<CR>" },
                    },
                    on_submit = function(item)
                        local map = {
                            wrap = M.toggle_wrap,
                            number = M.toggle_number,
                            relativenumber = M.toggle_relativenumber,
                            list = M.toggle_list,
                            spell = M.toggle_spell,
                            colorcolumn = M.toggle_colorcolumn,
                            ["diagnostics virtual_text"] = M.toggle_diag_virtual_text,
                            signcolumn = M.toggle_signcolumn,
                        }
                        if map[item.text] then map[item.text]() end
                    end,
                })
                menu:mount()
                menu:on(event.BufLeave, function() menu:unmount() end)
            end

            function M.layout_demo()
                local Layout = require("nui.layout")
                local Popup  = require("nui.popup")

                local left   = Popup({
                    border = { style = "rounded", text = { top = "Left", top_align = "center" } },
                    buf_options = { filetype = "markdown" },
                })
                local right  = Popup({
                    border = { style = "rounded", text = { top = "Right", top_align = "center" } },
                    buf_options = { filetype = "markdown" },
                })

                local layout = Layout(
                    {
                        position = "50%",
                        size = { width = "85%", height = "60%" },
                    },
                    Layout.Box({
                        Layout.Box(left, { size = "50%" }),
                        Layout.Box(right, { size = "50%" }),
                    }, { dir = "row" })
                )

                layout:mount()

                vim.api.nvim_buf_set_lines(left.bufnr, 0, -1, false,
                    { "# Left Pane", "", "This pane is a Nui Popup inside a Nui Layout." })
                vim.api.nvim_buf_set_lines(right.bufnr, 0, -1, false,
                    { "# Right Pane", "", "Use this to prototype UI quickly." })

                -- Close both panes with q / <Esc> from either side
                local function close_all()
                    pcall(function() layout:unmount() end)
                end
                for _, win in ipairs({ left, right }) do
                    win:map("n", "q", close_all, { noremap = true, nowait = true })
                    win:map("n", "<Esc>", close_all, { noremap = true, nowait = true })
                end
            end

            -- expose
            package.loaded["my_nui_ui"] = M
        end,
    },
}
