return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        dependencies = { "folke/which-key.nvim" },
        config = function()
            local tt            = require("toggleterm")

            -- defaults (used until you hit a preset)
            vim.g._tt_horiz_pct = vim.g._tt_horiz_pct or 0.45 -- horizontal height %
            vim.g._tt_vert_pct  = vim.g._tt_vert_pct or 0.45  -- vertical   width  %

            tt.setup({
                -- Size follows our current presets so it persists across toggles
                size = function(term)
                    if term.direction == "horizontal" then
                        return math.max(3, math.floor(vim.o.lines * (vim.g._tt_horiz_pct or 0.45)))
                    elseif term.direction == "vertical" then
                        return math.max(20, math.floor(vim.o.columns * (vim.g._tt_vert_pct or 0.45)))
                    end
                end,
                persist_size = false, -- we control size ourselves
                direction = "float",
                float_opts = { border = "curved", winblend = 5 },
                shade_terminals = false,
                start_in_insert = true,
                close_on_exit = true,
            })

            -- Transparent splits
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

            -- QoL for terminal buffers
            vim.api.nvim_create_autocmd("TermOpen", {
                pattern = "term://*",
                callback = function(ev)
                    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]],
                        { buffer = ev.buf, silent = true, desc = "Terminal: normal mode" })
                    vim.opt_local.number = false
                    vim.opt_local.relativenumber = false
                end,
            })

            local Terminal   = require("toggleterm.terminal").Terminal
            local float_term = Terminal:new({ direction = "float", hidden = true })
            local horiz_term = Terminal:new({ direction = "horizontal", hidden = true, on_open = make_transparent })
            local vert_term  = Terminal:new({ direction = "vertical", hidden = true, on_open = make_transparent })

            -- Optional: lazygit
            local lazygit
            if vim.fn.executable("lazygit") == 1 then
                lazygit = Terminal:new({
                    cmd = "lazygit",
                    direction = "float",
                    hidden = true,
                    on_open = function(t)
                        t
                            :resize(0.9)
                    end
                })
            end

            -- Helpers ----------------------------------------------------------------
            local function safe_map(mode, lhs, rhs, desc)
                if vim.fn.maparg(lhs, mode) == "" then
                    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
                end
            end

            local function horiz_lines(pct) return math.max(3, math.floor(vim.o.lines * pct)) end
            local function vert_cols(pct) return math.max(20, math.floor(vim.o.columns * pct)) end

            local function set_horiz_pct(pct)
                vim.g._tt_horiz_pct = pct
                local win = horiz_term.window
                if win and vim.api.nvim_win_is_valid(win) then
                    pcall(horiz_term.resize, horiz_term, horiz_lines(pct))
                end
            end

            local function set_vert_pct(pct)
                vim.g._tt_vert_pct = pct
                local win = vert_term.window
                if win and vim.api.nvim_win_is_valid(win) then
                    pcall(vert_term.resize, vert_term, vert_cols(pct))
                end
            end

            -- Mappings ----------------------------------------------------------------
            -- Toggles
            safe_map("n", "<leader>tt", function() float_term:toggle() end, "Terminal (float)")
            safe_map("n", "<leader>th", function() horiz_term:toggle() end, "Terminal (horizontal)")
            safe_map("n", "<leader>tv", function() vert_term:toggle() end, "Terminal (vertical)")
            if lazygit then
                safe_map("n", "<leader>tg", function() lazygit:toggle() end, "LazyGit (float)")
            end

            -- Presets: Vertical width
            safe_map("n", "<leader>t0", function() set_vert_pct(0.40) end, "Vertical width 40%")
            safe_map("n", "<leader>t1", function() set_vert_pct(0.50) end, "Vertical width 50%")
            safe_map("n", "<leader>t2", function() set_vert_pct(0.60) end, "Vertical width 60%")

            -- Presets: Horizontal height
            safe_map("n", "<leader>t3", function() set_horiz_pct(0.40) end, "Horizontal height 40%")
            safe_map("n", "<leader>t4", function() set_horiz_pct(0.50) end, "Horizontal height 50%")
            safe_map("n", "<leader>t5", function() set_horiz_pct(0.60) end, "Horizontal height 60%")

            -- Which-Key labels --------------------------------------------------------
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    -- { "<leader>t",  group = "Terminal" },
                    { "<leader>tt", desc = "Terminal (float)" },
                    { "<leader>th", desc = "Terminal (horizontal)" },
                    { "<leader>tv", desc = "Terminal (vertical)" },
                    (lazygit and { "<leader>tg", desc = "LazyGit (float)" } or nil),

                    { "<leader>t0", desc = "Vertical width 40%" },
                    { "<leader>t1", desc = "Vertical width 50%" },
                    { "<leader>t2", desc = "Vertical width 60%" },

                    { "<leader>t3", desc = "Horizontal height 40%" },
                    { "<leader>t4", desc = "Horizontal height 50%" },
                    { "<leader>t5", desc = "Horizontal height 60%" },
                })
            end
        end,
    },
}
