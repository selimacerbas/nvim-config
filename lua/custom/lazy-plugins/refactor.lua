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

        -- which-key v3: groups belong in `init`, not `keys`
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>r", group = "Refactor" } })
            end
        end,

        -- VISUAL: select code → <leader>re Extract Fn · <leader>rv Extract Var · <leader>ri Inline Var
        -- NORMAL: cursor on variable → <leader>ri Inline · <leader>rp Print · <leader>rP Cleanup prints
        keys = {
            -- Visual mode refactors (no <Esc>; keep selection active)
            { "<leader>re", function() require("refactoring").refactor("Extract Function") end, mode = "v", desc = "Extract Function", silent = true, noremap = true },
            { "<leader>rf", function() require("refactoring").refactor("Extract Function To File") end, mode = "v", desc = "Extract Function → File", silent = true, noremap = true },
            { "<leader>rv", function() require("refactoring").refactor("Extract Variable") end, mode = "v", desc = "Extract Variable", silent = true, noremap = true },
            { "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, mode = "v", desc = "Inline Variable", silent = true, noremap = true },
            { "<leader>rb", function() require("refactoring").refactor("Extract Block") end, mode = "v", desc = "Extract Block", silent = true, noremap = true },
            { "<leader>rr", function() require("refactoring").refactor("Extract Block To File") end, mode = "v", desc = "Extract Block → File", silent = true, noremap = true },
            { "<leader>rp", function() require("refactoring").debug.print_var({}) end, mode = "v", desc = "Debug: Print Var(s)", silent = true, noremap = true },
            -- optional Telescope UI (uncomment if you want it)
            -- { "<leader>rR", function() require("telescope").extensions.refactoring.refactors() end,    mode = "v", desc = "Telescope: Refactor…",      silent = true, noremap = true },

            -- Normal mode helpers
            { "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, mode = "n", desc = "Inline Variable (cursor)", silent = true, noremap = true },
            { "<leader>rp", function() require("refactoring").debug.print_var({}) end, mode = "n", desc = "Debug: Print Var", silent = true, noremap = true },
            { "<leader>rP", function() require("refactoring").debug.cleanup({}) end, mode = "n", desc = "Debug: Cleanup Prints", silent = true, noremap = true },
            -- { "<leader>rR", function() require("telescope").extensions.refactoring.refactors() end,    mode = "n", desc = "Telescope: Refactor…",      silent = true, noremap = true },
        },

        config = function()
            require("refactoring").setup({})
            pcall(function() require("telescope").load_extension("refactoring") end)
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
