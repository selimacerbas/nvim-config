return {
    {
        'williamboman/mason.nvim',
        dependencies = {
            -- LSP Core
            'williamboman/mason-lspconfig.nvim',
            'neovim/nvim-lspconfig',
            'b0o/schemastore.nvim',

            -- DAP
            'mfussenegger/nvim-dap',
            'jayp0521/mason-nvim-dap.nvim',

            -- Helm
            'towolf/vim-helm',

            -- ✅ FORMATTER + LINTER
            'stevearc/conform.nvim',      -- Formatting
            'zapling/mason-conform.nvim', -- Bridge for Conform
            'mfussenegger/nvim-lint',     -- Linting
            'rshkarin/mason-nvim-lint',   -- Bridge for nvim-lint
        },

        config = function()
            ---------------------
            -- Mason Setup
            ---------------------
            require("mason").setup()

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "rust_analyzer",
                    "clangd",
                    "terraformls",
                    "pyright",
                    "jsonls",
                    "yamlls",
                    "ts_ls",
                    "lua_ls",
                    "gopls",
                    "dockerls",
                    "bashls",
                    "helm_ls",
                    "html",
                    "lemminx",
                    "cmake",
                    "bzl",
                    "texlab",
                },
                automatic_installation = true
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
                    go = { "gofumpt" },
                },
            })

            require("mason-conform").setup({
                ensure_installed = {
                    "ruff",
                    "yamlfmt",
                    "fixjson",
                    "stylua",
                    "shfmt",
                    "prettier",
                    "gofumpt",
                },
            })

            ---------------------
            -- Linting: nvim-lint
            ---------------------
            local lint = require("lint")
            lint.linters_by_ft = {
                python = { "ruff" },
                yaml = { "yamllint" },
                json = { "jsonlint" },
                terraform = { "tflint" },
                sh = { "shellcheck" },
                go = { "golangcilint" },
            }

            require("mason-nvim-lint").setup({
                ensure_installed = {
                    "ruff",
                    "yamllint",
                    "jsonlint",
                    "tflint",
                    "shellcheck",
                    "golangci-lint",
                },
                automatic_installation = true,
            })

            -- Automatically trigger linting
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
                callback = function()
                    require("lint").try_lint()
                end,
            })

            ---------------------
            -- LSP Setup
            ---------------------
            local lspconfig = require('lspconfig')
            local schemastore = require('schemastore')

            lspconfig.rust_analyzer.setup {
                settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = { command = "clippy" },
                        diagnostics = { enable = true },
                        cargo = { allFeatures = true },
                        rustfmt = { enable = true },
                    },
                },
            }

            lspconfig.terraformls.setup { filetypes = { "terraform", "tf", "tfvars" } }

            lspconfig.jsonls.setup {
                settings = {
                    json = {
                        schemas = schemastore.json.schemas(),
                        validate = { enable = true },
                    },
                },
            }

            lspconfig.yamlls.setup {
                filetypes = { "Kptfile", "yaml", "yml" },
                settings = {
                    yaml = {
                        schemas = vim.tbl_extend("force", schemastore.yaml.schemas(), {
                            ["https://raw.githubusercontent.com/GoogleContainerTools/kpt/main/site/reference/schema/kptfile/kptfile.yaml"] = "Kptfile",
                            ["https://json.schemastore.org/chart.json"] = "Chart.yaml",
                        }),
                        validate = true,
                        hover = true,
                        completion = true,
                    },
                },
            }

            -- Other LSPs
            lspconfig.bzl.setup { filetypes = { "star" } }
            lspconfig.texlab.setup {}
            lspconfig.clangd.setup {}
            lspconfig.pyright.setup {}
            lspconfig.ts_ls.setup {}
            lspconfig.lua_ls.setup {}
            -- lspconfig.gopls.setup {}   -- This was causing duplications with "gd" command.
            lspconfig.dockerls.setup {}
            lspconfig.bashls.setup {}
            lspconfig.helm_ls.setup {}
            lspconfig.html.setup {}
            lspconfig.lemminx.setup {}
            lspconfig.cmake.setup {}
        end,
    },
}
