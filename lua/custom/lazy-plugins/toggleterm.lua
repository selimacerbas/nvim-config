return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        dependencies = { "folke/which-key.nvim" },
        config = function()
            local tt = require("toggleterm")

            tt.setup({
                -- Smart split sizing (your logic, kept)
                size = function(term)
                    local ratio = 0.45
                    if term.direction == "horizontal" then
                        return math.floor(vim.o.lines * ratio)
                    elseif term.direction == "vertical" then
                        return math.floor(vim.o.columns * ratio)
                    end
                end,
                persist_size = false,
                direction = "float",     -- default for :ToggleTerm; our custom terms set their own
                float_opts = { border = "curved", winblend = 5 },
                shade_terminals = false, -- keep colors intact
                start_in_insert = true,
                close_on_exit = true,
            })

            -- Transparent splits: reusable HL
            vim.api.nvim_set_hl(0, "ToggleTermTransparent", { bg = "NONE" })

            local function make_transparent(term)
                if term.direction ~= "float" then
                    local win = term.window
                    if not win or not vim.api.nvim_win_is_valid(win) then return end
                    local hl = table.concat({
                        "Normal:ToggleTermTransparent",
                        "NormalNC:ToggleTermTransparent",
                        "SignColumn:ToggleTermTransparent",
                        "EndOfBuffer:ToggleTermTransparent",
                    }, ",")
                    local ok = pcall(vim.api.nvim_set_option_value, "winhighlight", hl, { win = win })
                    if not ok then vim.api.nvim_win_set_option(win, "winhighlight", hl) end
                end
            end

            -- Buffer-local terminal quality-of-life
            vim.api.nvim_create_autocmd("TermOpen", {
                pattern = "term://*",
                callback = function(ev)
                    -- escape to Normal (buffer-local)
                    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]],
                        { buffer = ev.buf, silent = true, desc = "Terminal: normal mode" })
                    -- no line numbers in terminal
                    vim.opt_local.number = false
                    vim.opt_local.relativenumber = false
                end,
            })

            local Terminal   = require("toggleterm.terminal").Terminal
            local float_term = Terminal:new({ direction = "float", hidden = true })
            local horiz_term = Terminal:new({ direction = "horizontal", hidden = true, on_open = make_transparent })
            local vert_term  = Terminal:new({ direction = "vertical", hidden = true, on_open = make_transparent })

            -- Optional: lazygit (only if available)
            local lazygit
            if vim.fn.executable("lazygit") == 1 then
                lazygit = Terminal:new({
                    cmd = "lazygit",
                    direction = "float",
                    hidden = true,
                    on_open = function(t) t:resize(0.9) end, -- fill most of the screen
                })
            end

            -- Safe mappings (no override if user already mapped)
            local function safe_map(mode, lhs, rhs, desc)
                if vim.fn.maparg(lhs, mode) == "" then
                    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
                end
            end

            -- Leader mappings under <leader>T (Terminal)
            safe_map("n", "<leader>Tt", function() float_term:toggle() end, "Terminal (float)")
            safe_map("n", "<leader>Th", function() horiz_term:toggle() end, "Terminal (horizontal)")
            safe_map("n", "<leader>Tv", function() vert_term:toggle() end, "Terminal (vertical)")
            if lazygit then
                safe_map("n", "<leader>Tg", function() lazygit:toggle() end, "LazyGit (float)")
            end

            -- Which-Key labels
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    -- { "<leader>T",  group = "Terminal" },
                    { "<leader>Tt", desc = "Terminal (float)" },
                    { "<leader>Th", desc = "Terminal (horizontal)" },
                    { "<leader>Tv", desc = "Terminal (vertical)" },
                    (lazygit and { "<leader>Tg", desc = "LazyGit (float)" } or nil),
                })
            end
        end,
    },
}
