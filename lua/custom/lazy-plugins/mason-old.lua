return {

    -- LSP configuration with Mason for managing LSP servers
    {
        'williamboman/mason.nvim',
        dependencies = {
            'williamboman/mason-lspconfig.nvim', -- Bridge between mason.nvim and nvim-lspconfig
            'neovim/nvim-lspconfig',             -- LSP configurations
            'nvimtools/none-ls.nvim',            -- None-ls integration
            "nvimtools/none-ls-extras.nvim",
            'jay-babu/mason-null-ls.nvim',       -- Manage null-ls tools via Mason
            "mfussenegger/nvim-dap",             -- Required for debugging functionality
            "jay-babu/mason-nvim-dap.nvim",      -- Bridge for Mason and nvim-dap
            'towolf/vim-helm',                   -- Ensure Helm syntax highlighting is available
            'b0o/schemastore.nvim',              -- JSON/YAML Schema Store
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
                    "texlab"         -- LaTeX
                },
                automatic_installation = true
            })

            require("mason-null-ls").setup({
                ensure_installed = {
                    "yamlfix",       -- YAML Formatter
                    "yamllint",      -- YAML Linter
                    "jsonlint",      -- JSON Linter
                    "fixjson",       -- JSON Formatter
                    "flake8",        -- Python Linter
                    "black",         -- Python Formatter
                    "golangci-lint", -- Go Linter
                    "gci",           -- Go Formatter
                    "dcm",           -- Dart Linter/Formatter
                    "shellharden",   -- Shell Formatter
                    "shellcheck",    -- Shell Linter
                    "tflint",        -- Terraform Linter
                    "hcl",           -- HCL Formatter
                    "vale",          -- LaTeX Linter
                    "tex-fmt",       -- LaTeX Formatter

                },
                automatic_installation = true, -- Automatically install tools if not present
            })

            local null_ls = require("null-ls") -- Make sure you're using the correct module for `nvimtools/none-ls.nvim`

            null_ls.setup({
                sources = {
                    -- Python
                    null_ls.builtins.formatting.black,
                    null_ls.builtins.diagnostics.flake8,

                    -- YAML
                    null_ls.builtins.formatting.yamlfix,
                    null_ls.builtins.diagnostics.yamllint,

                    -- JSON
                    null_ls.builtins.formatting.fixjson,
                    null_ls.builtins.diagnostics.jsonlint,

                    -- Shell
                    null_ls.builtins.formatting.shellharden,
                    null_ls.builtins.diagnostics.shellcheck,

                    -- Go
                    null_ls.builtins.formatting.gci,
                    null_ls.builtins.diagnostics.golangci_lint,

                    -- Terraform
                    null_ls.builtins.diagnostics.tflint,

                    -- LaTeX (linting only)
                    null_ls.builtins.diagnostics.vale,
                },

                -- Just attach formatter capability, no formatting on save
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")
                    end
                end,
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
            lspconfig.bzl.setup {
                filetypes = { "star" },
            }
            lspconfig.texlab.setup {}
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
