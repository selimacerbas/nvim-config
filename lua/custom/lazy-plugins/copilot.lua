return {
    -- Community Copilot
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            suggestion = {
                enabled = false,
                auto_trigger = false,
            },
            panel = {
                enabled = false,
                auto_refresh = false,
            },
        })

        -- Keymap: Toggle Copilot suggestions
        vim.keymap.set("n", "<leader>ps", function()
            require("copilot.suggestion").toggle_auto_trigger()
        end, { desc = "Toggle Copilot Suggestions" })
    end,

- -- GitHub Copilot NVIM
-- {
--     "github/copilot.vim",
--     config = function()
--         -- Disable Copilot by default
--         vim.g.copilot_enabled = false
--
--         -- Optional: Disable the default Tab mapping
--         vim.g.copilot_no_tab_map = true
--
--         -- Set up a custom keybinding for accepting suggestions
--         vim.api.nvim_set_keymap(
--             "i",
--             "<C-L>",
--             "copilot#Accept('<CR>')",
--             { silent = true, expr = true }
--         )
--
--         -- Optional: Add a command to toggle Copilot
--         vim.api.nvim_create_user_command(
--             "CopilotToggle",
--             function()
--                 vim.g.copilot_enabled = not vim.g.copilot_enabled
--                 print("Copilot enabled: " .. tostring(vim.g.copilot_enabled))
--             end,
--             {}
--         )
--     end,
-- }
