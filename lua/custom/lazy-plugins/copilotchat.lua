return {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = "VeryLazy",
    build = "make tiktoken",
    dependencies = {
        "zbirenbaum/copilot.lua", -- or "github/copilot.vim"
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("CopilotChat").setup({
            -- Default AI assistant
            agent = "copilot",

            -- Chat window layout
            window = {
                layout = "vertical",
                position = "right",
                width = 0.4,
            },

            -- Predefined agents — add your own below
            agents = {
                copilot = {
                    provider = "copilot",
                    model = "gpt-4",
                    system_prompt = "You are a helpful AI assistant.",
                },
            },

            -- Easy to extend later with:
            -- prompts = { ... },
            -- contexts = { ... },
        })

        -- Optional key mappings
        local wk = require("which-key")
        wk.register({
            ["<leader>pc"] = { "<cmd>CopilotChat<CR>", "Copilot Chat: Open" },
            ["<leader>pt"] = { "<cmd>CopilotChatToggle<CR>", "Copilot Chat: Toggle" },
            ["<leader>pp"] = { "<cmd>CopilotChatPrompts<CR>", "Copilot Chat: Select Prompt" },
            ["<leader>pm"] = { "<cmd>CopilotChatModels<CR>", "Copilot Chat: Select Model" },
            ["<leader>pa"] = { "<cmd>CopilotChatAgents<CR>", "Copilot Chat: Select Agent" },
        }, { mode = "n" })
    end,
}
