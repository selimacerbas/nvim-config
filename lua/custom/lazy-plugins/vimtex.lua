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
        lazy = false, -- we don't want to lazy load VimTeX
        -- tag = "v2.15", -- uncomment to pin to a specific release
        init = function()
            -- VimTeX viewer configuration (Skim)
            vim.g.vimtex_view_method = "skim"
            vim.g.vimtex_view_skim_sync = 1
            vim.g.vimtex_view_skim_activate = 1 -- Auto-focus Skim when view opens

            -- VimTeX compile settings
            vim.g.vimtex_compiler_method = "latexmk"
            vim.g.vimtex_compile_on_save = 1

            -- Force XeLaTeX
            vim.g.vimtex_compiler_latexmk = {
                build_dir = '',
                callback = 1,
                continuous = 1,
                executable = 'latexmk',
                options = {
                    '-xelatex',
                    '-file-line-error',
                    '-synctex=1',
                    '-interaction=nonstopmode',
                },
            }
        end
    }
}
