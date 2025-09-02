return {
    -- 1) Gitsigns — unchanged core, plus which-key + text-objects (buffer-local)
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "folke/which-key.nvim" },
        opts = {
            signs = {
                add          = { text = "+" },
                change       = { text = "┃" },
                delete       = { text = "_" },
                topdelete    = { text = "‾" },
                changedelete = { text = "~" },
            },
            current_line_blame = true,
            current_line_blame_opts = { delay = 400, virt_text_pos = "eol" },
            preview_config = { border = "single" },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                end

                -- Hunk navigation (diff-aware)
                map("n", "]c", function() if vim.wo.diff then vim.cmd.normal({ "]c" }) else gs.next_hunk() end end,
                    "Next Git Hunk")
                map("n", "[c", function() if vim.wo.diff then vim.cmd.normal({ "[c" }) else gs.prev_hunk() end end,
                    "Prev Git Hunk")

                -- Hunk text objects
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Inner Hunk")
                map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>", "Around Hunk")

                -- which-key group (buffer-local, gitsigns actions)
                local ok, wk = pcall(require, "which-key")
                if ok then
                    local add = wk.add or wk.register
                    add({
                        { "<leader>g",  group = "Git" },

                        { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>",  desc = "Stage Hunk",           mode = { "n", "v" } },
                        { "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>",  desc = "Reset Hunk",           mode = { "n", "v" } },
                        { "<leader>gS", gs.stage_buffer,                 desc = "Stage Buffer" },
                        { "<leader>gu", gs.undo_stage_hunk,              desc = "Undo Stage Hunk" },
                        { "<leader>gR", gs.reset_buffer,                 desc = "Reset Buffer" },
                        { "<leader>gp", gs.preview_hunk,                 desc = "Preview Hunk (float)" },
                        { "<leader>gP", gs.preview_hunk_inline,          desc = "Preview Hunk (inline)" },
                        { "<leader>gb", gs.blame_line,                   desc = "Blame Line" },
                        { "<leader>gB", gs.toggle_current_line_blame,    desc = "Toggle Line Blame" },
                        { "<leader>gd", gs.diffthis,                     desc = "Diff This (index)" },
                        { "<leader>gD", function() gs.diffthis("~") end, desc = "Diff Against HEAD" },
                        { "<leader>gt", gs.toggle_deleted,               desc = "Toggle Deleted Lines" },
                        { "<leader>gx", gs.toggle_signs,                 desc = "Toggle Signs" },
                    }, { buffer = bufnr })
                end
            end,
        },
    },

    -- 2) Neogit — full-screen Git UI (Magit-style). Lazy on command/keys.
    {
        "NeogitOrg/neogit",
        cmd = { "Neogit" },
        dependencies = {
            "nvim-lua/plenary.nvim",         -- required
            "folke/which-key.nvim",
            "nvim-telescope/telescope.nvim", -- for pickers below
            -- optional, nicer diffs from Neogit: :DiffviewOpen etc.
            { "sindrets/diffview.nvim", optional = true },
        },
        opts = {
            integrations = { diffview = true, telescope = true },
        },
        keys = {
            { "<leader>gg", "<cmd>Neogit<CR>",        desc = "Neogit (status)" },
            { "<leader>gC", "<cmd>Neogit commit<CR>", desc = "Neogit Commit Popup" },
        },
        config = function(_, opts)
            require("neogit").setup(opts)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({ { "<leader>g", group = "Git" } })
            end
        end,
    },

    -- 3) Telescope Git pickers — convenient “find” sub-group under <leader>gf…
    {
        "nvim-telescope/telescope.nvim",
        optional = true,
        dependencies = { "folke/which-key.nvim" },
        keys = {
            { "<leader>gf",  group = "Git: Find (Telescope)",                            mode = "n" },

            { "<leader>gfc", function() require("telescope.builtin").git_commits() end,  desc = "Commits" },
            { "<leader>gfb", function() require("telescope.builtin").git_bcommits() end, desc = "Buffer Commits" },
            { "<leader>gfs", function() require("telescope.builtin").git_status() end,   desc = "Status" },
            { "<leader>gfB", function() require("telescope.builtin").git_branches() end, desc = "Branches" },
            { "<leader>gfS", function() require("telescope.builtin").git_stash() end,    desc = "Stash" },
        },
    },

    -- 4) (Optional) Diffview convenience keys, lazy on demand
    {
        "sindrets/diffview.nvim",
        optional = true,
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
        keys = {
            { "<leader>gV", "<cmd>DiffviewOpen<CR>",  desc = "Diffview: Open" },
            { "<leader>gX", "<cmd>DiffviewClose<CR>", desc = "Diffview: Close" },
        },
    },
}
