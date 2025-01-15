require("custom.lazy")
require("custom.functions")
require("custom.keymaps")

-- BREW BINARY DEPENDENCIES --
-- neovim
-- tree-sitter
-- ripgrep
-- fd
--  LuaSnip Dependency --
-- cd ~/.local/share/nvim/lazy/LuaSnip  # Adjust the path if you're using a different plugin manager
-- make install_jsregexp
-- END BREW BINARY DEPENDENCIES --

-- > /Users/selim/.local/state/nvim/lsp.log
-- > /Users/selim/.local/state/nvim/mason.log

-- LSP log level
vim.lsp.set_log_level("ERROR")

-- Disable Perl provider since I dont use Perl.
vim.g.loaded_perl_provider = 0

-- pynvim Dependency. The venv is created under lua/custom folder.
vim.g.python3_host_prog = vim.fn.expand('~/.config/nvim/lua/custom/venv/bin/python')


-- Treat Kptfiles as YAML files.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "Kptfile",
    callback = function()
        vim.bo.filetype = "yaml"
    end,
})


-- Map leader as space.
vim.g.mapleader = " "

-- Map localleader.
vim.g.maplocalleader = "\\"

-- Line numbers
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.signcolumn = "yes"    -- Always show the sign column

-- Enable system clipboard for copy paste
vim.opt.clipboard:append("unnamedplus")

vim.opt.tabstop = 4        -- Number of spaces for a tab
vim.opt.shiftwidth = 4     -- Number of spaces for autoindent
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.smartindent = true -- Automatically indent new lines

-- Highlight the current line
vim.opt.cursorline = true

-- Transparency level for floating windows (0-100, lower is more opaque)
vim.opt.winblend = 5

-- Transparency level for popup menus (completion menus, etc.)
vim.opt.pumblend = 5
