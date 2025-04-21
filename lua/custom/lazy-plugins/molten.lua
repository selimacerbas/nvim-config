-- Installation + dependencies
-- Required; pip install pynvim jupyter_client jupyter_console ipykernel matplotlib pandas
-- Optional: pip install nbformat cairosvg plotly kaleido pyperclip pillow requests
-- brew install imagemagick
-- Put this in ~/.zshrc: export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"
-- source ~/.zshrc


-- Create your penv specific Jupyter Kernel
-- pyenv activate tf2-env (change the name)
-- pythkn -m ipykernel install --user --name=tf2-env --display-name "TensorFlow 2"
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

        -- 🔁 Optional keymaps (you can tweak the prefixes to your liking)
        vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>",
            { silent = true, desc = "Init Molten kernel" })
        vim.keymap.set("n", "<localleader>mo", ":MoltenEvaluateOperator<CR>",
            { silent = true, desc = "Run operator selection" })
        vim.keymap.set("n", "<localleader>ml", ":MoltenEvaluateLine<CR>",
            { silent = true, desc = "Run current line" })
        vim.keymap.set("n", "<localleader>mc", ":MoltenReevaluateCell<CR>",
            { silent = true, desc = "Re-evaluate current cell" })
        vim.keymap.set("n", "<localleader>ms", ":MoltenEnterOutput<CR>",
            { silent = true, desc = "Show output" })
        vim.keymap.set("v", "<localleader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv",
            { silent = true, desc = "Run visual selection" })
        -- Less suggested,
        vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>",
            { silent = true, desc = "molten delete cell" })
        vim.keymap.set("n", "<localleader>mh", ":MoltenHideOutput<CR>",
            { silent = true, desc = "hide output" })
        vim.keymap.set("n", "<localleader>me", ":noautocmd MoltenEnterOutput<CR>",
            { silent = true, desc = "show/enter output" })
    end,
}
