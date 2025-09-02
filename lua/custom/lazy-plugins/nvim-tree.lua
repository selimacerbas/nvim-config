return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "folke/which-key.nvim",
        },

        -- Lazy-load on commands/keys; plus we create a VimEnter autocmd in `init`
        cmd = {
            "NvimTreeToggle", "NvimTreeOpen", "NvimTreeClose", "NvimTreeRefresh",
            "NvimTreeFindFile", "NvimTreeCollapse",
            "NvimTreeCreate", "NvimTreeRemove", "NvimTreeRename",
            "NvimTreeCopy", "NvimTreeCut", "NvimTreePaste",
        },
        keys = {
            { "<leader>nt", "<cmd>NvimTreeToggle<CR>",                                              desc = "NvimTree: Toggle" },
            { "<leader>no", "<cmd>NvimTreeOpen<CR>",                                                desc = "NvimTree: Open" },
            { "<leader>nc", "<cmd>NvimTreeClose<CR>",                                               desc = "NvimTree: Close" },
            { "<leader>nC", "<cmd>NvimTreeCollapse<CR>",                                            desc = "NvimTree: Collapse All" },
            { "<leader>nr", "<cmd>NvimTreeRefresh<CR>",                                             desc = "NvimTree: Refresh" },
            { "<leader>nf", "<cmd>NvimTreeFindFile<CR>",                                            desc = "NvimTree: Find Current File" },
            { "<leader>na", "<cmd>NvimTreeCreate<CR>",                                              desc = "NvimTree: Create" },
            { "<leader>nd", "<cmd>NvimTreeRemove<CR>",                                              desc = "NvimTree: Delete" },
            { "<leader>nR", "<cmd>NvimTreeRename<CR>",                                              desc = "NvimTree: Rename" },
            { "<leader>nx", "<cmd>NvimTreeCut<CR>",                                                 desc = "NvimTree: Cut" },
            { "<leader>ny", "<cmd>NvimTreeCopy<CR>",                                                desc = "NvimTree: Copy" },
            { "<leader>np", "<cmd>NvimTreePaste<CR>",                                               desc = "NvimTree: Paste" },
            -- built-in filter toggles (no re-setup)
            { "<leader>ng", function() require("nvim-tree.api").tree.toggle_gitignore_filter() end, desc = "NvimTree: Toggle .gitignore" },
            { "<leader>n.", function() require("nvim-tree.api").tree.toggle_hidden_filter() end,    desc = "NvimTree: Toggle Dotfiles" },
        },

        -- Create the "open on directory" autocmd before the plugin loads
        init = function()
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    -- If exactly one CLI arg and it's a directory: cd into it and open the tree.
                    if vim.fn.argc() == 1 then
                        local arg = vim.fn.argv(0)
                        if arg and vim.fn.isdirectory(arg) == 1 then
                            vim.cmd.cd(arg)
                            -- this command also lazy-loads the plugin via `cmd` trigger
                            vim.cmd("NvimTreeOpen")
                        end
                    end
                end,
            })
        end,

        opts = function()
            local function on_attach(bufnr)
                local api = require("nvim-tree.api")
                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end
                -- defaults first
                api.config.mappings.default_on_attach(bufnr)
                -- open in tab/splits
                vim.keymap.set("n", "t", api.node.open.tab, opts("Open in New Tab"))
                vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
                vim.keymap.set("n", "T", api.node.open.horizontal, opts("Open: Horizontal Split"))
                -- sibling nav
                vim.keymap.set("n", "<Tab>", api.node.navigate.sibling.next, opts("Next Sibling"))
                vim.keymap.set("n", "<S-Tab>", api.node.navigate.sibling.prev, opts("Previous Sibling"))
            end

            return {
                disable_netrw       = true,
                hijack_netrw        = true,
                view                = { side = "left", width = 40 },
                renderer            = { highlight_git = true, highlight_opened_files = "all" },
                update_focused_file = { enable = true, update_root = true },
                sync_root_with_cwd  = true,
                respect_buf_cwd     = true,
                diagnostics         = { enable = false },
                git                 = { enable = true, ignore = true }, -- default respect .gitignore (toggle with <leader>ng)
                trash               = { cmd = "trash", require_confirm = true },
                on_attach           = on_attach,
            }
        end,

        config = function(_, opts)
            require("nvim-tree").setup(opts)

            -- Auto-close Neovim when NvimTree is the last window left
            vim.api.nvim_create_autocmd("BufEnter", {
                nested = true,
                callback = function()
                    -- if the only window left is the tree, quit Neovim
                    if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == "NvimTree" then
                        vim.cmd("quit")
                        -- If you’d rather close just the tree (and keep Neovim running) when it’s the last window, I can swap the autocmd to require("nvim-tree.api").tree.close() instead of :quit.
                    end
                end,
            })

            -- which-key labels
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    -- { "<leader>n",  group = "NvimTree" },
                    { "<leader>nt", desc = "Toggle" },
                    { "<leader>no", desc = "Open" },
                    { "<leader>nc", desc = "Close" },
                    { "<leader>nC", desc = "Collapse All" },
                    { "<leader>nr", desc = "Refresh" },
                    { "<leader>nf", desc = "Find Current File" },
                    { "<leader>na", desc = "Create" },
                    { "<leader>nd", desc = "Delete" },
                    { "<leader>nR", desc = "Rename" },
                    { "<leader>nx", desc = "Cut" },
                    { "<leader>ny", desc = "Copy" },
                    { "<leader>np", desc = "Paste" },
                    { "<leader>ng", desc = "Toggle .gitignore" },
                    { "<leader>n.", desc = "Toggle Dotfiles" },
                })
            end
        end,
    },
}
