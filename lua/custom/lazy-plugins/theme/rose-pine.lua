return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,    -- load on startup
        priority = 1000, -- before UI plugins
        dependencies = { "folke/which-key.nvim" },

        init = function()
            -- which-key group visible immediately
            local ok, wk = pcall(require, "which-key")
            if ok then
                (wk.add or wk.register)({
                        { "<leader>u",  group = "UI" },
                        { "<leader>ur", group = "Rose Pine" },
                    })
            end
        end,

        keys = function()
            -- keep your custom groups in one place so they survive re-setup() calls
            local CUSTOM_GROUPS = {
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
            }

            local CUSTOM_HLG = {
                ["@type"]               = { fg = "#869688" },
                ["@variable"]           = { fg = "#b4bce0" },
                NormalFloat             = { bg = "NONE" },
                FloatBorder             = { bg = "NONE", fg = "muted" },
                FloatTitle              = { bg = "NONE", fg = "subtle" },
                WhichKeyFloat           = { bg = "NONE" },
                Pmenu                   = { bg = "NONE" },
                PmenuSel                = { bg = "rose" },
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
            }

            local function apply(opts)
                local s        = vim.g._rosepine or {
                    variant = "auto",      -- "auto" | "main" | "moon" | "dawn"
                    dark_variant = "main", -- "main" | "moon"
                    dim_inactive_windows = false,
                    extend_background_behind_borders = true,
                    styles = { bold = false, italic = false, transparency = false },
                }
                opts           = opts or {}
                s.variant      = opts.variant or s.variant
                s.dark_variant = opts.dark_variant or s.dark_variant
                if opts.dim_inactive_windows ~= nil then s.dim_inactive_windows = opts.dim_inactive_windows end
                if opts.extend_background_behind_borders ~= nil then
                    s.extend_background_behind_borders = opts.extend_background_behind_borders
                end
                if opts.styles then s.styles = vim.tbl_deep_extend("force", s.styles, opts.styles) end
                vim.g._rosepine = s

                require("rose-pine").setup({
                    variant = s.variant,
                    dark_variant = s.dark_variant,
                    dim_inactive_windows = s.dim_inactive_windows,
                    extend_background_behind_borders = s.extend_background_behind_borders,
                    enable = {
                        terminal = true,
                        legacy_highlights = true,
                        migrations = true,
                    },
                    styles = {
                        bold = s.styles.bold,
                        italic = s.styles.italic,
                        transparency = s.styles.transparency,
                    },
                    groups = CUSTOM_GROUPS,
                    highlight_groups = CUSTOM_HLG,
                })

                -- sync :set background with chosen variant (helps other plugins)
                vim.o.background = (s.variant == "dawn") and "light" or "dark"

                vim.cmd.colorscheme("rose-pine")
                pcall(function() require("lualine").refresh() end)

                vim.notify(
                    ("Rose Pine → %s (dark:%s)%s%s%s%s"):format(
                        s.variant, s.dark_variant,
                        s.styles.transparency and " +transparent" or "",
                        s.styles.bold and " +bold" or "",
                        s.styles.italic and " +italic" or "",
                        s.dim_inactive_windows and " +dim-inactive" or ""
                    ),
                    vim.log.levels.INFO
                )
            end

            local function set_variant(v) return function() apply({ variant = v }) end end
            local function set_dark_variant(v) return function() apply({ dark_variant = v, variant = v }) end end
            local function cycle()
                local order = { "main", "moon", "dawn" }
                local cur = (vim.g._rosepine and vim.g._rosepine.variant) or "main"
                local idx = 1
                for i, v in ipairs(order) do
                    if v == cur then
                        idx = i
                        break
                    end
                end
                apply({ variant = order[(idx % #order) + 1] })
            end

            local function toggle(k)
                local s = vim.g._rosepine or { styles = {} }
                if k == "transparency" then
                    s.styles.transparency = not s.styles.transparency
                    apply({ styles = { transparency = s.styles.transparency } })
                elseif k == "bold" then
                    s.styles.bold = not s.styles.bold
                    apply({ styles = { bold = s.styles.bold } })
                elseif k == "italic" then
                    s.styles.italic = not s.styles.italic
                    apply({ styles = { italic = s.styles.italic } })
                elseif k == "dim" then
                    s.dim_inactive_windows = not s.dim_inactive_windows
                    apply({ dim_inactive_windows = s.dim_inactive_windows })
                end
            end

            local function toggle_light_dark()
                local s = vim.g._rosepine or {}
                if (s.variant == "dawn") or (vim.o.background == "light") then
                    apply({ variant = s.dark_variant or "main" })
                else
                    apply({ variant = "dawn" })
                end
            end

            return {
                -- Variants
                { "<leader>ur1", set_variant("main"), desc = "Rose Pine: Main (dark)" },
                { "<leader>ur2", set_variant("moon"), desc = "Rose Pine: Moon (dark alt)" },
                { "<leader>ur3", set_variant("dawn"), desc = "Rose Pine: Dawn (light)" },
                { "<leader>urc", cycle, desc = "Rose Pine: Cycle variants" },

                -- Dark variant shortcut (forces dark)
                { "<leader>urm", set_dark_variant("main"), desc = "Rose Pine: Dark → Main" },
                { "<leader>uro", set_dark_variant("moon"), desc = "Rose Pine: Dark → Moon" },

                -- Toggles
                { "<leader>urt", function() toggle("transparency") end, desc = "Rose Pine: Toggle transparency" },
                { "<leader>urb", function() toggle("bold") end, desc = "Rose Pine: Toggle bold" },
                { "<leader>uri", function() toggle("italic") end, desc = "Rose Pine: Toggle italic" },
                { "<leader>urd", function() toggle("dim") end, desc = "Rose Pine: Toggle dim inactive" },
                { "<leader>url", toggle_light_dark, desc = "Rose Pine: Toggle light/dark" },
            }
        end,

        config = function(_, _)
            --------------------------------------------------------------------------
            -- Apply once at startup (your desired defaults)
            --------------------------------------------------------------------------
            require("rose-pine").setup({
                variant = "auto",
                dark_variant = "main",
                dim_inactive_windows = false,
                extend_background_behind_borders = true,
                enable = {
                    terminal = true,
                    legacy_highlights = true,
                    migrations = true,
                },
                styles = { bold = false, italic = false, transparency = false },
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
                highlight_groups = {
                    ["@type"]               = { fg = "#869688" },
                    ["@variable"]           = { fg = "#b4bce0" },
                    NormalFloat             = { bg = "NONE" },
                    FloatBorder             = { bg = "NONE", fg = "muted" },
                    FloatTitle              = { bg = "NONE", fg = "subtle" },
                    WhichKeyFloat           = { bg = "NONE" },
                    Pmenu                   = { bg = "NONE" },
                    PmenuSel                = { bg = "rose" },
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
            vim.cmd.colorscheme("rose-pine")

            --------------------------------------------------------------------------
            -- Light transparency for *floats only*
            --------------------------------------------------------------------------
            local aug = vim.api.nvim_create_augroup("FloatsWinblend", { clear = true })
            local function set_winblend_safe(win, val)
                pcall(vim.api.nvim_set_option_value, "winblend", val, { win = win })
            end
            vim.api.nvim_create_autocmd({ "WinNew", "WinEnter" }, {
                group = aug,
                callback = function()
                    local win = vim.api.nvim_get_current_win()
                    if not (win and vim.api.nvim_win_is_valid(win)) then return end
                    local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
                    if not ok or not cfg or cfg.relative == "" then return end
                    local cur
                    pcall(function()
                        cur = vim.api.nvim_get_option_value("winblend", { win = win })
                    end)
                    if type(cur) == "number" and cur > 0 then return end
                    set_winblend_safe(win, 10)
                end,
            })
        end,
    },
}
