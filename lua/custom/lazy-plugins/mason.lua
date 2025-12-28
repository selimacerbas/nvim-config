return {
    {
        "mason-org/mason.nvim",
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

        -- Load after UI is ready but before user interaction
        event = "VeryLazy",

        -- only the two keymaps you asked for
        keys = {
            { "<leader>lc", "<cmd>LspDedupeHere<CR>",  desc = "LSP: Dedupe (buf)", mode = "n", silent = true, noremap = true },
            { "<leader>lT", "<cmd>LintAutoToggle<CR>", desc = "Lint: Toggle Auto", mode = "n", silent = true, noremap = true },
        },

        config = function()
            ----------------------------------------------------------------
            -- Mason core
            ----------------------------------------------------------------
            require("mason").setup({})

            ----------------------------------------------------------------
            -- LSP install list (mason-lspconfig)
            ----------------------------------------------------------------
            local mlsp = require("mason-lspconfig")

            local servers = {
                "rust_analyzer", "clangd", "terraformls", "pyright", "jsonls", "yamlls",
                "ts_ls", "lua_ls", "gopls", "dockerls", "bashls", "helm_ls", "html",
                "lemminx", "cmake", "texlab", "cssls",
                "ruff",
            }

            mlsp.setup({
                ensure_installed = servers,
                automatic_installation = true,
            })

            ----------------------------------------------------------------
            -- Shared capabilities / helpers (0.11+ API with 0.10 fallback)
            ----------------------------------------------------------------
            local schemastore = require("schemastore")
            local caps = require("cmp_nvim_lsp").default_capabilities()
            local use_new = (vim.fn.has("nvim-0.11") == 1) and (type(vim.lsp.config) == "table")

            vim.g._lsp_configured = vim.g._lsp_configured or {}
            local function mark_configured(server) vim.g._lsp_configured[server] = true end
            local function already(server)
                if vim.g._lsp_configured[server] then return true end
                return use_new and (vim.lsp.config[server] ~= nil) or false
            end

            local function on_attach(_, _) end

            local function apply_server(server, conf)
                if use_new then
                    vim.lsp.config[server] = vim.tbl_deep_extend("force", vim.lsp.config[server] or {}, conf)
                else
                    require("lspconfig")[server].setup(conf)
                end
                mark_configured(server)
            end

            local function setup_server(server)
                if already(server) then return end

                local opts = {
                    capabilities = caps,
                    on_attach = on_attach,
                }

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
                            format = { enable = false }, -- use conform
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
                    }
                elseif server == "clangd" then
                    opts.cmd = { "clangd", "--background-index", "--header-insertion=never", "--clang-tidy" }
                elseif server == "terraformls" then
                    opts.filetypes = { "terraform", "terraform-vars", "tf", "tfvars", "hcl" }
                elseif server == "html" then
                    opts.filetypes = { "html", "templ" }
                elseif server == "ruff" then
                    opts.init_options = { settings = { args = {} } }
                end

                apply_server(server, opts)
            end

            if type(mlsp.setup_handlers) == "function" then
                mlsp.setup_handlers({
                    function(server) setup_server(server) end,
                })
            elseif type(mlsp.get_installed_servers) == "function" then
                for _, server in ipairs(mlsp.get_installed_servers()) do
                    setup_server(server)
                end
            else
                for _, server in ipairs(servers) do
                    setup_server(server)
                end
            end

            ----------------------------------------------------------------
            -- Kill duplicate clients per buffer on attach
            ----------------------------------------------------------------
            vim.g.lsp_dedupe_on_attach = true
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("LspDedupe", { clear = true }),
                callback = function(args)
                    if not vim.g.lsp_dedupe_on_attach then return end
                    local bufnr = args.buf
                    local seen = {}
                    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                        local key = client.name .. "::" .. (client.config.root_dir or "")
                        if seen[key] then client.stop(true) else seen[key] = true end
                    end
                end,
            })

            -- User command used by <leader>lc
            vim.api.nvim_create_user_command("LspDedupeHere", function()
                local bufnr = vim.api.nvim_get_current_buf()
                local seen, killed = {}, {}
                for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                    local key = c.name .. "::" .. (c.config.root_dir or "")
                    if seen[key] then
                        c.stop(true); table.insert(killed, c.name)
                    else
                        seen[key] = true
                    end
                end
                vim.notify(#killed > 0 and ("Stopped: " .. table.concat(killed, ", ")) or "No duplicates",
                    vim.log.levels.INFO, { title = "LSP dedupe" })
            end, {})

            ----------------------------------------------------------------
            -- DAP via Mason (unchanged)
            ----------------------------------------------------------------
            require("mason-nvim-dap").setup({
                ensure_installed = { "codelldb", "cpptools", "debugpy", "delve", "js-debug-adapter" },
                automatic_installation = true,
            })

            ----------------------------------------------------------------
            -- Formatting: Conform (unchanged)
            ----------------------------------------------------------------
            require("conform").setup({
                formatters_by_ft = {
                    python          = { "ruff_format" },
                    yaml            = { "yamlfmt" },
                    json            = { "fixjson" },
                    sh              = { "shfmt" },
                    lua             = { "luaformatter" },
                    javascript      = { "prettier" },
                    typescript      = { "prettier" },
                    typescriptreact = { "prettier" },
                    javascriptreact = { "prettier" },
                    go              = { "gofumpt" },
                    html            = { "prettier" },
                    css             = { "prettier" },
                    markdown        = { "prettier" },
                },
            })

            require("mason-conform").setup({
                ensure_installed = { "ruff", "yamlfmt", "fixjson", "luaformatter", "shfmt", "prettier", "gofumpt" },
                automatic_installation = true,
            })

            ----------------------------------------------------------------
            -- Linting: nvim-lint + auto-lint toggle
            ----------------------------------------------------------------
            local lint = require("lint")
            lint.linters_by_ft = {
                python    = { "ruff" },
                yaml      = { "yamllint" },
                json      = { "jsonlint" },
                terraform = { "tflint" },
                sh        = { "shellcheck" },
                go        = { "golangcilint" },
            }

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

            -- default ON
            enable_autolint()

            -- User command used by <leader>lT
            vim.api.nvim_create_user_command("LintAutoToggle", function()
                if vim.g.autolint_enabled then disable_autolint() else enable_autolint() end
            end, {})

            ----------------------------------------------------------------
            -- mason-nvim-lint (disabled auto install)
            ----------------------------------------------------------------
            local ok_mnl, mnl = pcall(require, "mason-nvim-lint")
            if ok_mnl then
                mnl.setup({
                    ensure_installed       = {},
                    automatic_installation = false,
                    ignore_install         = { "golangcilint", "jsonlint" },
                })
            end

            ----------------------------------------------------------------
            -- Tool installation via mason-tool-installer (unchanged)
            ----------------------------------------------------------------
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "ruff", "yamllint", "jsonlint", "tflint", "shellcheck", "golangci-lint",
                },
                auto_update      = false,
                run_on_start     = true,
                start_delay      = 300,
                debounce_hours   = 0,
            })
        end,
    },
}
