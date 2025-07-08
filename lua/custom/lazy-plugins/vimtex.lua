-- To get this shit worked;
-- Install zathura from here: https://github.com/homebrew-zathura/homebrew-zathura
-- brew install --cask skim (instead of zathura)
-- Install basictex from here: brew install --cask basictex
-- Put binary to Path: export PATH="/Library/TeX/texbin:$PATH"
-- Test: which latex
-- Run; sudo tlmgr update --self
-- Install: sudo tlmgr install latexmk
-- OR
-- brew install --cask mactex
-- export PATH="/Library/TeX/texbin:$PATH"
-- brew install --cask skim
-- which latex
-- which tlmgr



return {
    {
        "lervag/vimtex",
        lazy = false, -- load immediately
        dependencies = { "folke/which-key.nvim" },
        init = function()
            -- Viewer: Skim
            vim.g.vimtex_view_method        = "skim"
            vim.g.vimtex_view_skim_sync     = 1
            vim.g.vimtex_view_skim_activate = 1

            -- Compiler: latexmk with XeLaTeX
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
        end,
        config = function()
            local wk_ok, which_key = pcall(require, "which-key")
            if not wk_ok then return end

            which_key.register({
                v = {
                    name = "VimTeX/VimBeGood",
                    c = { "<cmd>VimtexCompile<CR>", "Compile" },
                    s = { "<cmd>VimtexStop<CR>", "Stop Compile" },
                    v = { "<cmd>VimtexView<CR>", "View PDF" },
                    C = { "<cmd>VimtexClean<CR>", "Clean Aux Files" },
                    t = { "<cmd>VimtexTocToggle<CR>", "Toggle ToC" },
                    r = { "<cmd>VimtexCompileSelected<CR>", "Compile Selection" },
                    i = { "<cmd>VimtexInfo<CR>", "Show Info" },
                },
            }, { prefix = "<leader>" })
        end,
    },
}
