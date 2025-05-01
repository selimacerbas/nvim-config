return
{
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
        local chatgpt = require("chatgpt")

        chatgpt.setup({
            openai_params = {
                model = "gpt-4.1-2025-04-14", -- ✅ valid model ID
                frequency_penalty = 0,
                presence_penalty = 0,
                max_tokens = 4095,
                temperature = 0.2,
                top_p = 0.1,
                n = 1,
            },
            actions_paths = {}, -- optionally load custom actions
        })

        -- ✅ Register which-key mappings (new spec)
        require("which-key").register({
            ["<leader>c"] = { name = "ChatGPT" },
            ["<leader>ca"] = { "<cmd>ChatGPTRun add_tests<CR>", desc = "Add Tests" },
            ["<leader>cc"] = { "<cmd>ChatGPT<CR>", desc = "ChatGPT UI" },
            ["<leader>cd"] = { "<cmd>ChatGPTRun docstring<CR>", desc = "Docstring" },
            ["<leader>ce"] = { "<cmd>ChatGPTEditWithInstructions<CR>", desc = "Edit with Instructions" },
            ["<leader>cf"] = { "<cmd>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs" },
            ["<leader>cg"] = { "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction" },
            ["<leader>ck"] = { "<cmd>ChatGPTRun keywords<CR>", desc = "Keywords" },
            ["<leader>cl"] = { "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability" },
            ["<leader>co"] = { "<cmd>ChatGPTRun optimize_code<CR>", desc = "Optimize Code" },
            ["<leader>cr"] = { "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit" },
            ["<leader>cs"] = { "<cmd>ChatGPTRun summarize<CR>", desc = "Summarize" },
            ["<leader>ct"] = { "<cmd>ChatGPTRun translate<CR>", desc = "Translate" },
            ["<leader>cx"] = { "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain Code" },
        }, { mode = { "n", "v" } })
    end,
    dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "folke/which-key.nvim",
    },
}
