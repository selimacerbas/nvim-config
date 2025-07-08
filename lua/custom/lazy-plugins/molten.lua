-- Installation + dependencies
-- Required; pip install pynvim jupyter_client jupyter_console ipykernel matplotlib pandas
-- Optional: pip install nbformat cairosvg plotly kaleido pyperclip pillow requests
-- brew install imagemagick
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
        build = ":UpdateRemotePlugins",
        dependencies = {
            {
                "3rd/image.nvim",
                opts = {
                    rocks = {
                        hererocks = true, -- enable automatic Lua 5.1 + LuaRocks install
                    },
                },
                config = function()
                    require("image").setup({
                        backend   = "kitty", -- or "ueberzug"
                        processor = "magick_cli",
                    })
                end,
            },
            "folke/which-key.nvim",
        },
        config = function()
            -- use image.nvim as the provider
            vim.g.molten_image_provider = "image.nvim"

            -- register Molten commands under <leader>m
            local wk_ok, which_key = pcall(require, "which-key")
            if not wk_ok then return end

            which_key.register({
                m = {
                    name = "Molten",
                    i = { ":MoltenInit<CR>", "Init Kernel" },
                    o = { ":MoltenEvaluateOperator<CR>", "Run Operator" },
                    l = { ":MoltenEvaluateLine<CR>", "Run Line" },
                    c = { ":MoltenReevaluateCell<CR>", "Re-evaluate Cell" },
                    s = { ":MoltenEnterOutput<CR>", "Show Output" },
                    d = { ":MoltenDelete<CR>", "Delete Cell" },
                    h = { ":MoltenHideOutput<CR>", "Hide Output" },
                    e = { ":noautocmd MoltenEnterOutput<CR>", "Enter Output (noautocmd)" },
                },
            }, { prefix = "<leader>" })

            -- visual-mode evaluation under <leader>m v
            which_key.register({
                m = {
                    v = { ":<C-u>MoltenEvaluateVisual<CR>gv", "Run Visual Selection" },
                },
            }, { prefix = "<leader>", mode = "v" })
        end,
    },
}
