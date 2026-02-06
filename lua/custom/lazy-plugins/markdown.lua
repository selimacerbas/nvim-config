---------------------------------------------------------------------------
-- Diagrams-as-code inside Neovim (Mermaid/PlantUML/D2/gnuplot)
-- # 1) Put an mmdc wrapper earlier in PATH than Homebrew
-- mkdir -p ~/.local/bin
-- cat > ~/.local/bin/mmdc <<'SH'
-- #!/usr/bin/env bash
-- exec npx -y -p @mermaid-js/mermaid-cli mmdc "$@"
-- SH
-- chmod +x ~/.local/bin/mmdc
--
-- # 2) Ensure ~/.local/bin is first in your PATH (add to your shell rc)
-- echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
-- # Start a new shell OR source it:
-- source ~/.zshrc
--
-- # 3) Confirm Neovim will see the wrapper first
-- type -a mmdc
-- mmdc -V
--
-- mkdir -p ~/.config/mermaid
-- cat > ~/.config/mermaid/puppeteer.json <<'JSON'
-- {
--   "executablePath": "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
-- }
-- JSON

-- -- inside your "3rd/diagram.nvim" opts
-- renderer_options = {
--   mermaid = {
--     theme = "dark",
--     scale = 1,
--     background = "transparent",
--     cli_args = {
--       "--puppeteerConfigFile",
--       vim.fn.expand("~/.config/mermaid/puppeteer.json"),
--     },
--   },
-- },
--
--
-- vim.env.PATH = vim.fn.expand("~/.local/bin") .. ":" .. vim.env.PATH

