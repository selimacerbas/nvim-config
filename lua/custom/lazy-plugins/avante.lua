return {
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        build = function()
            if vim.fn.has("win32") == 1 then
                return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
            else
                return "make"
            end
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "echasnovski/mini.pick",
            "nvim-telescope/telescope.nvim",
            "hrsh7th/nvim-cmp",
            "ibhagwan/fzf-lua",
            "stevearc/dressing.nvim",
            "zbirenbaum/copilot.lua",
            { -- paste images
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name  = false,
                        drag_and_drop         = { insert_mode = true },
                        use_absolute_path     = true,
                    },
                },
            },
            { -- render markdown in Avante panes
                "MeanderingProgrammer/render-markdown.nvim",
                ft   = { "markdown", "Avante" },
                opts = { file_types = { "markdown", "Avante" }, latex = { enabled = false } },
            },
            "folke/which-key.nvim",
        },

        -- make the group visible as soon as which-key is around
        init = function()
            local ok, wk = pcall(require, "which-key")
            if not ok then return end
            if wk.add then
                -- wk.add({ { "<leader>a", group = "Avante" } })             -- v3
            else
                -- wk.register({ a = { name = "Avante" } }, { prefix = "<leader>" }) -- v2
            end
        end,

        -- define keymaps up-front so which-key can show them immediately
        keys = {
            { "<leader>aa", "<cmd>AvanteAsk<CR>",                    desc = "Ask AI" },
            { "<leader>a?", "<cmd>AvanteModels<CR>",                 desc = "Select Model" },
            { "<leader>aB", "<cmd>AvanteBuild<CR>",                  desc = "Build Dependencies" },
            { "<leader>ac", "<cmd>AvanteChat<CR>",                   desc = "Chat Session" },
            { "<leader>an", "<cmd>AvanteChatNew<CR>",                desc = "New Chat" },
            { "<leader>ah", "<cmd>AvanteHistory<CR>",                desc = "Chat History" },
            { "<leader>aC", "<cmd>AvanteClear<CR>",                  desc = "Clear Chat History" },
            { "<leader>ae", "<cmd>AvanteEdit<CR>",                   desc = "Edit Response" },
            { "<leader>af", "<cmd>AvanteFocus<CR>",                  desc = "Focus Sidebar" },
            { "<leader>ar", "<cmd>AvanteRefresh<CR>",                desc = "Refresh Sidebar" },
            { "<leader>at", "<cmd>AvanteToggle<CR>",                 desc = "Toggle Sidebar" },
            { "<leader>aS", "<cmd>AvanteStop<CR>",                   desc = "Stop AI Request" },
            { "<leader>ap", "<cmd>AvanteSwitchProvider<CR>",         desc = "Switch Provider" },
            { "<leader>aR", "<cmd>AvanteShowRepoMap<CR>",            desc = "Show Repo Map" },
            { "<leader>as", "<cmd>AvanteSwitchSelectorProvider<CR>", desc = "Switch Selector" },
        },

        opts = {
            provider  = "openai",
            providers = {
                openai  = {
                    endpoint           = "https://api.openai.com/v1",
                    model              = "gpt-5-mini-2025-08-07", -- your choice
                    timeout            = 30000,
                    extra_request_body = {
                        temperature = 1,
                        max_completion_tokens = 8192,
                    },
                },
                copilot = {},
            },
            -- If Avante's built-ins clash with MCP tools, uncomment to disable:
            -- disabled_tools = { "list_files","search_files","read_file","create_file","rename_file","delete_file","create_dir","rename_dir","delete_dir","bash" },
        },

        config = function(_, opts)
            -- load Avante core
            require("avante_lib").load()

            -- safe MCP integration (no-op if mcphub/extension missing)
            local function mcp_system_prompt()
                local ok, hubmod = pcall(require, "mcphub")
                if not ok then return "" end
                local hub = hubmod.get_hub_instance and hubmod.get_hub_instance()
                return (hub and hub.get_active_servers_prompt and hub:get_active_servers_prompt()) or ""
            end
            local function mcp_tool()
                local ok, ext = pcall(require, "mcphub.extensions.avante")
                return (ok and ext.mcp_tool and ext.mcp_tool()) or nil
            end

            local merged = vim.tbl_deep_extend("force", opts, {
                system_prompt = mcp_system_prompt,
                custom_tools  = function()
                    local t = mcp_tool()
                    return t and { t } or {}
                end,
            })

            require("avante").setup(merged)
        end,
    },
}
