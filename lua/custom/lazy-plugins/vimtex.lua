-- To get this shit worked;
-- Install zathura from here: https://github.com/homebrew-zathura/homebrew-zathura
-- brew install --cask skim (instead of zathura)
-- Install basictex from here: brew install --cask basictex
-- Put binary to Path: export PATH="/Library/TeX/texbin:$PATH"
-- Test: which latex
-- Run; sudo tlmgr update --self
-- Install:
-- sudo tlmgr install latexmk xetex biber bibtex
-- # (Optional but often useful)
-- sudo tlmgr install fontspec filehook unicode-math
--
-- OR install bigger package
-- brew install --cask mactex
-- export PATH="/Library/TeX/texbin:$PATH"
-- brew install --cask skim
-- which latex
-- which tlmgr



return {
    {
        "lervag/vimtex",
        ft = { "tex", "plaintex" }, -- load only for TeX buffers
        dependencies = { "folke/which-key.nvim" },

        -- Global opts must be set BEFORE the plugin loads
        init = function()
            -- Viewer: Skim (macOS)
            vim.g.vimtex_view_method        = "skim"
            vim.g.vimtex_view_skim_sync     = 1
            vim.g.vimtex_view_skim_activate = 1

            -- Compiler: latexmk with XeLaTeX (continuous, on save)
            vim.g.vimtex_compiler_method    = "latexmk"
            vim.g.vimtex_compile_on_save    = 1
            vim.g.vimtex_compiler_latexmk   = {
                build_dir  = "",
                callback   = 1,
                continuous = 1,
                executable = "latexmk",
                options    = {
                    "-xelatex",
                    "-file-line-error",
                    "-synctex=1",
                    "-interaction=nonstopmode",
                },
            }

            -- Don’t auto-open quickfix (open with <leader>ve)
            vim.g.vimtex_quickfix_mode      = 0

            -- Which-Key v3 group (do not put groups under keys)
            local ok, wk                    = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>v", group = "VimTeX" } })
            end
        end,

        -- Leader keymaps (real maps so Lazy loads on press)
        keys = {
            { "<leader>vc", "<cmd>VimtexCompile<CR>",         desc = "Compile (latexmk -xelatex)", mode = "n", silent = true, noremap = true },
            { "<leader>vs", "<cmd>VimtexStop<CR>",            desc = "Stop compile",               mode = "n", silent = true, noremap = true },
            { "<leader>vv", "<cmd>VimtexView<CR>",            desc = "View PDF (Skim)",            mode = "n", silent = true, noremap = true },
            { "<leader>vC", "<cmd>VimtexClean<CR>",           desc = "Clean aux files",            mode = "n", silent = true, noremap = true },
            { "<leader>vt", "<cmd>VimtexTocToggle<CR>",       desc = "Toggle ToC",                 mode = "n", silent = true, noremap = true },
            { "<leader>vr", "<cmd>VimtexCompileSelected<CR>", desc = "Compile selection",          mode = "n", silent = true, noremap = true },
            { "<leader>vi", "<cmd>VimtexInfo<CR>",            desc = "VimTeX info",                mode = "n", silent = true, noremap = true },
            { "<leader>ve", "<cmd>VimtexErrors<CR>",          desc = "Show errors (quickfix)",     mode = "n", silent = true, noremap = true },
            { "<leader>vw", "<cmd>VimtexCountWords!<CR>",     desc = "Count words",                mode = "n", silent = true, noremap = true },
        },

        config = function()
            -- TeX buffer niceties
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "tex", "plaintex" },
                callback = function()
                    vim.opt_local.conceallevel  = 2
                    vim.opt_local.concealcursor = "nc"
                end,
            })
        end,
    },
}
