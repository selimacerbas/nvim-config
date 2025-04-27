return
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

{
    "ravitemer/mcphub.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    build        = "npm install -g mcp-hub@latest",
    config       = function()
        require("mcphub").setup()
    end,
}
