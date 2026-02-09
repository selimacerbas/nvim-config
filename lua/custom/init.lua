require("custom.lazy")

-- BREW BINARY DEPENDENCIES --
-- brew install neovim
-- brew install tree-sitter
-- brew install tree-sitter-cli
-- brew install ripgrep
-- brew install fd
-- brew install glab
-- brew install gh
-- brew install timg
-- brew install mermaid-cli
-- brew install imagemagick
-- brew install deno (peek.nvim needs it)
-- brew install chafa viu (fzf needs these)

--  LuaSnip Dependency --
-- cd ~/.local/share/nvim/lazy/LuaSnip  # Adjust the path if you're using a different plugin manager
-- make install_jsregexp

-- END BREW BINARY DEPENDENCIES --

--  /Users/selim/.local/state/nvim/lsp.log
--  /Users/selim/.local/state/nvim/mason.log

-- LSP log level
vim.lsp.set_log_level("ERROR")

-- Disable Perl provider since I dont use Perl.
vim.g.loaded_perl_provider = 0

-- pynvim Dependency. The venv is created under lua/custom folder.
vim.g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/nvim-env/bin/python")

-- needed for mermaid and diagram.nvim
vim.env.PATH = vim.fn.expand("~/.local/bin") .. ":" .. vim.env.PATH

-- Treat Kptfiles as YAML files.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "Kptfile",
    callback = function()
        vim.bo.filetype = "yaml"
    end,
})

-- Leader keys are set in lazy.lua (before lazy.nvim setup).

-- Cell delimeter for molten
vim.g.molten_cell_delimiter = "# %%"

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

-- To open splits are going be opened at right side.
vim.opt.splitright = true
--
-- Avoid Neovim equalizing splits on open/close (prevents REPL width creep)
vim.o.equalalways = false



-- === Terminal Related(global) ===

-- Leave terminal (Job) mode with Esc
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { silent = true, desc = "Terminal: normal mode" })

-- === UI Sizing (global) ===
do
    -- Register which-key sub-groups for UI sizing
    local ok, wk = pcall(require, "which-key")
    if ok and wk.add then
        wk.add({
            { "<leader>uw", group = "Width presets" },
            { "<leader>uh", group = "Height presets" },
            { "<leader>ut", group = "UI controls" },
        })
    end

    local sizing = require("custom.ui-sizing")
    sizing.setup({
        -- flip this to true if you want per-filetype auto reapply (recommended only for sidebars)
        enable_ft_fallback = false,
    })

    local function map(lhs, fn, desc)
        vim.keymap.set({ "n", "t" }, lhs, fn, { silent = true, desc = desc })
    end

    -- Width presets
    map("<leader>uw1", function() sizing.set_width_ratio(0.15) end, "Width → 15%")
    map("<leader>uw2", function() sizing.set_width_ratio(0.25) end, "Width → 25%")
    map("<leader>uw3", function() sizing.set_width_ratio(0.35) end, "Width → 35%")
    map("<leader>uw4", function() sizing.set_width_ratio(0.45) end, "Width → 45%")

    -- Height presets
    map("<leader>uh1", function() sizing.set_height_ratio(0.15) end, "Height → 15%")
    map("<leader>uh2", function() sizing.set_height_ratio(0.25) end, "Height → 25%")
    map("<leader>uh3", function() sizing.set_height_ratio(0.35) end, "Height → 35%")
    map("<leader>uh4", function() sizing.set_height_ratio(0.45) end, "Height → 45%")

    -- Handy controls
    map("<leader>uto", function() vim.cmd("UISizeOff") end, "OFF")
    map("<leader>utO", function() vim.cmd("UISizeOn") end, "ON")
    map("<leader>utc", function() vim.cmd("UISizeClear") end, "Clear current")
    map("<leader>utR", function() vim.cmd("UISizeResetAll") end, "Reset ALL")
end
