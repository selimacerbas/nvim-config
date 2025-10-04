-- Configuration; We have to create a .json file which will store the API KEYs for the servers. The JSON file will look like as below.
--  API KEY can also be put in .zshrc file and exported as ENV variable.
-- {
--   "mcpServers": {
--     "fetch": {
--       "command": "uvx",
--       "args": ["mcp-server-fetch", "$API_KEY"], //replaces $API_KEY with API_KEY from env field
--jjjkk       "env": {
--         "API_KEY": "",                 // Falls back to process.env.API_KEY
--         "SERVER_URL": null,            // Falls back to process.env.SERVER_URL
--         "AUTH_HEADER": "BEARER ${API_KEY}", // ${API_KEY} is replaced with resolved value of API_KEY in the env field falling back to process.env
--         "DEBUG": "true"               // Direct value, no fallback
--       }
--     },
--     "remote-server": {
--       "url": "https://api.example.com/mcp", // Auto determine streamable-http or sse, Auto OAuth authorization
--       "headers": {                          // Explicit headers
--         "Authorization": "Bearer ${API_KEY}" // ${API_KEY} is replaced with process.env.API_KEY
--       }
--     }
--   }
-- }

-- MCP Hub: manage local MCP servers and expose Avante integration
-- MCP Hub: manage local/remote MCP servers + Avante slash-commands
return {
    {
        "ravitemer/mcphub.nvim",
        cmd = { "MCPHub" }, -- lazy-load on :MCPHub
        dependencies = {
            "nvim-lua/plenary.nvim",
            "folke/which-key.nvim",
        },
        build = "npm install -g mcp-hub@latest",

        -- which-key v3: register the group early
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({ { "<leader>h", group = "MCPHub" } })
            end
        end,

        -- v3-friendly keymaps (lazy-loads the plugin, then runs the actions)
        keys = {
            { "<leader>hb", "<cmd>MCPHub<CR>", desc = "MCPHub: Open/Toggle UI", mode = "n", silent = true, noremap = true },

            {
                "<leader>ha",
                function()
                    -- runtime toggle for auto-approve (fallback to a simple global)
                    local ok, hubmod = pcall(require, "mcphub")
                    local v = vim.g.mcphub_auto_approve
                    if type(v) ~= "boolean" then v = false end
                    v = not v
                    vim.g.mcphub_auto_approve = v
                    -- if the plugin exposes a setter, try to use it
                    if ok and hubmod.set_auto_approve then pcall(hubmod.set_auto_approve, v) end
                    vim.notify("MCP auto-approve: " .. (v and "ON" or "OFF"))
                end,
                desc = "MCPHub: Toggle Auto-Approve",
                mode = "n",
                silent = true,
                noremap = true
            },

            {
                "<leader>he",
                function()
                    -- edit servers.json (workspace first)
                    local look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" }
                    local cwd = vim.fn.getcwd()
                    for _, rel in ipairs(look_for) do
                        local p = cwd .. "/" .. rel
                        if (vim.uv or vim.loop).fs_stat(p) then
                            vim.cmd.edit(p)
                            return
                        end
                    end
                    local global = vim.fn.expand("~/.config/mcphub/servers.json")
                    vim.fn.mkdir(vim.fn.fnamemodify(global, ":h"), "p")
                    vim.cmd.edit(global)
                end,
                desc = "MCPHub: Edit servers.json",
                mode = "n",
                silent = true,
                noremap = true
            },

            {
                "<leader>hr",
                function()
                    local ok, hubmod = pcall(require, "mcphub")
                    local hub = ok and hubmod.get_hub_instance and hubmod.get_hub_instance() or nil
                    if hub and hub.restart then hub:restart() else vim.cmd("MCPHub") end
                end,
                desc = "MCPHub: Restart / Open",
                mode = "n",
                silent = true,
                noremap = true
            },

            {
                "<leader>hR",
                function()
                    local ok, hubmod = pcall(require, "mcphub")
                    local hub = ok and hubmod.get_hub_instance and hubmod.get_hub_instance() or nil
                    if hub and hub.hard_refresh then
                        hub:hard_refresh()
                    else
                        vim.notify("Open MCPHub first: <leader>hb", vim.log.levels.WARN) -- fixed hint key
                    end
                end,
                desc = "MCPHub: Hard Refresh",
                mode = "n",
                silent = true,
                noremap = true
            },
        },

        opts = {
            -- Binary / hub process
            config                  = vim.fn.expand("~/.config/mcphub/servers.json"),
            port                    = 37373,
            shutdown_delay          = 5 * 60 * 1000,
            use_bundled_binary      = false,
            mcp_request_timeout     = 60000,

            -- Workspace awareness
            workspace               = {
                enabled               = true,
                look_for              = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" },
                reload_on_dir_changed = true,
                port_range            = { min = 40000, max = 41000 },
            },

            -- Chat plugin integrations
            auto_approve            = true, -- can be toggled at runtime via <leader>ha
            auto_toggle_mcp_servers = true,
            extensions              = {
                avante = {
                    make_slash_commands = true, -- exposes /mcp:server:prompt
                },
            },

            -- UI
            ui                      = {
                window = {
                    width = 0.85,
                    height = 0.85,
                    align = "center",
                    border = "rounded",
                    relative = "editor",
                    zindex = 50,
                },
                wo = { winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder" },
            },
        },

        config = function(_, opts)
            require("mcphub").setup(opts)
            -- which-key v3 will show labels from keys; no extra registration needed here.
        end,
    },
}
