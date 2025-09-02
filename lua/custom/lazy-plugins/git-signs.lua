return {
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
                map("n", "]c", function()
                    if vim.wo.diff then vim.cmd.normal({ "]c", bang = false }) else gs.next_hunk() end
                end, "Next Git Hunk")

                map("n", "[c", function()
                    if vim.wo.diff then vim.cmd.normal({ "[c", bang = false }) else gs.prev_hunk() end
                end, "Prev Git Hunk")

                -- Text objects for hunks (operator-pending/visual)
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Inner Hunk")
                map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>", "Around Hunk")

                -- which-key group under <leader>g (buffer-local)
                local ok, wk = pcall(require, "which-key")
                if ok then
                    local add = wk.add or wk.register
                    add({
                        { "<leader>g",  group = "Git (gitsigns)" },

                        -- works in NORMAL and VISUAL (selection becomes the range)
                        { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>",  desc = "Stage Hunk",           mode = { "n", "v" } },
                        { "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>",  desc = "Reset Hunk",           mode = { "n", "v" } },

                        { "<leader>gS", gs.stage_buffer,                 desc = "Stage Buffer" },
                        { "<leader>gu", gs.undo_stage_hunk,              desc = "Undo Stage Hunk" },
                        { "<leader>gR", gs.reset_buffer,                 desc = "Reset Buffer" },

                        { "<leader>gp", gs.preview_hunk,                 desc = "Preview Hunk (float)" },
                        { "<leader>gP", gs.preview_hunk_inline,          desc = "Preview Hunk (inline)" },

                        { "<leader>gb", gs.blame_line,                   desc = "Blame Line" },
                        { "<leader>gB", gs.toggle_current_line_blame,    desc = "Toggle Line Blame" },

                        { "<leader>gd", gs.diffthis,                     desc = "Diff This" },
                        { "<leader>gD", function() gs.diffthis("~") end, desc = "Diff Against HEAD" },

                        { "<leader>gt", gs.toggle_deleted,               desc = "Toggle Deleted Lines" },
                        { "<leader>gx", gs.toggle_signs,                 desc = "Toggle Signs" },
                    }, { buffer = bufnr })
                end
            end,
        },
    },
}
