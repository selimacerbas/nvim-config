return {
    -- Colorscheme: TokyoNight
    {
        "folke/tokyonight.nvim",
        lazy = true,
        dependencies = { "folke/which-key.nvim" },
        config = function()
            ---------------------------------------------------------------------------
            -- State + helpers
            ---------------------------------------------------------------------------
            local state = vim.g._tokyonight_custom or { style = "storm", transparent = false }
            local styles = { "storm", "night", "moon", "day" }

            local function apply(opts)
                state.style = opts.style or state.style
                state.transparent = (opts.transparent ~= nil) and opts.transparent or state.transparent
                vim.g._tokyonight_custom = state

                -- day looks best with a light background
                vim.o.background = (state.style == "day") and "light" or "dark"

                require("tokyonight").setup({
                    style = state.style, -- storm | night | day | moon
                    transparent = state.transparent,
                    terminal_colors = true,
                    styles = { sidebars = "dark", floats = "dark" },
                })
                vim.cmd.colorscheme("tokyonight")
                pcall(require, "lualine") -- refresh lualine if present
                pcall(function() require("lualine").refresh() end)
            end

            local function cycle_style()
                local idx = 1
                for i, s in ipairs(styles) do
                    if s == state.style then
                        idx = i
                        break
                    end
                end
                apply({ style = styles[(idx % #styles) + 1] })
                vim.notify("TokyoNight → " .. state.style .. (state.transparent and " (transparent)" or ""),
                    vim.log.levels.INFO)
            end

            local function set_style(s) apply({ style = s }) end
            local function toggle_transparent() apply({ transparent = not state.transparent }) end

            -- initial apply
            apply(state)

            ---------------------------------------------------------------------------
            -- Keymaps (which-key v3 preferred, v2 fallback)
            ---------------------------------------------------------------------------
            local wk_ok, wk = pcall(require, "which-key")
            if wk_ok then
                local add = wk.add or wk.register
                if add then
                    add({
                        { "<leader>ut", group = "TokyoNight" },
                    })
                end
            end

            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
            end

            -- TokyoNight controls
            map("n", "<leader>utc", cycle_style, "TokyoNight: Cycle style")
            map("n", "<leader>utt", toggle_transparent, "TokyoNight: Toggle transparent")
            map("n", "<leader>ut1", function() set_style("storm") end, "TokyoNight: Storm")
            map("n", "<leader>ut2", function() set_style("night") end, "TokyoNight: Night")
            map("n", "<leader>ut3", function() set_style("moon") end, "TokyoNight: Moon")
            map("n", "<leader>ut4", function() set_style("day") end, "TokyoNight: Day")
        end,
    },
}
