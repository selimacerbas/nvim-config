return {

    -- LSP configuration with Mason for managing LSP servers
    {
        'williamboman/mason.nvim',
        dependencies = {
            'williamboman/mason-lspconfig.nvim', -- Bridge between mason.nvim and nvim-lspconfig
            'neovim/nvim-lspconfig',             -- LSP configurations
            'b0o/schemastore.nvim',              -- JSON/YAML Schema Store
            'nvimtools/none-ls.nvim',            -- None-ls integration
            'jayp0521/mason-null-ls.nvim',       -- Manage null-ls tools via Mason
            'jose-elias-alvarez/null-ls.nvim',
            "mfussenegger/nvim-dap",             -- Required for debugging functionality
            "jayp0521/mason-nvim-dap.nvim",      -- Bridge for Mason and nvim-dap
            'towolf/vim-helm',                   -- Ensure Helm syntax highlighting is available
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "rust_analyzer", -- Rust
                    "clangd",        -- C, C++
                    "terraformls",   -- Terraform
                    "pyright",       -- Python
                    "jsonls",        -- JSON
                    "yamlls",        -- YAML
                    "ts_ls",         -- JavaScript, TypeScript
                    "lua_ls",        -- Lua
                    "gopls",         -- Go
                    "dockerls",      -- Docker
                    "bashls",        -- Bash
                    "helm_ls",       -- Helm
                    "html",          -- HTML
                    "lemminx",       -- XML
                    "cmake",         -- CMake
                    "bzl",           -- Starlark
                },
                automatic_installation = true
            })

            require("mason-null-ls").setup({
                ensure_installed = {
                    "yamlfmt",       -- YAML Formatter
                    "yamllint",      -- YAML Linter
                    "jsonlint",      -- JSON Linter
                    "fixjson",       -- JSON Formatter
                    "flake8",        -- Python Linter
                    "black",         -- Python Formatter
                    "golangci-lint", -- Go Linter
                    "gci",           -- Go Formatter
                    "dcm",           -- Dart Linter/Formatter
                    "shellharden",   -- Shell Linter/Formatter
                    "tflint",        -- Terraform Linter
                    "hcl",           -- HCL Formatter

                },
                automatic_installation = true, -- Automatically install tools if not present
            })

            -----------------------
            -- Lint & Formatters --
            -----------------------
            require("null-ls").setup({
                sources = {
                    -- Python
                    require("null-ls").builtins.diagnostics.flake8.with({
                        args = { "--config", vim.fn.stdpath("config") .. "/lua/custom/lazy-plugins/lint-config/flake8-config.ini" },
                    }),                                           -- Python Linter
                    require("null-ls").builtins.formatting.black, -- Python Formatter

                    -- YAML
                    require("null-ls").builtins.diagnostics.yamllint.with({
                        args = { "-c", vim.fn.stdpath("config") .. "/lua/custom/lazy-plugins/lint-config/yamllint-config.yaml", "-" },
                    }),                                             -- YAML Linter
                    require("null-ls").builtins.formatting.yamlfmt, -- YAML Formatter

                    -- JSON
                    require("null-ls").builtins.diagnostics.jsonlint, -- JSON Linter
                    require("null-ls").builtins.formatting.fixjson,   -- JSON Formatter

                    -- Go
                    require("null-ls").builtins.diagnostics.golangci_lint, -- Go Linter

                    -- Shell
                    require("null-ls").builtins.diagnostics.shellcheck, -- Shell Linter
                    require("null-ls").builtins.formatting.shellharden, -- Shell Formatter

                },
            })
            ------------------------
            -- Configure the LSPs --
            ------------------------
            local lspconfig = require('lspconfig')
            local schemastore = require('schemastore')

            -- Existing LSP configurations
            lspconfig.rust_analyzer.setup {
                settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = {
                            command = "clippy", -- Optional: Run `clippy` during save
                        },
                        diagnostics = {
                            enable = true,
                        },
                        cargo = {
                            allFeatures = true,
                        },
                        rustfmt = {
                            enable = true,
                        },
                    },
                },
            }

            lspconfig.terraformls.setup {
                filetypes = { "terraform", "tf", "tfvars", },
            }

            lspconfig.jsonls.setup {
                settings = {
                    json = {
                        schemas = schemastore.json.schemas(),
                        validate = { enable = true },
                    },
                },
            }
            lspconfig.yamlls.setup {
                filetypes = { "Kptfile" },
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
            lspconfig.bzl.setup {
                filetypes = { "star" },
            }
            lspconfig.clangd.setup {}
            lspconfig.pyright.setup {}
            lspconfig.ts_ls.setup {}
            lspconfig.lua_ls.setup {}
            lspconfig.gopls.setup {}
            lspconfig.dockerls.setup {}
            lspconfig.bashls.setup {}
            lspconfig.helm_ls.setup {}
            lspconfig.html.setup {}
            lspconfig.lemminx.setup {}
            lspconfig.cmake.setup {}
        end
    },

    -- Add more plugins below as needed
}
