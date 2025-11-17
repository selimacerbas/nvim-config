-- lua/plugins/friendly-snippets.lua
return {
    "rafamadriz/friendly-snippets",

    dependencies = { "L3MON4D3/LuaSnip" },
    event = "InsertEnter",

    config = function()
        local ls = require("luasnip")

        ----------------------------------------------------------------
        -- Load VSCode-style snippets (friendly-snippets)
        ----------------------------------------------------------------
        require("luasnip.loaders.from_vscode").lazy_load()

        -- If you have your own VSCode-style snippets somewhere:
        -- require("luasnip.loaders.from_vscode").lazy_load({
        --   paths = { vim.fn.stdpath("config") .. "/my-snippets" },
        -- })

        ----------------------------------------------------------------
        -- Share HTML snippets with TS / TSX / JS / JSX
        ----------------------------------------------------------------
        -- This is the key bit people generally recommend for TSX/JSX:
        -- use `html` snippets (and optionally JS/React snippets) in those fts.
        ----------------------------------------------------------------
        ls.filetype_extend("typescriptreact", { "html", "javascriptreact", "javascript" })
        ls.filetype_extend("javascriptreact", { "html", "javascript" })

        -- If you also want HTML snippets in plain TS/JS:
        ls.filetype_extend("typescript", { "html", "javascript" })
        ls.filetype_extend("javascript", { "html" })
    end,
}
