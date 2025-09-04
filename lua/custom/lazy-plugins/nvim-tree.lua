return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "folke/which-key.nvim",
        },

        -- still lazy on commands/keys; VimEnter will trigger the command to load it
        cmd = {
            "NvimTreeToggle", "NvimTreeOpen", "NvimTreeClose", "NvimTreeRefresh",
            "NvimTreeFindFile", "NvimTreeCollapse", "NvimTreeResize",
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
            -- built-in filter toggles
            { "<leader>ng", function() require("nvim-tree.api").tree.toggle_gitignore_filter() end, desc = "NvimTree: Toggle .gitignore" },
            { "<leader>n.", function() require("nvim-tree.api").tree.toggle_hidden_filter() end,    desc = "NvimTree: Toggle Dotfiles" },

            -- 👇 Width presets (percent-of-editor). These open the tree if needed.
            {
                "<leader>n0",
                function()
                    local api = require("nvim-tree.api")
                    local w = math.max(20, math.floor(vim.o.columns * 0.15))
                    if not api.tree.is_visible() then api.tree.open() end
                    api.tree.resize({ absolute = w })
                end,
                desc = "NvimTree: 15% width",
            },
            {
                "<leader>n1",
                function()
                    local api = require("nvim-tree.api")
                    local w = math.max(20, math.floor(vim.o.columns * 0.25))
                    if not api.tree.is_visible() then api.tree.open() end
                    api.tree.resize({ absolute = w })
                end,
                desc = "NvimTree: 25% width",
            },
            {
                "<leader>n2",
                function()
                    local api = require("nvim-tree.api")
                    local w = math.max(20, math.floor(vim.o.columns * 0.35))
                    if not api.tree.is_visible() then api.tree.open() end
                    api.tree.resize({ absolute = w })
                end,
                desc = "NvimTree: 35% width",
            },


        },

        -- Always open the tree on startup (and snap to 40% by default)
        init = function()
            -- in your `init = function()` (auto-open on start)
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    vim.schedule(function()
                        local width = math.max(20, math.floor(vim.o.columns * 0.15)) -- 15% default
                        vim.cmd("NvimTreeOpen")
                        vim.cmd("NvimTreeResize " .. width)
                    end)
                end,
            })
        end,

        opts = function()
            local function on_attach(bufnr)
                local api = require("nvim-tree.api")
                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end
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
                view                = { side = "left", width = 15 }, -- initial; we snap to 20% on VimEnter
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

            -- When tree is the last window, just close the tree (don't quit Neovim)
            vim.api.nvim_create_autocmd("BufEnter", {
                nested = true,
                callback = function()
                    if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == "NvimTree" then
                        require("nvim-tree.api").tree.close()
                    end
                end,
            })

            -- which-key labels
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    { "<leader>n",  group = "NvimTree" },
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
                    { "<leader>n0", desc = "15% width" },
                    { "<leader>n1", desc = "25% width" },
                    { "<leader>n2", desc = "35% width" },
                })
            end
        end,
    },
}
