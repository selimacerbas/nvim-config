return {
    {
        "neovim/nvim-lspconfig",
        dependencies = { "folke/which-key.nvim" },
        config = function()
            -- ===== Diagnostic UI =====
            local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }
            vim.diagnostic.config({
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = icons.Error,
                        [vim.diagnostic.severity.WARN]  = icons.Warn,
                        [vim.diagnostic.severity.HINT]  = icons.Hint,
                        [vim.diagnostic.severity.INFO]  = icons.Info,
                    },
                },
                virtual_text = { spacing = 2, prefix = "●" },
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
            })

            -- ===== Capabilities (augment via cmp if present) =====
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            pcall(function()
                capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
            end)
            vim.lsp.config("*", { capabilities = capabilities })

            -- ===== Buffer-local on LspAttach =====
            -- Sets buffer options, LSP g-motion keymaps, and inlay hints.
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr  = args.buf
                    local client = vim.lsp.get_client_by_id(args.data.client_id)

                    vim.bo[bufnr].omnifunc   = "v:lua.vim.lsp.omnifunc"
                    vim.bo[bufnr].tagfunc    = "v:lua.vim.lsp.tagfunc"
                    vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"

                    -- Buffer-local LSP navigation (only active when LSP is attached)
                    local function bmap(lhs, rhs, desc)
                        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
                    end
                    bmap("gd", "<cmd>Lspsaga goto_definition<CR>",  "Go to definition")
                    bmap("gD", "<cmd>Lspsaga goto_declaration<CR>", "Go to declaration")
                    bmap("gh", "<cmd>Lspsaga finder<CR>",           "Finder (refs+impl)")
                    bmap("gi", vim.lsp.buf.implementation,          "Go to implementation")
                    bmap("gr", vim.lsp.buf.references,              "List references")
                    bmap("K",  "<cmd>Lspsaga hover_doc ++silent<CR>", "Hover doc")

                    -- Disable hover for linter/formatter-only servers so Lspsaga
                    -- doesn't show "No information available" from them
                    if client and vim.tbl_contains({ "ruff", "copilot" }, client.name) then
                        client.server_capabilities.hoverProvider = false
                    end

                    -- Inlay hints if supported
                    if client and client.server_capabilities.inlayHintProvider then
                        vim.b[bufnr]._ih_enabled = true
                        pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
                    end
                end,
            })

            -- Toggle inlay hints
            vim.api.nvim_create_user_command("LspToggleInlayHints", function()
                local buf = vim.api.nvim_get_current_buf()
                local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
                vim.lsp.inlay_hint.enable(not enabled, { bufnr = buf })
                vim.b[buf]._ih_enabled = not enabled
                vim.notify("Inlay hints: " .. (not enabled and "ON" or "OFF"))
            end, {})
        end,
    },
}
