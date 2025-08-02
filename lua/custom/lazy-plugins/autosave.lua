return {

    -- Auto-save plugin, these values are default values.
    {
        'Pocco81/auto-save.nvim',
        config = function()
            require("auto-save").setup({
                enabled = true,  -- Start enabled by default
                execution_message = {
                    message = function() -- customize the save message
                        return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
                    end,
                },
                trigger_events = { "InsertLeave", "TextChanged", }, -- Auto-save after leaving insert mode or changing text
                conditions = {
                    exists = true,                          -- Only save if the file exists
                    modifiable = true,                      -- Only save if the buffer is modifiable
                },
                clean_command_line_interval = 0,            -- Don't display the save message for a long time
                debounce_delay = 135,                       -- Delay (in milliseconds) before saving after changes
            })
        end
    },

    -- Add more plugins below as needed
}
