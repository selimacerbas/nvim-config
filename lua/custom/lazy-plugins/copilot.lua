return {
    -- GitHub Copilot NVIM
    {
        "github/copilot.vim",
        config = function()
            -- Disable Copilot by default
            vim.g.copilot_enabled = false

            -- Optional: Disable the default Tab mapping
            vim.g.copilot_no_tab_map = true

            -- Set up a custom keybinding for accepting suggestions
            vim.api.nvim_set_keymap(
                "i",
                "<C-L>",
                "copilot#Accept('<CR>')",
                { silent = true, expr = true }
            )

            -- Optional: Add a command to toggle Copilot
            vim.api.nvim_create_user_command(
                "CopilotToggle",
                function()
                    vim.g.copilot_enabled = not vim.g.copilot_enabled
                    print("Copilot enabled: " .. tostring(vim.g.copilot_enabled))
                end,
                {}
            )
        end,
    },
}
