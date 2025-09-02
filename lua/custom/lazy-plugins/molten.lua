-- Installation + dependencies
-- Required; pip install pynvim jupyter_client jupyter_console ipykernel matplotlib pandas
-- Optional: pip install nbformat cairosvg plotly kaleido pyperclip pillow requests
-- brew install imagemagick
-- brew install pngpaste
-- Put this in ~/.zshrc: export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"
-- source ~/.zshrc


-- Create your penv specific Jupyter Kernel
-- pyenv activate tf2-env (change the name)
-- python -m ipykernel install --user --name=tf2-env --display-name "TensorFlow 2"
-- jupyter console --kernel tf2-env
--
-- Check which kernels you have in your system
-- jupyter kernelspec list --json

-- Run this to init the jupyter in your nvim.
-- :MoltenInit tf2-env
--

return {
    {
        "benlubas/molten-nvim",
        ft = { "python", "julia", "r" },
        cmd = { "MoltenInit", "MoltenEvaluateLine", "MoltenEvaluateVisual", "MoltenEvaluateOperator",
            "MoltenReevaluateCell", "MoltenEnterOutput", "MoltenHideOutput", "MoltenDelete" },
        build = ":UpdateRemotePlugins",
        dependencies = {
            {
                "3rd/image.nvim",
                opts = {
                    rocks = { enabled = true, hererocks = true }, -- auto-install Lua5.1 + luarocks
                },
                config = function()
                    require("image").setup({
                        backend   = "kitty",     -- or "ueberzug" if not using Kitty
                        processor = "magick_cli" -- ImageMagick CLI
                    })
                end,
            },
            "folke/which-key.nvim",
        },
        config = function()
            -- Use image.nvim as the renderer for rich outputs
            vim.g.molten_image_provider = "image.nvim"

            -- which-key: <leader>j ... (Jupyter/Molten)
            local ok, wk = pcall(require, "which-key")
            if ok then
                local add = wk.add or wk.register
                add({
                    -- { "<leader>j",  group = "Jupyter (Molten)" },
                    { "<leader>ji", ":MoltenInit<CR>",                  desc = "Init Kernel" },
                    { "<leader>jl", ":MoltenEvaluateLine<CR>",          desc = "Run Line" },
                    { "<leader>jo", ":MoltenEvaluateOperator<CR>",      desc = "Run Operator" },
                    { "<leader>jc", ":MoltenReevaluateCell<CR>",        desc = "Re-evaluate Cell" },
                    { "<leader>js", ":MoltenEnterOutput<CR>",           desc = "Show Output" },
                    { "<leader>jh", ":MoltenHideOutput<CR>",            desc = "Hide Output" },
                    { "<leader>jd", ":MoltenDelete<CR>",                desc = "Delete Cell" },
                    { "<leader>jS", ":noautocmd MoltenEnterOutput<CR>", desc = "Enter Output (noautocmd)" },
                }, { mode = "n", silent = true, noremap = true })

                -- Visual: evaluate selection
                add({
                    { "<leader>jv", ":<C-u>MoltenEvaluateVisual<CR>gv", desc = "Run Visual Selection" },
                }, { mode = "v", silent = true, noremap = true })
            end
        end,
    },
}
