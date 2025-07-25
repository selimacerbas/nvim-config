-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    -- Clone lazy.nvim repository if it's not already installed
    vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Map leader as space, this is very important. Needed for lazy.
vim.g.mapleader = " "

-- Map localleader, needed for lazy.
vim.g.maplocalleader = ","

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- Import custom plugin configurations
        { import = "custom.lazy-plugins.telescope" },
        { import = "custom.lazy-plugins.lspsaga" },
        -- { import = "custom.lazy-plugins.copilot" },
        -- { import = "custom.lazy-plugins.copilotchat" },
        { import = "custom.lazy-plugins.treesitter" },
        { import = "custom.lazy-plugins.nvim-cmp" },
        { import = "custom.lazy-plugins.toggleterm" },
        { import = "custom.lazy-plugins.mason" },
        { import = "custom.lazy-plugins.nvim-tree" },
        { import = "custom.lazy-plugins.comment" },
        { import = "custom.lazy-plugins.autopairs" },
        { import = "custom.lazy-plugins.blankline" },
        { import = "custom.lazy-plugins.autosave" },
        { import = "custom.lazy-plugins.flutter-tools-dart" },
        { import = "custom.lazy-plugins.nvim-web-icons" },
        { import = "custom.lazy-plugins.which-key" },
        { import = "custom.lazy-plugins.platformio" },
        { import = "custom.lazy-plugins.git-signs" },
        { import = "custom.lazy-plugins.vimbegood" },
        { import = "custom.lazy-plugins.todo-comments" },
        { import = "custom.lazy-plugins.markdown-preview" },
        { import = "custom.lazy-plugins.bookmarks" },
        { import = "custom.lazy-plugins.vimtex" },
        { import = "custom.lazy-plugins.molten" },
        { import = "custom.lazy-plugins.twilight" },
        { import = "custom.lazy-plugins.zen-mode" },
        { import = "custom.lazy-plugins.mcphub" },
        { import = "custom.lazy-plugins.avante" },
        { import = "custom.lazy-plugins.luasnip" },
        { import = "custom.lazy-plugins.surround" },
        { import = "custom.lazy-plugins.refactor" },
        { import = "custom.lazy-plugins.typr" },
        { import = "custom.lazy-plugins.lsp-signature" },
        -- { import = "custom.lazy-plugins.nvim-lspconfig" },
        -- { import = "custom.lazy-plugins.chatgpt" },
        { import = "custom.lazy-plugins.theme.rose-pine" }, -- Change here if you want new theme.


    },
    install = { colorscheme = { "rose-pine" } },
})
