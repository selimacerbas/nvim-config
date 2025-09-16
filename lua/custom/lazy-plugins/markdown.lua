return {
    ---------------------------------------------------------------------------
    -- Image backend (required by diagram.nvim to draw images in terminal)
    ---------------------------------------------------------------------------
    {
        "3rd/image.nvim",
        lazy = true,
        opts = {
            backend = "kitty",        -- "kitty" | "ueberzug" | "sixel"
            processor = "magick_cli", -- ImageMagick (`magick` or `convert`)
            max_width = 0,
            max_height = 0,
            max_width_window_percentage = 60,
            window_overlap_clear_enabled = true,
            editor_only_render_when_focused = true,
            tmux_show_only_in_active_window = true,
        },
    },

    ---------------------------------------------------------------------------
    -- Diagrams-as-code inside Neovim (Mermaid/PlantUML/D2/gnuplot)
    ---------------------------------------------------------------------------
    {
        "3rd/diagram.nvim",
        ft = { "markdown" },
        dependencies = { "3rd/image.nvim", "folke/which-key.nvim" },
        opts = {
            events = {
                render_buffer = { "BufWinEnter", "InsertLeave", "TextChanged" },
                clear_buffer  = { "BufLeave" },
            },
            renderer_options = {
                mermaid = {
                    theme = "dark", -- "default"|"dark"|"forest"|"neutral"
                    scale = 1,
                    background = "transparent",
                    -- cli_args = { "--no-sandbox" },
                },
                -- plantuml = {},
                -- d2 = {},
                -- gnuplot = {},
            },
        },
        keys = {
            -- DIAGRAM group: <leader>md…
            {
                "<leader>mdh",
                function() require("diagram").show_diagram_hover() end,
                desc = "Diagram: Hover (open at cursor)",
                ft = "markdown",
                mode = "n",
            },
            {
                "<leader>mdR",
                function() vim.cmd("edit") end, -- reliable re-render trigger
                desc = "Diagram: Re-render (reload buffer)",
                ft = "markdown",
                mode = "n",
            },
            {
                "<leader>md?",
                function() vim.cmd("DiagramCheck") end,
                desc = "Diagram: Check toolchain",
                ft = "markdown",
                mode = "n",
            },
        },
        config = function(_, opts)
            require("diagram").setup(opts)

            -- which-key groups
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    { "<leader>m",   group = "Markdown" },
                    { "<leader>md",  group = "Diagram" },
                    { "<leader>mdh", desc = "Hover (open at cursor)" },
                    { "<leader>mdR", desc = "Re-render (reload buffer)" },
                    { "<leader>md?", desc = "Check toolchain" },
                })
            end

            -- ===== Tooling checks =====
            local function _has(bin) return (vim.fn.executable(bin) == 1) end

            local function detect_backend()
                if _has("kitty") and os.getenv("TERM") and string.match(os.getenv("TERM"), "kitty") then
                    return "kitty"
                end
                if _has("ueberzugpp") or _has("ueberzug") then
                    return "ueberzug"
                end
                if os.getenv("TERM") and (string.match(os.getenv("TERM"), "sixel") or string.match(os.getenv("TERM"), "mlterm")) then
                    return "sixel"
                end
                return nil
            end

            local function diagram_check(silent)
                local missing = {}

                -- image backend
                local backend = detect_backend()
                if not backend then
                    table.insert(missing, "image backend (Kitty ≥ 0.28, Überzug++, or Sixel-capable terminal)")
                end

                -- ImageMagick
                if not (_has("magick") or _has("convert")) then
                    table.insert(missing, "ImageMagick (`magick` or `convert`)")
                end

                -- Renderers you’re likely to use (adjust if you add more)
                if not _has("mmdc") then table.insert(missing, "Mermaid CLI (`mmdc`)") end
                -- if not _has("plantuml") then table.insert(missing, "PlantUML (`plantuml`)") end
                -- if not _has("d2")      then table.insert(missing, "D2 (`d2`)") end
                -- if not _has("gnuplot") then table.insert(missing, "gnuplot (`gnuplot`)") end

                if #missing == 0 then
                    if not silent then vim.notify("diagram.nvim: all good ✅", vim.log.levels.INFO) end
                    return true
                else
                    local msg = "diagram.nvim: missing tools → \n• " .. table.concat(missing, "\n• ")
                    if not silent then vim.notify(msg, vim.log.levels.WARN, { title = "DiagramCheck" }) end
                    return false
                end
            end

            -- :DiagramCheck command
            vim.api.nvim_create_user_command("DiagramCheck", function() diagram_check(false) end, {})

            -- gentle heads-up once per session on first Markdown open
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function()
                    if vim.g.__diagram_checked_once then return end
                    vim.g.__diagram_checked_once = true
                    diagram_check(true) -- silent (warn only on missing)
                end,
            })
        end,
    },

    ---------------------------------------------------------------------------
    -- Pretty in-buffer Markdown (headings, tables, math, callouts, etc.)
    ---------------------------------------------------------------------------
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            -- choose ONE icon provider:
            -- "nvim-tree/nvim-web-devicons",
            "nvim-mini/mini.icons",
            "folke/which-key.nvim",
        },
        opts = {
            enabled = false, -- start off; toggle when you want “reading mode”
            file_types = { "markdown" },
            preset = "none",
            -- (optional) tune conceal/heading styles here
        },
        keys = {
            -- RENDER group: <leader>mr…
            { "<leader>mrt", "<cmd>RenderMarkdown toggle<CR>",     desc = "Render: Toggle (global)", ft = "markdown" },
            { "<leader>mrb", "<cmd>RenderMarkdown buf_toggle<CR>", desc = "Render: Toggle (buffer)", ft = "markdown" },
            { "<leader>mrr", "<cmd>RenderMarkdown refresh<CR>",    desc = "Render: Refresh",         ft = "markdown" },
        },
        config = function(_, opts)
            require("render-markdown").setup(opts)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    { "<leader>m",   group = "Markdown" },
                    { "<leader>mr",  group = "Render" },
                    { "<leader>mrt", desc = "Toggle (global)" },
                    { "<leader>mrb", desc = "Toggle (buffer)" },
                    { "<leader>mrr", desc = "Refresh" },
                })
            end
        end,
    },



    -- Web preview in your browser (Mermaid + TeX; requires Deno)
    {
        "toppair/peek.nvim",
        ft = { "markdown" },                    -- load only for Markdown
        build = "deno task --quiet build:fast", -- Deno-based bundle
        dependencies = { "folke/which-key.nvim" },
        init = function()
            -- minimal defaults; we’ll open/close on demand
            vim.g.peek_theme = "dark"
        end,
        config = function()
            local peek = require("peek")
            peek.setup({
                auto_load = false, -- don’t auto-open
                close_on_bdelete = true,
                syntax = true,
                theme = "dark",
                update_on_change = true,
                app = "browser", -- use your default browser
                filetype = { "markdown" },
            })

            -- simple user commands
            vim.api.nvim_create_user_command("PeekOpen", peek.open, {})
            vim.api.nvim_create_user_command("PeekClose", peek.close, {})

            -- keymaps (Web Preview group)
            vim.keymap.set("n", "<leader>mwo", function() peek.open() end,
                { desc = "Web Preview: Open (Peek)" })
            vim.keymap.set("n", "<leader>mwc", function() peek.close() end,
                { desc = "Web Preview: Close (Peek)" })
            vim.keymap.set("n", "<leader>mwt", function()
                if peek.is_open() then peek.close() else peek.open() end
            end, { desc = "Web Preview: Toggle (Peek)" })

            -- which-key labels
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    { "<leader>m",   group = "Markdown" },
                    { "<leader>mw",  group = "Web Preview" },
                    { "<leader>mwo", desc = "Open (Peek)" },
                    { "<leader>mwc", desc = "Close (Peek)" },
                    { "<leader>mwt", desc = "Toggle (Peek)" },
                })
            end
        end,
    }


}
