return {
    {
        "theprimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "folke/which-key.nvim",
            -- optional fuzzy menu:
            "nvim-telescope/telescope.nvim",
        },

        -- Basics:
        --  • VISUAL: select code → <leader>re Extract Fn · <leader>rv Extract Var · <leader>ri Inline Var
        --  • NORMAL: cursor on variable → <leader>ri Inline · <leader>rp Print · <leader>rP Cleanup prints
        keys = {
            -- Visual mode refactors
            { "<leader>re", "<Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>", mode = "v", desc = "Extract Function" },
            { "<leader>rf", "<Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>", mode = "v", desc = "Extract Function → File" },
            { "<leader>rv", "<Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>", mode = "v", desc = "Extract Variable" },
            { "<leader>ri", "<Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>", mode = "v", desc = "Inline Variable" },
            { "<leader>rb", "<Esc><Cmd>lua require('refactoring').refactor('Extract Block')<CR>", mode = "v", desc = "Extract Block" },
            { "<leader>rr", "<Esc><Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>", mode = "v", desc = "Extract Block → File" },
            { "<leader>rp", "<Esc><Cmd>lua require('refactoring').debug.print_var({})<CR>", mode = "v", desc = "Debug: Print Var(s)" },
            -- { "<leader>rR", "<Esc><Cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",      mode = "v", desc = "Telescope: Refactor…" }, -- optional

            -- Normal mode helpers
            { "<leader>ri", "<Cmd>lua require('refactoring').refactor('Inline Variable')<CR>", mode = "n", desc = "Inline Variable (cursor)" },
            { "<leader>rp", "<Cmd>lua require('refactoring').debug.print_var({})<CR>", mode = "n", desc = "Debug: Print Var" },
            { "<leader>rP", "<Cmd>lua require('refactoring').debug.cleanup({})<CR>", mode = "n", desc = "Debug: Cleanup Prints" },
            -- { "<leader>rR", "<Cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",           mode = "n", desc = "Telescope: Refactor…" },  -- optional
        },

        config = function()
            require("refactoring").setup({})
            pcall(function() require("telescope").load_extension("refactoring") end)

            -- which-key v3 group label
            local ok, wk = pcall(require, "which-key")
            if ok then
                (wk.add or wk.register)({
                        { "<leader>r", group = "Refactor" },
                    })
            end
        end,
    },
}
-- HOW TO USE (quick examples)
--
-- 1) Extract Function  (VISUAL)  <leader>r e
--    JS/TS example:
--      Before:
--        function greet() {
--          const msg = "hello";
--          console.log(msg.toUpperCase());  <-- visually select this line
--        }
--      Action: <leader>r e  → prompts for new function name
--      After:
--        function greet() {
--          const msg = "hello";
--          NEW_FUNC_NAME(msg);
--        }
--        function NEW_FUNC_NAME(msg) {
--          console.log(msg.toUpperCase());
--        }
--
-- 2) Extract Variable (VISUAL)  <leader>r v
--    Python example:
--      Before:   total = price * tax_rate + shipping
--                           ^^^^^^^^ select "price * tax_rate"
--      Action:   <leader>r v → name it e.g. subtotal
--      After:    subtotal = price * tax_rate
--                total    = subtotal + shipping
--
-- 3) Inline Variable (VISUAL or NORMAL)  <leader>r i
--    Go example:
--      Before:
--        n := a + b
--        fmt.Println(n)
--      Action: cursor on `n`  → <leader>r i
--      After:
--        fmt.Println(a + b)
--
-- 4) Extract Block / Extract Block To File (VISUAL)  <leader>r b / <leader>r r
--    Useful to split a long loop/if-body into its own function or file.
--
-- 5) Extract Function To File (VISUAL)  <leader>r f
--    Prompts for a file path; moves the new function there and inserts a call.
--
-- 6) Debug helpers:
--    • Print variable under cursor/selection:  <leader>r p
--    • Remove all inserted debug prints:       <leader>r P
---------------------------------------------------------------------------
