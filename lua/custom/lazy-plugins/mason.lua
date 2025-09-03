return {
    {
        "williamboman/mason.nvim",
        dependencies = {
            -- LSP Core
            "mason-org/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
            "b0o/schemastore.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",

            -- DAP
            "mfussenegger/nvim-dap",
            "jayp0521/mason-nvim-dap.nvim",

            -- Helm
            "towolf/vim-helm",

            -- Format / Lint
            "stevearc/conform.nvim",
            "zapling/mason-conform.nvim",
            "mfussenegger/nvim-lint",
            "rshkarin/mason-nvim-lint",

            -- UX
            "folke/which-key.nvim",
        },

        config = function()
            ---------------------
            -- Mason core
            ---------------------
            require("mason").setup({})

            ---------------------
            -- LSP: install list (cover both tsserver/ts_ls)
            ---------------------
            local mlsp = require("mason-lspconfig")
            mlsp.setup({
                ensure_installed = {
                    "rust_analyzer",
                    "clangd",
                    "terraformls",
                    "pyright",
                    "jsonls",
                    "yamlls",
                    "ts_ls", -- new name in lspconfig
                    "lua_ls",
                    "gopls",
                    "dockerls",
                    "bashls",
                    "helm_ls",
                    "html",
                    "lemminx",
                    "cmake",
                    "texlab",
                },
                automatic_installation = true,
            })

            local lspconfig   = require("lspconfig")
            local schemastore = require("schemastore")
            local caps        = require("cmp_nvim_lsp").default_capabilities()

            local function on_attach(_, _)
                -- keep empty to avoid clashing with lspsaga keymaps
            end

            -- per-server setup builder
            local function setup_server(server)
                if not lspconfig[server] then return end
                local opts = { capabilities = caps, on_attach = on_attach }

                if server == "jsonls" then
                    opts.settings = {
                        json = {
                            schemas = schemastore.json.schemas(),
                            validate = { enable = true },
                        },
                    }
                elseif server == "yamlls" then
                    opts.settings = {
                        yaml = {
                            schemas = schemastore.yaml.schemas(),
                            keyOrdering = false,
                            format = { enable = true },
                        },
                    }
                elseif server == "lua_ls" then
                    opts.settings = {
                        Lua = {
                            workspace = { checkThirdParty = false },
                            telemetry = { enable = false },
                            diagnostics = { globals = { "vim" } },
                            format = { enable = false }, -- use stylua via conform
                        },
                    }
                elseif server == "gopls" then
                    opts.settings = {
                        gopls = {
                            gofumpt = true,
                            usePlaceholders = true,
                            analyses = { unusedparams = true, shadow = true },
                            staticcheck = true,
                        },
                    }
                elseif server == "tsserver" or server == "ts_ls" then
                    opts.single_file_support = true
                    opts.settings = {
                        typescript = { format = { enable = false } },
                        javascript = { format = { enable = false } },
                    } -- prettier via conform
                elseif server == "clangd" then
                    opts.cmd = { "clangd", "--background-index", "--header-insertion=never", "--clang-tidy" }
                elseif server == "terraformls" then
                    opts.filetypes = { "terraform", "terraform-vars", "tf", "tfvars", "hcl" }
                elseif server == "html" then
                    opts.filetypes = { "html", "templ" } -- include templ if you use it
                end

                lspconfig[server].setup(opts)
            end

            -- ✅ robust handler: use setup_handlers if present, else fallback loop
            if type(mlsp.setup_handlers) == "function" then
                mlsp.setup_handlers({
                    function(server) setup_server(server) end,
                })
            else
                -- older mason-lspconfig: configure the servers that are already installed
                for _, server in ipairs(mlsp.get_installed_servers() or {}) do
                    setup_server(server)
                end
            end

            ---------------------
            -- DAP via Mason
            ---------------------
            require("mason-nvim-dap").setup({
                ensure_installed = { "codelldb", "cpptools", "debugpy", "delve", "js-debug-adapter" },
                automatic_installation = true,
            })

            ---------------------
            -- Formatting: Conform
            ---------------------
            require("conform").setup({
                formatters_by_ft = {
                    python = { "ruff_format" },
                    yaml = { "yamlfmt" },
                    json = { "fixjson" },
                    lua = { "stylua" },
                    sh = { "shfmt" },
                    javascript = { "prettier" },
                    typescript = { "prettier" },
                    typescriptreact = { "prettier" },
                    javascriptreact = { "prettier" },
                    go = { "gofumpt" },
                    html = { "prettier" },
                    css = { "prettier" },
                    markdown = { "prettier" },
                },
            })

            require("mason-conform").setup({
                ensure_installed = { "ruff", "yamlfmt", "fixjson", "stylua", "shfmt", "prettier", "gofumpt" },
                automatic_installation = true,
            })


            ---------------------
            -- Linting: nvim-lint (load first)
            ---------------------
            local lint = require("lint")

            -- Keep nvim-lint's own IDs (note: "golangcilint" is the nvim-lint id)
            lint.linters_by_ft = {
                python    = { "ruff" },
                yaml      = { "yamllint" },
                json      = { "jsonlint" },
                terraform = { "tflint" },
                sh        = { "shellcheck" },
                go        = { "golangcilint" },
            }

            ---------------------
            -- Install tools via mason-tool-installer (explicit Mason names)
            ---------------------
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "ruff",     -- linter (also formatter)
                    "yamllint",
                    "jsonlint", -- ⚠️ optional: only include if you actually see it in :Mason
                    "tflint",
                    "shellcheck",
                    "golangci-lint",
                },
                auto_update      = false,
                run_on_start     = true,
                start_delay      = 300, -- ms after UI starts
                debounce_hours   = 0,   -- install every start if missing
            })

            ---------------------
            -- mason-nvim-lint (disable its auto-scanner completely)
            ---------------------
            local ok_mnl, mnl = pcall(require, "mason-nvim-lint")
            if ok_mnl then
                mnl.setup({
                    ensure_installed       = {},                             -- <- nothing here
                    automatic_installation = false,                          -- <- do not scan or map linters
                    ignore_install         = { "golangcilint", "jsonlint" }, -- belt & suspenders
                })
            end

            -- Auto-lint (unchanged)
            local grp = vim.api.nvim_create_augroup("UserLintAutocmds", { clear = true })
            vim.g.autolint_enabled = true
            local function enable_autolint()
                vim.g.autolint_enabled = true
                vim.api.nvim_clear_autocmds({ group = grp })
                vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
                    group = grp,
                    callback = function() require("lint").try_lint() end,
                })
                vim.notify("nvim-lint: auto-lint ON")
            end
            local function disable_autolint()
                vim.g.autolint_enabled = false
                vim.api.nvim_clear_autocmds({ group = grp })
                vim.notify("nvim-lint: auto-lint OFF")
            end
            enable_autolint()


            -- which-key: small admin block under <leader>l (doesn’t clash with Saga)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    -- { "<leader>l",  group = "LSP" },
                    { "<leader>lm", "<cmd>Mason<CR>",                          desc = "Mason UI" },
                    { "<leader>lI", "<cmd>LspInfo<CR>",                        desc = "LSP Info" },
                    { "<leader>lX", "<cmd>LspRestart<CR>",                     desc = "LSP Restart" },
                    { "<leader>ll", function() require("lint").try_lint() end, desc = "Lint: Run Now" },
                    {
                        "<leader>lT",
                        function()
                            if vim.g.autolint_enabled then disable_autolint() else enable_autolint() end
                        end,
                        desc = "Lint: Toggle Auto"
                    },
                }, { mode = "n", silent = true, noremap = true })
            end
        end,
    },
}
