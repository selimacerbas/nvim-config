return {
    {
        "neovim/nvim-lspconfig",
        dependencies = { "folke/which-key.nvim" },
        config = function()
            local lspconfig = require("lspconfig")

            -- ===== Global LSP UI =====
            ---- ===== Diagnostic signs (0.11+ API, with 0.10 fallback) =====
            local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }
            if vim.fn.has("nvim-0.11") == 1 then
                -- Neovim 0.11+: configure signs via vim.diagnostic.config
                vim.diagnostic.config({
                    signs = {
                        text = {
                            [vim.diagnostic.severity.ERROR] = icons.Error,
                            [vim.diagnostic.severity.WARN]  = icons.Warn,
                            [vim.diagnostic.severity.HINT]  = icons.Hint,
                            [vim.diagnostic.severity.INFO]  = icons.Info,
                        },
                        -- you can also set numhl/texthl here if you want:
                        -- numhl = {
                        --   [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
                        --   [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
                        --   [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
                        --   [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
                        -- },
                    },
                    virtual_text = { spacing = 2, prefix = "●" },
                    underline = true,
                    update_in_insert = false,
                    severity_sort = true,
                    float = { border = "rounded", source = "if_many" },
                })
            else
                -- Neovim 0.10.x: define DiagnosticSign* groups explicitly
                for t, icon in pairs(icons) do
                    local hl = "DiagnosticSign" .. t
                    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
                end
                vim.diagnostic.config({
                    signs = true,
                    virtual_text = { spacing = 2, prefix = "●" },
                    underline = true,
                    update_in_insert = false,
                    severity_sort = true,
                    float = { border = "rounded", source = "if_many" },
                })
            end
            local border = "rounded"
            vim.lsp.handlers["textDocument/hover"] =
                vim.lsp.with(vim.lsp.handlers.hover, { border = border })
            vim.lsp.handlers["textDocument/signatureHelp"] =
                vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })

            -- ===== Capabilities (with cmp if present) =====
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            pcall(function() capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities) end)

            -- ===== Inlay hints compat (0.10 function vs 0.11+ table) =====
            local function ih_enable(buf, enable)
                local ih = vim.lsp.inlay_hint
                if type(ih) == "function" then
                    -- Neovim 0.10
                    pcall(ih, buf, enable)
                elseif type(ih) == "table" and ih.enable then
                    -- Neovim 0.11+
                    -- common signature: enable(bufnr, true/false)
                    local ok = pcall(ih.enable, buf, enable)
                    if not ok then
                        -- some nightlies used enable(true, { bufnr = N })
                        pcall(ih.enable, true, { bufnr = buf })
                    end
                end
            end

            local function ih_is_enabled(buf)
                local ih = vim.lsp.inlay_hint
                if type(ih) == "table" and ih.is_enabled then
                    local ok, res = pcall(ih.is_enabled, buf)
                    if ok then return res end
                end
                return vim.b[buf]._ih_enabled == true
            end

            -- ===== Buffer-local on LspAttach =====
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr              = args.buf
                    local client             = vim.lsp.get_client_by_id(args.data.client_id)

                    vim.bo[bufnr].omnifunc   = "v:lua.vim.lsp.omnifunc"
                    vim.bo[bufnr].tagfunc    = "v:lua.vim.lsp.tagfunc"
                    vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"

                    -- Inlay hints if supported
                    if client and client.server_capabilities.inlayHintProvider then
                        vim.b[bufnr]._ih_enabled = true
                        ih_enable(bufnr, true)
                    end

                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                    end
                    local has_saga = package.loaded["lspsaga"] ~= nil

                    -- Hover
                    if has_saga then
                        map("n", "K", "<cmd>Lspsaga hover_doc<CR>", "Hover Documentation")
                    else
                        map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
                    end

                    -- Go-to
                    if has_saga then
                        map("n", "gd", "<cmd>Lspsaga goto_definition<CR>", "Go to Definition")
                        map("n", "gD", "<cmd>Lspsaga goto_declaration<CR>", "Go to Declaration")
                        map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
                    else
                        map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
                        map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
                        map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
                    end

                    map("n", "gr", vim.lsp.buf.references, "List References")

                    -- Diagnostics (preserve ]c/[c for gitsigns)
                    map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
                    map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
                    map("n", "<C-W>d", vim.diagnostic.open_float, "Line Diagnostics")


                    -- Insert-mode which-key hints
                    local ok, wk = pcall(require, "which-key")
                    if ok then
                        if wk.add then
                            -- which-key v3 style (array of specs)
                            wk.add({
                                { "<C-n>",      desc = "Next Completion",   mode = "i", buffer = bufnr },
                                { "<C-p>",      desc = "Prev Completion",   mode = "i", buffer = bufnr },

                                -- Group header so <C-x> shows a menu in insert mode
                                { "<C-x>",      group = "Complete (<C-x>)", mode = "i", buffer = bufnr },
                                { "<C-x><C-o>", desc = "Omni (LSP)",        mode = "i", buffer = bufnr },
                                { "<C-x><C-f>", desc = "File Name",         mode = "i", buffer = bufnr },
                                { "<C-x><C-d>", desc = "Dictionary",        mode = "i", buffer = bufnr },
                                { "<C-x><C-t>", desc = "Tag",               mode = "i", buffer = bufnr },
                                { "<C-x>=",     desc = "Spelling",          mode = "i", buffer = bufnr },
                            })
                        else
                            -- which-key v2 fallback (table + prefix)
                            wk.register({
                                ["<C-n>"] = "Next Completion",
                                ["<C-p>"] = "Prev Completion",
                            }, { mode = "i", buffer = bufnr })

                            wk.register({
                                name  = "Complete (<C-x>)",
                                o     = { "<C-x><C-o>", "Omni (LSP)" },
                                f     = { "<C-x><C-f>", "File Name" },
                                d     = { "<C-x><C-d>", "Dictionary" },
                                t     = { "<C-x><C-t>", "Tag" },
                                ["="] = { "<C-x>=", "Spelling" },
                            }, { mode = "i", prefix = "<C-x>", buffer = bufnr })
                        end
                    end
                end,
            })

            -- Toggle inlay hints (works on both 0.10 & 0.11+)
            vim.api.nvim_create_user_command("LspToggleInlayHints", function()
                local buf = vim.api.nvim_get_current_buf()
                local enabled = ih_is_enabled(buf)
                ih_enable(buf, not enabled)
                vim.b[buf]._ih_enabled = not enabled
                vim.notify("Inlay hints: " .. ((not enabled) and "ON" or "OFF"))
            end, {})

            -- NOTE: server setup is handled in your Mason config; no lspconfig.setup calls here.
        end,
    },
}