---------------------------------------------------------------------------
return {
    {
        "3rd/diagram.nvim",
        ft = { "markdown" },
        dependencies = { "3rd/image.nvim", "folke/which-key.nvim" },

        -- which-key v3: register groups early
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({
                    { "<leader>m",  group = "Markdown" },
                    { "<leader>md", group = "Diagram" },
                })
            end
        end,

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
                    cli_args = {
                        "--puppeteerConfigFile",
                        vim.fn.expand("~/.config/mermaid/puppeteer.json"),
                    },
                },
            },
        },

        -- v3-friendly keys
        keys = {
            {
                "<leader>mdh",
                function() require("diagram").show_diagram_hover() end,
                desc = "Diagram: Hover (open at cursor)",
                mode = "n",
                ft = "markdown",
                silent = true,
                noremap = true,
            },
            {
                "<leader>mdR",
                function() vim.cmd("edit") end, -- reliable re-render trigger
                desc = "Diagram: Re-render (reload buffer)",
                mode = "n",
                ft = "markdown",
                silent = true,
                noremap = true,
            },
            {
                "<leader>md?",
                function() vim.cmd("DiagramCheck") end,
                desc = "Diagram: Check toolchain",
                mode = "n",
                ft = "markdown",
                silent = true,
                noremap = true,
            },
        },

        config = function(_, opts)
            -- Ensure image.nvim is set up before diagram.nvim uses it
            local ok_img, img = pcall(require, "image")
            if ok_img and img.setup then
                -- Check if already setup by looking for internal state
                local status, _ = pcall(function() return img.get_images end)
                if not status or not package.loaded["image"] then
                    pcall(img.setup, {})
                end
            end

            require("diagram").setup(opts)

            -- ===== Tooling checks =====
            local function _has(bin) return (vim.fn.executable(bin) == 1) end
            local function detect_backend()
                local uv = vim.uv or vim.loop
                if _has("kitty") and os.getenv("TERM") and string.match(os.getenv("TERM"), "kitty") then
                    return "kitty"
                end
                if _has("ueberzugpp") or _has("ueberzug") then return "ueberzug" end
                if os.getenv("TERM")
                    and (string.match(os.getenv("TERM"), "sixel") or string.match(os.getenv("TERM"), "mlterm")) then
                    return "sixel"
                end
                return nil
            end

            local function diagram_check(silent)
                local missing, backend = {}, detect_backend()
                if not backend then
                    table.insert(missing, "image backend (Kitty ≥ 0.28, Überzug++, or Sixel-capable terminal)")
                end
                if not (_has("magick") or _has("convert")) then
                    table.insert(missing, "ImageMagick (`magick` or `convert`)")
                end
                if not _has("mmdc") then
                    table.insert(missing, "Mermaid CLI (`mmdc`)")
                end

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

            -- once per session on first Markdown open
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
    -- Pretty in-buffer Markdown
    ---------------------------------------------------------------------------
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-mini/mini.icons",
            "folke/which-key.nvim",
        },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({
                    { "<leader>m",  group = "Markdown" },
                    { "<leader>mr", group = "Render" },
                })
            end
        end,

        opts = {
            enabled = false, -- start off; toggle when you want “reading mode”
            file_types = { "markdown" },
            preset = "none",
        },

        keys = {

            { "<leader>mrt", "<cmd>RenderMarkdown toggle<CR>",     desc = "Render: Toggle (global)", mode = "n", ft = "markdown", silent = true, noremap = true },
            { "<leader>mrb", "<cmd>RenderMarkdown buf_toggle<CR>", desc = "Render: Toggle (buffer)", mode = "n", ft = "markdown", silent = true, noremap = true },
            { "<leader>mrr", "<cmd>RenderMarkdown refresh<CR>",    desc = "Render: Refresh",         mode = "n", ft = "markdown", silent = true, noremap = true },
        },

        config = function(_, opts)
            require("render-markdown").setup(opts)
        end,
    },

    ---------------------------------------------------------------------------
    -- Web preview in your browser (Mermaid + TeX; requires Deno)
    ---------------------------------------------------------------------------
    {
        "toppair/peek.nvim",
        ft = { "markdown" },
        build = "deno task --quiet build:fast",
        dependencies = { "folke/which-key.nvim" },

        init = function()
            vim.g.peek_theme = "dark"
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({
                    { "<leader>m",  group = "Markdown" },
                    { "<leader>mw", group = "Web Preview" },
                })
            end
        end,

        keys = {

            { "<leader>mwo", "<cmd>PeekOpen<CR>",   desc = "Web Preview: Open (Peek)",   mode = "n", ft = "markdown", silent = true, noremap = true },
            { "<leader>mwc", "<cmd>PeekClose<CR>",  desc = "Web Preview: Close (Peek)",  mode = "n", ft = "markdown", silent = true, noremap = true },
            { "<leader>mwt", "<cmd>PeekToggle<CR>", desc = "Web Preview: Toggle (Peek)", mode = "n", ft = "markdown", silent = true, noremap = true },
        },

        config = function()
            local peek = require("peek")
            peek.setup({
                auto_load = false,
                close_on_bdelete = true,
                syntax = true,
                theme = "dark",
                update_on_change = true,
                app = "browser",
                filetype = { "markdown" },
            })

            -- user commands (used by keys[])
            vim.api.nvim_create_user_command("PeekOpen", function() peek.open() end, {})
            vim.api.nvim_create_user_command("PeekClose", function() peek.close() end, {})
            vim.api.nvim_create_user_command("PeekToggle", function()
                if peek.is_open() then peek.close() else peek.open() end
            end, {})
        end,
    },

    ---------------------------------------------------------------------------
    -- Mermaid playground (uses live-server)
    ---------------------------------------------------------------------------
    {
        "selimacerbas/mermaid-playground.nvim",
        ft = { "markdown", "mdx" },
        dependencies = { "barrett-ruth/live-server.nvim", "folke/which-key.nvim" },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({
                    { "<leader>m",  group = "Markdown" },
                    { "<leader>mm", group = "Mermaid" },
                })
            end
        end,

        keys = {

            {
                "<leader>mmr",
                function() pcall(function() require("mermaid_playground").render() end) end,
                desc = "Mermaid: Render",
                mode = "n",
                ft = { "markdown", "mdx" },
                silent = true,
                noremap = true
            },
            {
                "<leader>mms",
                function() pcall(function() require("mermaid_playground").start() end) end,
                desc = "Mermaid: Start server",
                mode = "n",
                ft = { "markdown", "mdx" },
                silent = true,
                noremap = true
            },
            {
                "<leader>mmS",
                function() pcall(function() require("mermaid_playground").stop() end) end,
                desc = "Mermaid: Stop server",
                mode = "n",
                ft = { "markdown", "mdx" },
                silent = true,
                noremap = true
            },
        },

        config = function()
            require("mermaid_playground").setup({
                workspace_dir = nil, -- defaults to $XDG_CONFIG_HOME/mermaid-playground
                index_name = "index.html",
                diagram_name = "diagram.mmd",
                overwrite_index_on_start = false,
                auto_refresh = true,
                auto_refresh_events = { "InsertLeave", "TextChanged", "BufWritePost" },
                debounce_ms = 450,
                notify_on_refresh = false,
            })
        end,
    },
    --
    -- lua/custom/lazy-plugins/markdown-otter.lua
    {
        "jmbuhr/otter.nvim",
        ft = { "markdown", "rmd", "quarto", "qmd" },
        dependencies = {
            "folke/which-key.nvim",
            "nvim-treesitter/nvim-treesitter",
            { "AckslD/nvim-FeMaco.lua", cmd = "FeMaco" }, -- optional popup editor
        },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({
                    { "<leader>m",  group = "Markdown" },
                    { "<leader>mo", group = "Otter" },
                })
            end
        end,

        opts = {
            lsp = {
                diagnostic_update_events = { "BufWritePost", "InsertLeave" },
                root_dir = function(_, bufnr)
                    return vim.fs.root(bufnr or 0, { ".git", "pyproject.toml", "package.json", "_quarto.yml" })
                        or vim.loop.cwd()
                end,
            },
            buffers = { set_filetype = true, write_to_disk = false },
            handle_leading_whitespace = true,
        },

        -- v3 which-key: define *mappings* here and add a group label
        keys = {

            {
                "<leader>moA",
                function() require("otter").activate(nil, true, true) end,
                desc = "Activate LSP in code blocks",
                mode = "n",
                ft = { "markdown", "rmd", "quarto", "qmd" },
                silent = true,
                noremap = true
            },

            {
                "<leader>moE",
                "<cmd>FeMaco<CR>",
                desc = "Edit fenced block in popup (LSP)",
                mode = "n",
                ft = { "markdown", "rmd", "quarto", "qmd" },
                silent = true,
                noremap = true
            },

            {
                "<leader>mox",
                function() require("otter").export() end,
                desc = "Export code blocks (overwrite)",
                mode = "n",
                ft = { "markdown", "rmd", "quarto", "qmd" },
                silent = true,
                noremap = true
            },

            {
                "<leader>moX",
                function() require("otter").export_otter_as() end,
                desc = "Export blocks as…",
                mode = "n",
                ft = { "markdown", "rmd", "quarto", "qmd" },
                silent = true,
                noremap = true
            },
        },

        config = function(_, opts)
            local otter = require("otter")
            otter.setup(opts)

            -- Auto-activate Otter only in "real" markdown-like buffers
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "markdown", "rmd", "quarto", "qmd" },
                callback = function(args)
                    local bufnr = args.buf

                    -- skip unlisted/special buffers (help, nofile, prompt, quickfix, etc.)
                    local bt = vim.bo[bufnr].buftype
                    if bt ~= "" then return end

                    -- skip unnamed buffers
                    if vim.api.nvim_buf_get_name(bufnr) == "" then return end

                    -- skip floating windows (LSP hover/signature markdown previews)
                    local win = vim.fn.bufwinid(bufnr)
                    if win ~= -1 then
                        local cfg = vim.api.nvim_win_get_config(win)
                        if cfg and cfg.relative and cfg.relative ~= "" then return end
                    end

                    -- run only once per buffer
                    if vim.b[bufnr].otter_activated then return end
                    vim.b[bufnr].otter_activated = true

                    -- be defensive (avoid throwing inside temporary buffers)
                    pcall(function() require("otter").activate(nil, true, true) end)
                end,
            })
        end,
    }
}
