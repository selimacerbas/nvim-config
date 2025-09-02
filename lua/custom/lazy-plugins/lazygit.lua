return {
    {
        "kdheepak/lazygit.nvim",
        version = "*",
        cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
        dependencies = {
            "folke/which-key.nvim",
            -- "nvim-lua/plenary.nvim", -- optional; not strictly required by lazygit.nvim
        },
        init = function()
            -- If you use `nvr` (neovim-remote) to edit commit messages inside Neovim:
            -- vim.g.lazygit_use_neovim_remote = 1
            -- vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
        end,
        config = function()
            -- Optional visuals for LazyGit's floating window
            vim.g.lazygit_floating_window_winblend = 5 -- slight transparency
            vim.g.lazygit_floating_window_scaling_factor = 0.9

            local function ensure_lazygit(cmd)
                return function()
                    if vim.fn.executable("lazygit") == 1 then
                        vim.cmd(cmd)
                    else
                        vim.notify(
                            "LazyGit not found in PATH. Install it first (e.g. brew install lazygit / scoop install lazygit / apt install lazygit).",
                            vim.log.levels.WARN
                        )
                    end
                end
            end

            -- Safe map helper (don’t override existing user maps)
            local function safe_map(lhs, rhs, desc)
                if vim.fn.maparg(lhs, "n") == "" then
                    vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
                end
            end

            -- Keymaps (project-scoped Git under <leader>g)
            safe_map("<leader>hg", ensure_lazygit("LazyGit"), "LazyGit (project)")
            safe_map("<leader>hB", ensure_lazygit("LazyGitCurrentFile"), "LazyGit (current file)")
            safe_map("<leader>hf", ensure_lazygit("LazyGitFilter"), "LazyGit (filter by branch/commit)")
            safe_map("<leader>hF", ensure_lazygit("LazyGitFilterCurrentFile"), "LazyGit (filter current file)")
            safe_map("<leader>hc", ensure_lazygit("LazyGitConfig"), "LazyGit config")

            -- Which-Key labels / group
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>h",  group = "Git / LazyGit" },
                    { "<leader>hg", desc = "LazyGit (project)" },
                    { "<leader>hB", desc = "LazyGit (current file)" },
                    { "<leader>hf", desc = "LazyGit (filter by branch/commit)" },
                    { "<leader>hF", desc = "LazyGit (filter current file)" },
                    { "<leader>hc", desc = "LazyGit config" },
                })
            end
        end,
    },
}
