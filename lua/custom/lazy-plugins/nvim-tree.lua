return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "folke/which-key.nvim",
        },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>n", group = "NvimTree" } })
            end
            -- Auto-open tree on startup (only when no file arguments)
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    if vim.fn.argc() == 0 then
                        vim.schedule(function() vim.cmd("NvimTreeOpen") end)
                    end
                end,
            })
        end,

        cmd = {
            "NvimTreeToggle", "NvimTreeOpen", "NvimTreeClose", "NvimTreeRefresh",
            "NvimTreeFindFile", "NvimTreeCollapse", "NvimTreeResize",
            "NvimTreeCreate", "NvimTreeRemove", "NvimTreeRename",
            "NvimTreeCopy", "NvimTreeCut", "NvimTreePaste",
        },

        keys = {
            { "<leader>nt", "<cmd>NvimTreeToggle<CR>",   desc = "Toggle",       mode = "n", silent = true },
            { "<leader>no", "<cmd>NvimTreeOpen<CR>",     desc = "Open",         mode = "n", silent = true },
            { "<leader>nc", "<cmd>NvimTreeClose<CR>",    desc = "Close",        mode = "n", silent = true },
            { "<leader>nC", "<cmd>NvimTreeCollapse<CR>", desc = "Collapse All", mode = "n", silent = true },
            { "<leader>nr", "<cmd>NvimTreeRefresh<CR>",  desc = "Refresh",      mode = "n", silent = true },
            { "<leader>nf", "<cmd>NvimTreeFindFile<CR>", desc = "Find File",    mode = "n", silent = true },
            { "<leader>na", "<cmd>NvimTreeCreate<CR>",   desc = "Create",       mode = "n", silent = true },
            { "<leader>nd", "<cmd>NvimTreeRemove<CR>",   desc = "Delete",       mode = "n", silent = true },
            { "<leader>nR", "<cmd>NvimTreeRename<CR>",   desc = "Rename",       mode = "n", silent = true },
            { "<leader>nx", "<cmd>NvimTreeCut<CR>",      desc = "Cut",          mode = "n", silent = true },
            { "<leader>ny", "<cmd>NvimTreeCopy<CR>",     desc = "Copy",         mode = "n", silent = true },
            { "<leader>np", "<cmd>NvimTreePaste<CR>",    desc = "Paste",        mode = "n", silent = true },
            {
                "<leader>ng",
                function() require("nvim-tree.api").tree.toggle_gitignore_filter() end,
                desc = "Toggle .gitignore", mode = "n", silent = true,
            },
            {
                "<leader>n.",
                function() require("nvim-tree.api").tree.toggle_hidden_filter() end,
                desc = "Toggle dotfiles", mode = "n", silent = true,
            },
        },

        opts = function()
            local function on_attach(bufnr)
                local api = require("nvim-tree.api")
                local function o(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end
                api.config.mappings.default_on_attach(bufnr)
                vim.keymap.set("n", "t", api.node.open.tab, o("Open in New Tab"))
                vim.keymap.set("n", "v", api.node.open.vertical, o("Open: Vertical Split"))
                vim.keymap.set("n", "T", api.node.open.horizontal, o("Open: Horizontal Split"))
                vim.keymap.set("n", "<Tab>", api.node.navigate.sibling.next, o("Next Sibling"))
                vim.keymap.set("n", "<S-Tab>", api.node.navigate.sibling.prev, o("Previous Sibling"))
            end

            return {
                disable_netrw       = true,
                hijack_netrw        = true,
                view                = { side = "left" },
                renderer            = { highlight_git = true, highlight_opened_files = "all" },
                update_focused_file = { enable = true, update_root = true },
                sync_root_with_cwd  = true,
                respect_buf_cwd     = true,
                diagnostics         = { enable = false },
                git                 = { enable = true, ignore = true },
                trash               = { cmd = "trash", require_confirm = true },
                on_attach           = on_attach,
            }
        end,

        config = function(_, opts)
            require("nvim-tree").setup(opts)

            -- If tree is the last window, close it (don't quit Neovim)
            vim.api.nvim_create_autocmd("BufEnter", {
                nested = true,
                callback = function()
                    if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == "NvimTree" then
                        require("nvim-tree.api").tree.close()
                    end
                end,
            })
        end,
    },
}
