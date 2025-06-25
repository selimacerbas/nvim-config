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
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    ft = { "python", "julia", "r" },
    dependencies = {
        {
            "3rd/image.nvim",
            opts = {
                rocks = {
                    hererocks = true, -- This enables automatic Lua 5.1 + LuaRocks install
                },
            },
            config = function()
                require("image").setup({
                    backend = "kitty", -- Or ueberzug, but Ghostty already support kitty.
                    processor = "magick_cli"
                })
            end,
        },
    },
    config = function()
        vim.g.molten_image_provider = "image.nvim"
    end,
}
