return {
    -- THEME ─────────────────────────────────────────────────────────────────────
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000, -- load before UI plugins
        config = function()
            require("rose-pine").setup({
                variant = "auto",
                dark_variant = "main",
                dim_inactive_windows = false,
                extend_background_behind_borders = true,
                enable = {
                    terminal = true,
                    legacy_highlights = true,
                    migrations = true, -- handle deprecated options automatically
                },

                styles = {
                    bold = false,
                    italic = false,
                    transparency = false,
                },

                groups = {
                    border        = "muted",
                    link          = "iris",
                    panel         = "surface",

                    error         = "love",
                    hint          = "iris",
                    info          = "subtle",
                    note          = "pine",
                    todo          = "rose",
                    warn          = "gold",

                    git_add       = "foam",
                    git_change    = "rose",
                    git_delete    = "love",
                    git_dirty     = "rose",
                    git_ignore    = "muted",
                    git_merge     = "iris",
                    git_rename    = "pine",
                    git_stage     = "iris",
                    git_text      = "rose",
                    git_untracked = "subtle",

                    h1            = "iris",
                    h2            = "foam",
                    h3            = "rose",
                    h4            = "gold",
                    h5            = "pine",
                    h6            = "foam",
                },

                -- keep custom colors here so they survive colorscheme reloads
                highlight_groups = {
                    ["@type"]               = { fg = "#869688" }, -- Classes / types
                    ["@variable"]           = { fg = "#b4bce0" }, -- Variables

                    -- floats only
                    NormalFloat             = { bg = "NONE" },
                    FloatBorder             = { bg = "NONE", fg = "muted" },
                    FloatTitle              = { bg = "NONE", fg = "subtle" },

                    -- common floaty UIs
                    WhichKeyFloat           = { bg = "NONE" },
                    Pmenu                   = { bg = "NONE" },
                    PmenuSel                = { bg = "rose" }, -- keep selection readable
                    TelescopeNormal         = { bg = "NONE" },
                    TelescopeBorder         = { bg = "NONE", fg = "muted" },
                    TelescopePromptNormal   = { bg = "NONE" },
                    TelescopePromptBorder   = { bg = "NONE", fg = "muted" },
                    TelescopeResultsNormal  = { bg = "NONE" },
                    TelescopePreviewNormal  = { bg = "NONE" },

                    LspInfoBorder           = { link = "FloatBorder" },
                    DiagnosticFloatingError = { link = "DiagnosticError" },
                    DiagnosticFloatingWarn  = { link = "DiagnosticWarn" },
                    DiagnosticFloatingInfo  = { link = "DiagnosticInfo" },
                    DiagnosticFloatingHint  = { link = "DiagnosticHint" },
                },
            })

            vim.cmd("colorscheme rose-pine")

            -- LIGHT TRANSPARENCY FOR FLOATS ONLY (safe across 0.10/0.11)
            do
                local aug = vim.api.nvim_create_augroup("FloatsWinblend", { clear = true })

                local function set_winblend_safe(win, val)
                    local ok = pcall(vim.api.nvim_set_option_value, "winblend", val, { win = win })
                    if not ok then pcall(vim.api.nvim_win_set_option, win, "winblend", val) end
                end

                vim.api.nvim_create_autocmd({ "WinNew", "WinEnter" }, {
                    group = aug,
                    callback = function()
                        local win = vim.api.nvim_get_current_win()
                        if not (win and vim.api.nvim_win_is_valid(win)) then return end

                        -- only floats
                        local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
                        if not ok or not cfg or cfg.relative == "" then return end

                        -- skip if already nonzero
                        local cur
                        local ok_get = pcall(function()
                            cur = vim.api.nvim_get_option_value("winblend", { win = win }) -- 0.11+
                            return true
                        end)
                        if not ok_get then
                            local ok2, cur2 = pcall(vim.api.nvim_win_get_option, win, "winblend") -- 0.10
                            if ok2 then cur = cur2 end
                        end
                        if type(cur) == "number" and cur > 0 then return end

                        set_winblend_safe(win, 10) -- tweak 0..100
                    end,
                })
            end

            -- Optional: also fade completion popup menu
            -- vim.o.pumblend = 10
        end,
    },
}
--     -- STATUSLINE ────────────────────────────────────────────────────────────────
--     {
--         "nvim-lualine/lualine.nvim",
--         dependencies = {
--             "nvim-tree/nvim-web-devicons",
--             { "franco-ruggeri/mcphub-lualine.nvim", lazy = true }, -- MCPHub component
--         },
--         config = function()
--             require("lualine").setup({
--                 options = {
--                     theme = "rose-pine",
--                 },
--                 sections = {
--                     lualine_x = {
--                         { "mcphub", icon = "󰐻 " }, -- shows active MCP servers / spinner
--                         { "pipeline", icon = "" }, -- ← latest CI run status
--                         -- your other components can follow here
--                     },
--                 },
--             })
--         end,
--     },
