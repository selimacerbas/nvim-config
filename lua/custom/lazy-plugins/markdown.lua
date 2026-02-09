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

---------------------------------------------------------------------------
return {
    ---------------------------------------------------------------------------
    -- Diagram: in-terminal rendering (Mermaid/PlantUML/D2/gnuplot)
    ---------------------------------------------------------------------------
    {
        "3rd/diagram.nvim",
        ft = { "markdown" },
        dependencies = { "3rd/image.nvim", "folke/which-key.nvim" },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>m", group = "Markdown" } })
            end
        end,

        opts = {
            events = {
                render_buffer = { "BufWinEnter", "InsertLeave", "TextChanged" },
                clear_buffer  = { "BufLeave" },
            },
            renderer_options = {
                mermaid = {
                    theme = "dark",
                    scale = 1,
                    background = "transparent",
                    cli_args = {
                        "--puppeteerConfigFile",
                        vim.fn.expand("~/.config/mermaid/puppeteer.json"),
                    },
                },
            },
        },

        keys = {
            { "<leader>md", function() require("diagram").show_diagram_hover() end, desc = "Diagram hover",    mode = "n", ft = "markdown", silent = true, noremap = true },
            { "<leader>mD", function() vim.cmd("edit") end,                         desc = "Diagram re-render", mode = "n", ft = "markdown", silent = true, noremap = true },
            { "<leader>m?", function() vim.cmd("DiagramCheck") end,                 desc = "Diagram check",     mode = "n", ft = "markdown", silent = true, noremap = true },
        },

        config = function(_, opts)
            -- Ensure image.nvim is set up before diagram.nvim uses it
            local ok_img, img = pcall(require, "image")
            if ok_img and img.setup then
                local status, _ = pcall(function() return img.get_images end)
                if not status or not package.loaded["image"] then
                    pcall(img.setup, {})
                end
            end

            require("diagram").setup(opts)

            -- ===== Tooling checks =====
            local function _has(bin) return (vim.fn.executable(bin) == 1) end
            local function detect_backend()
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
                    table.insert(missing, "image backend (Kitty, Ueberzug++, or Sixel terminal)")
                end
                if not (_has("magick") or _has("convert")) then
                    table.insert(missing, "ImageMagick (`magick` or `convert`)")
                end
                if not _has("mmdc") then
                    table.insert(missing, "Mermaid CLI (`mmdc`)")
                end

                if #missing == 0 then
                    if not silent then vim.notify("diagram.nvim: all good", vim.log.levels.INFO) end
                    return true
                else
                    local msg = "diagram.nvim: missing tools:\n- " .. table.concat(missing, "\n- ")
                    if not silent then vim.notify(msg, vim.log.levels.WARN, { title = "DiagramCheck" }) end
                    return false
                end
            end

            vim.api.nvim_create_user_command("DiagramCheck", function() diagram_check(false) end, {})

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function()
                    if vim.g.__diagram_checked_once then return end
                    vim.g.__diagram_checked_once = true
                    diagram_check(true)
                end,
            })
        end,
    },

    ---------------------------------------------------------------------------
    -- Render: pretty in-buffer markdown
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
                wk.add({ { "<leader>m", group = "Markdown" } })
            end
        end,

        opts = {
            enabled = false,
            file_types = { "markdown" },
            preset = "none",
        },

        keys = {
            { "<leader>mt", "<cmd>RenderMarkdown toggle<CR>",     desc = "Render toggle",          mode = "n", ft = "markdown", silent = true, noremap = true },
            { "<leader>mT", "<cmd>RenderMarkdown buf_toggle<CR>", desc = "Render toggle (buffer)",  mode = "n", ft = "markdown", silent = true, noremap = true },
            { "<leader>mp", "<cmd>RenderMarkdown preview<CR>",    desc = "Render preview (split)",  mode = "n", ft = "markdown", silent = true, noremap = true },
        },

        config = function(_, opts)
            require("render-markdown").setup(opts)
        end,
    },

    ---------------------------------------------------------------------------
    -- Preview: browser-based markdown preview (uses live-server)
    ---------------------------------------------------------------------------
    {
        dir = "/Users/selimacerbas/Repositories/Personal/Github/markdown-preview.nvim",
        ft = { "markdown", "mdx", "mermaid" },
        dependencies = { "selimacerbas/live-server.nvim", "folke/which-key.nvim" },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>m", group = "Markdown" } })
            end
        end,

        keys = {
            { "<leader>ms", function() require("markdown_preview").start() end,   desc = "Preview start",   mode = "n", ft = { "markdown", "mdx" }, silent = true, noremap = true },
            { "<leader>mS", function() require("markdown_preview").stop() end,    desc = "Preview stop",    mode = "n", ft = { "markdown", "mdx" }, silent = true, noremap = true },
            { "<leader>mr", function() require("markdown_preview").refresh() end, desc = "Preview refresh", mode = "n", ft = { "markdown", "mdx" }, silent = true, noremap = true },
        },

        config = function()
            require("markdown_preview").setup({
                port = 8421,
                open_browser = true,
                debounce_ms = 300,
            })
        end,
    },

    ---------------------------------------------------------------------------
    -- Otter: LSP in fenced code blocks
    ---------------------------------------------------------------------------
    {
        "jmbuhr/otter.nvim",
        ft = { "markdown", "rmd", "quarto", "qmd" },
        dependencies = {
            "folke/which-key.nvim",
            "nvim-treesitter/nvim-treesitter",
            { "AckslD/nvim-FeMaco.lua", cmd = "FeMaco" },
        },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>m", group = "Markdown" } })
            end
        end,

        opts = {
            lsp = {
                diagnostic_update_events = { "BufWritePost", "InsertLeave" },
                root_dir = function(_, bufnr)
                    return vim.fs.root(bufnr or 0, { ".git", "pyproject.toml", "package.json", "_quarto.yml" })
                        or vim.uv.cwd()
                end,
            },
            buffers = { set_filetype = true, write_to_disk = false },
            handle_leading_whitespace = true,
        },

        keys = {
            { "<leader>ma", function() require("otter").activate(nil, true, true) end, desc = "Otter activate",   mode = "n", ft = { "markdown", "rmd", "quarto", "qmd" }, silent = true, noremap = true },
            { "<leader>me", "<cmd>FeMaco<CR>",                                         desc = "Otter edit block",  mode = "n", ft = { "markdown", "rmd", "quarto", "qmd" }, silent = true, noremap = true },
            { "<leader>mx", function() require("otter").export() end,                  desc = "Otter export",      mode = "n", ft = { "markdown", "rmd", "quarto", "qmd" }, silent = true, noremap = true },
            { "<leader>mX", function() require("otter").export_otter_as() end,         desc = "Otter export as",   mode = "n", ft = { "markdown", "rmd", "quarto", "qmd" }, silent = true, noremap = true },
        },

        config = function(_, opts)
            local otter = require("otter")
            otter.setup(opts)

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "markdown", "rmd", "quarto", "qmd" },
                callback = function(args)
                    local bufnr = args.buf
                    local bt = vim.bo[bufnr].buftype
                    if bt ~= "" then return end
                    if vim.api.nvim_buf_get_name(bufnr) == "" then return end

                    local win = vim.fn.bufwinid(bufnr)
                    if win ~= -1 then
                        local cfg = vim.api.nvim_win_get_config(win)
                        if cfg and cfg.relative and cfg.relative ~= "" then return end
                    end

                    if vim.b[bufnr].otter_activated then return end
                    vim.b[bufnr].otter_activated = true

                    pcall(function() require("otter").activate(nil, true, true) end)
                end,
            })
        end,
    },
}
