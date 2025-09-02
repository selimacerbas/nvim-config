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
        ft = { "tex", "plaintex" }, -- load only for TeX buffers (faster startup)
        dependencies = { "folke/which-key.nvim" },

        -- Global opts must be set BEFORE the plugin loads → put them in init
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

            -- Optional: don’t auto-open quickfix on warnings (open via <leader>ve)
            vim.g.vimtex_quickfix_mode      = 0

            -- Make the <leader>v group visible immediately
            local ok, wk                    = pcall(require, "which-key")
            if ok then
                if wk.add then
                    wk.add({ { "<leader>v", group = "VimTeX / Vim" } })
                else
                    wk.register({ v = { name = "VimTeX / Vim" } }, { prefix = "<leader>" })
                end
            end
        end,

        -- Leader keys (show up in Which-Key; trigger plugin on use)
        keys = {
            { "<leader>vc", "<cmd>VimtexCompile<CR>",         desc = "Compile (latexmk -xelatex)" },
            { "<leader>vs", "<cmd>VimtexStop<CR>",            desc = "Stop compile" },
            { "<leader>vv", "<cmd>VimtexView<CR>",            desc = "View PDF (Skim)" },
            { "<leader>vC", "<cmd>VimtexClean<CR>",           desc = "Clean aux files" },
            { "<leader>vt", "<cmd>VimtexTocToggle<CR>",       desc = "Toggle ToC" },
            { "<leader>vr", "<cmd>VimtexCompileSelected<CR>", desc = "Compile selection" },
            { "<leader>vi", "<cmd>VimtexInfo<CR>",            desc = "VimTeX info" },
            { "<leader>ve", "<cmd>VimtexErrors<CR>",          desc = "Show errors (quickfix)" },
            { "<leader>vw", "<cmd>VimtexCountWords!<CR>",     desc = "Count words" },
        },

        config = function()
            -- Small per-buffer niceties for TeX
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "tex", "plaintex" },
                callback = function()
                    -- Comfortable math conceal; tweak if you dislike hiding markers
                    vim.opt_local.conceallevel  = 2
                    vim.opt_local.concealcursor = "nc"
                end,
            })
        end,
    },
}
