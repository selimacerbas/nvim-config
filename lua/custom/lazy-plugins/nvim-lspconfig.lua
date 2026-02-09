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
            if type(vim.lsp.config) == "table" then
                vim.lsp.config.capabilities =
                    vim.tbl_deep_extend("force", vim.lsp.config.capabilities or {}, capabilities)
            end

            -- ===== Buffer-local on LspAttach =====
            -- Only sets buffer options and inlay hints.
            -- All keymaps are owned by lspsaga.lua.
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr  = args.buf
                    local client = vim.lsp.get_client_by_id(args.data.client_id)

                    vim.bo[bufnr].omnifunc   = "v:lua.vim.lsp.omnifunc"
                    vim.bo[bufnr].tagfunc    = "v:lua.vim.lsp.tagfunc"
                    vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"

                    -- Override Neovim 0.10+ default K so Lspsaga hover_doc runs instead
                    vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>",
                        { buffer = bufnr, desc = "Hover doc", silent = true })

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
