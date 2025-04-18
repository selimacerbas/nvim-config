-- Installation + dependencies
-- pip install pynvim jupyter_client matplotlib pandas
-- Optional: pip install nbformat cairosvg plotly kaleido pyperclip pillow
-- brew install imagemagick
-- Put this in ~/.zshrc: export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"
-- source ~/.zshrc


return {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    ft = { "python", "julia", "r" },
    dependencies = {
        {
            "3rd/image.nvim",
            opts = {
                rocks = {
                    hererocks = true, -- ✅ This enables automatic Lua 5.1 + LuaRocks install
                },
            },
            config = function()
                require("image").setup({
                    backend = "magick_cli", -- or "viu" if you prefer ImageMagick
                })
            end,
        },
    },
    config = function()
        vim.g.molten_image_provider = "image.nvim"

        -- 🔁 Optional keymaps (you can tweak the prefixes to your liking)
        vim.keymap.set("n", "<localleader>mi", ":MoltenInit python3<CR>", { silent = true, desc = "Init Molten kernel" })
        vim.keymap.set("n", "<localleader>mrc", ":MoltenReevaluateCell<CR>",
            { silent = true, desc = "Re-evaluate current cell" })
        vim.keymap.set("n", "<localleader>mel", ":MoltenEvaluateLine<CR>", { silent = true, desc = "Run current line" })
        vim.keymap.set("n", "<localleader>meo", ":MoltenEnterOutput<CR>", { silent = true, desc = "Show output" })
        vim.keymap.set("v", "<localleader>mev", ":<C-u>MoltenEvaluateVisual<CR>gv",
            { silent = true, desc = "Run visual selection" })
    end,
}
