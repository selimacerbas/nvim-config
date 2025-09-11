return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            { "franco-ruggeri/mcphub-lualine.nvim", lazy = true }, -- MCPHub statusline component
            "topaxi/pipeline.nvim",                                -- provides the "pipeline" lualine component
            "folke/which-key.nvim",
        },
        opts = function()
            ---------------------------------------------------------------------------
            -- which-key groups (v3 add / v2 register) — no key collisions
            ---------------------------------------------------------------------------
            local ok, wk = pcall(require, "which-key")
            if ok then
                (wk.add or wk.register)({
                        { "<leader>ul", group = "Lualine" },
                    })
            end

            ---------------------------------------------------------------------------
            -- helper keymaps for lualine itself
            ---------------------------------------------------------------------------
            local function map(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
            end
            map("<leader>ulr", function() require("lualine").refresh() end, "Lualine: Refresh")
            map("<leader>ulm", function()
                vim.g.mcphub_component_enabled = not vim.g.mcphub_component_enabled
                require("lualine").refresh()
                vim.notify("MCPHub in lualine → " .. (vim.g.mcphub_component_enabled and "ON" or "OFF"))
            end, "Lualine: Toggle MCPHub")

            ---------------------------------------------------------------------------
            -- MCPHub component (toggleable)
            ---------------------------------------------------------------------------
            vim.g.mcphub_component_enabled = (vim.g.mcphub_component_enabled ~= false)
            local mcphub = {
                "mcphub",
                icon = "󰐻 ",
                spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                stopped_symbol = "-",
                cond = function() return vim.g.mcphub_component_enabled end,
            }

            ---------------------------------------------------------------------------
            -- lualine setup (pipeline.nvim badge + mcphub + usuals)
            ---------------------------------------------------------------------------
            return {
                options = {
                    theme = "auto",                 -- follows your current colorscheme (e.g. tokyonight styles)
                    globalstatus = true,
                    refresh = { statusline = 200 }, -- snappier updates/spinners
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = {
                        { "pipeline", icon = "" }, -- ← from topaxi/pipeline.nvim
                        mcphub,
                        "encoding", "fileformat", "filetype",
                    },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            }
        end,
    },
}
