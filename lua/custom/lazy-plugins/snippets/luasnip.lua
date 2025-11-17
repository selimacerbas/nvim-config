-- lua/plugins/luasnip.lua
return {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    event = "InsertEnter",

    config = function()
        local ls = require("luasnip")

        -- Core LuaSnip behaviour
        ls.config.set_config({
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = false,
            -- you can turn this into a ft_func if you ever want more advanced ft mapping
        })

        ----------------------------------------------------------------
        -- Keymaps for navigating snippets
        ----------------------------------------------------------------
        vim.keymap.set({ "i", "s" }, "<C-j>", function()
            if ls.expand_or_jumpable() then
                ls.expand_or_jump()
            end
        end, { desc = "LuaSnip: expand/jump" })

        vim.keymap.set({ "i", "s" }, "<C-k>", function()
            if ls.jumpable(-1) then
                ls.jump(-1)
            end
        end, { desc = "LuaSnip: jump back" })

        -- If you ever use choice nodes:
        -- vim.keymap.set("i", "<C-l>", function()
        --   if ls.choice_active() then
        --     ls.change_choice(1)
        --   end
        -- end, { desc = "LuaSnip: next choice" })
    end,
}
