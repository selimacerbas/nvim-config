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
        cmd = { "MCPHub" },      -- lazy-load on :MCPHub
        keys = {                 -- and on these leader keys
            { "<leader>mb", "<cmd>MCPHub<CR>", desc = "MCPHub: Open/Toggle UI" },
            {
                "<leader>ma",
                function()       -- toggle auto-approve (runtime-safe)
                    local v = vim.g.mcphub_auto_approve
                    if type(v) ~= "boolean" then v = false end
                    vim.g.mcphub_auto_approve = not v
                    vim.notify("MCP auto-approve: " .. (vim.g.mcphub_auto_approve and "ON" or "OFF"))
                end,
                desc = "MCPHub: Toggle Auto-Approve"
            },
            {
                "<leader>me",
                function()       -- edit servers.json (workspace first)
                    local look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" }
                    local cwd = vim.fn.getcwd()
                    for _, rel in ipairs(look_for) do
                        local p = cwd .. "/" .. rel
                        if vim.uv.fs_stat(p) then
                            vim.cmd.edit(p); return
                        end
                    end
                    local global = vim.fn.expand("~/.config/mcphub/servers.json")
                    vim.fn.mkdir(vim.fn.fnamemodify(global, ":h"), "p")
                    vim.cmd.edit(global)
                end,
                desc = "MCPHub: Edit servers.json"
            },
            {
                "<leader>mr",
                function()       -- restart hub if running
                    local hub = (pcall(require, "mcphub") and require("mcphub").get_hub_instance()) or nil
                    if hub and hub.restart then hub:restart() else vim.cmd("MCPHub") end
                end,
                desc = "MCPHub: Restart / Open"
            },
            {
                "<leader>mR",
                function()       -- hard refresh the hub state
                    local hub = (pcall(require, "mcphub") and require("mcphub").get_hub_instance()) or nil
                    if hub and hub.hard_refresh then
                        hub:hard_refresh()
                    else
                        vim.notify("Open MCPHub first: <leader>mb", vim.log.levels.WARN)
                    end
                end,
                desc = "MCPHub: Hard Refresh"
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "folke/which-key.nvim",
        },
        -- Installs the Node CLI that actually manages MCP servers
        -- (global install; see docs for local/bundled alternatives)
        build = "npm install -g mcp-hub@latest",
        opts = {
            -- Binary / hub process
            config                  = vim.fn.expand("~/.config/mcphub/servers.json"),
            port                    = 37373,
            shutdown_delay          = 5 * 60 * 1000, -- keep hub around for fast re-entry
            use_bundled_binary      = false, -- set true if you switch to bundled_build.lua
            mcp_request_timeout     = 60000,

            -- Workspace awareness (project-local configs are auto-merged)
            workspace               = {
                enabled               = true,
                look_for              = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" },
                reload_on_dir_changed = true,
                port_range            = { min = 40000, max = 41000 },
            },

            -- Chat plugin integrations
            auto_approve            = true, -- you can toggle live with <leader>ma
            auto_toggle_mcp_servers = true, -- let LLMs start/stop servers as needed
            extensions              = {
                avante = {
                    make_slash_commands = true, -- exposes /mcp:server:prompt
                },
            },

            -- UI polish (optional)
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

            -- which-key (v3-safe) group + labels
            local ok, wk = pcall(require, "which-key")
            if not ok then return end
            local add = wk.add or function(spec, o) wk.register(spec, o) end
            add({
                -- { "<leader>h",  group = "MCPHub" },
                { "<leader>hb", desc = "MCPHub: Open/Toggle UI" },
                { "<leader>ha", desc = "MCPHub: Toggle Auto-Approve" },
                { "<leader>he", desc = "MCPHub: Edit servers.json" },
                { "<leader>hr", desc = "MCPHub: Restart / Open" },
                { "<leader>hR", desc = "MCPHub: Hard Refresh" },
            })
        end,
    },
}
