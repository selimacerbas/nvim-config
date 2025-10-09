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

-- Map leader as space.
vim.g.mapleader = " "

-- Map localleader.
vim.g.maplocalleader = ","

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
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { silent = true })

-- === UI Sizing (global) ===
do
    local sizing = require("custom.ui-sizing")
    sizing.setup()

    local function map(lhs, fn, desc)
        vim.keymap.set({ "n", "t" }, lhs, fn, { silent = true, desc = desc })
    end

    -- Width presets (you already had these)
    map("uw1", function() sizing.set_width_ratio(0.15) end, "UI Sizing: Width → 15%")
    map("uw2", function() sizing.set_width_ratio(0.25) end, "UI Sizing: Width → 25%")
    map("uw3", function() sizing.set_width_ratio(0.35) end, "UI Sizing: Width → 35%")
    map("uw4", function() sizing.set_width_ratio(0.45) end, "UI Sizing: Width → 45%")

    map("<leader>uw1", function() sizing.set_width_ratio(0.15) end, "UI Sizing: Width → 15%")
    map("<leader>uw2", function() sizing.set_width_ratio(0.25) end, "UI Sizing: Width → 25%")
    map("<leader>uw3", function() sizing.set_width_ratio(0.35) end, "UI Sizing: Width → 35%")
    map("<leader>uw4", function() sizing.set_width_ratio(0.45) end, "UI Sizing: Width → 45%")

    -- Height presets (new)
    map("uh1", function() sizing.set_height_ratio(0.15) end, "UI Sizing: Height → 15%")
    map("uh2", function() sizing.set_height_ratio(0.25) end, "UI Sizing: Height → 25%")
    map("uh3", function() sizing.set_height_ratio(0.35) end, "UI Sizing: Height → 35%")
    map("uh4", function() sizing.set_height_ratio(0.45) end, "UI Sizing: Height → 45%")

    map("<leader>uh1", function() sizing.set_height_ratio(0.15) end, "UI Sizing: Height → 15%")
    map("<leader>uh2", function() sizing.set_height_ratio(0.25) end, "UI Sizing: Height → 25%")
    map("<leader>uh3", function() sizing.set_height_ratio(0.35) end, "UI Sizing: Height → 35%")
    map("<leader>uh4", function() sizing.set_height_ratio(0.45) end, "UI Sizing: Height → 45%")

    -- which-key labels (use your existing folke/which-key if present)
    local ok, wk = pcall(require, "which-key")
    if ok then
        wk.add({
            { "uw", group = "UI Sizing (Width)", mode = { "n", "t" } },
            { "uw1", desc = "Width → 15%", mode = { "n", "t" } },
            { "uw2", desc = "Width → 25%", mode = { "n", "t" } },
            { "uw3", desc = "Width → 35%", mode = { "n", "t" } },
            { "uw4", desc = "Width → 45%", mode = { "n", "t" } },

            { "uh", group = "UI Sizing (Height)", mode = { "n", "t" } },
            { "uh1", desc = "Height → 15%", mode = { "n", "t" } },
            { "uh2", desc = "Height → 25%", mode = { "n", "t" } },
            { "uh3", desc = "Height → 35%", mode = { "n", "t" } },
            { "uh4", desc = "Height → 45%", mode = { "n", "t" } },
        })
        wk.add({
            { "<leader>uw", group = "UI Sizing (Width)" },
            { "<leader>uw1", desc = "Width → 15%" },
            { "<leader>uw2", desc = "Width → 25%" },
            { "<leader>uw3", desc = "Width → 35%" },
            { "<leader>uw4", desc = "Width → 45%" },

            { "<leader>uh", group = "UI Sizing (Height)" },
            { "<leader>uh1", desc = "Height → 15%" },
            { "<leader>uh2", desc = "Height → 25%" },
            { "<leader>uh3", desc = "Height → 35%" },
            { "<leader>uh4", desc = "Height → 45%" },
        })
    end
end

-- UI SIZING --
