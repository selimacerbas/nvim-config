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
            {
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
            {
                "MeanderingProgrammer/render-markdown.nvim",
                ft    = { "markdown", "Avante" },
                latex = { enabled = false }, -- Set true if LaTex Support needed. But you may need to install some dependecies checkhealth it.
                opts  = { file_types = { "markdown", "Avante" } },
            },
            "folke/which-key.nvim",
        },
        opts = {
            provider  = "openai",
            providers = {
                openai = {
                    endpoint           = "https://api.openai.com/v1",
                    model              = "gpt-4.1-mini",
                    timeout            = 30000,
                    extra_request_body = {
                        temperature           = 0,
                        max_completion_tokens = 8192,
                    },
                },
                copilot = {},
            },
            -- Activate here if there is conflict between Avante Tools anc MCP Servers.
            -- disabled_tools = {
            --     "list_files", -- Built-in file operations
            --     "search_files",
            --     "read_file",
            --     "create_file",
            --     "rename_file",
            --     "delete_file",
            --     "create_dir",
            --     "rename_dir",
            --     "delete_dir",
            --     "bash", -- Built-in terminal access
            -- },
        },
        config = function(_, opts)
            -- load Avante core
            require("avante_lib").load()

            -- merge in MCP Hub prompts & tools
            local av_opts = vim.tbl_extend("force", opts, {
                system_prompt = function()
                    local hub = require("mcphub").get_hub_instance()
                    return hub and hub:get_active_servers_prompt() or ""
                end,
                custom_tools = function()
                    return {
                        require("mcphub.extensions.avante").mcp_tool(),
                    }
                end,
            })

            require("avante").setup(av_opts)

            local wk_ok, which_key = pcall(require, "which-key")
            if not wk_ok then return end

            which_key.register({
                a = {
                    name  = "Avante",
                    a     = { "<cmd>AvanteAsk<CR>", "Ask AI" },
                    ["?"] = { "<cmd>AvanteModels<CR>", "Select Model" },
                    B     = { "<cmd>AvanteBuild<CR>", "Build Dependencies" },
                    c     = { "<cmd>AvanteChat<CR>", "Chat Session" },
                    n     = { "<cmd>AvanteChatNew<CR>", "New Chat" },
                    h     = { "<cmd>AvanteHistory<CR>", "Chat History" },
                    C     = { "<cmd>AvanteClear<CR>", "Clear Chat History" },
                    e     = { "<cmd>AvanteEdit<CR>", "Edit Response" },
                    f     = { "<cmd>AvanteFocus<CR>", "Focus Sidebar" },
                    r     = { "<cmd>AvanteRefresh<CR>", "Refresh Sidebar" },
                    t     = { "<cmd>AvanteToggle<CR>", "Toggle Sidebar" },
                    S     = { "<cmd>AvanteStop<CR>", "Stop AI Request" },
                    p     = { "<cmd>AvanteSwitchProvider<CR>", "Switch Provider" },
                    R     = { "<cmd>AvanteShowRepoMap<CR>", "Show Repo Map" },
                    s     = { "<cmd>AvanteSwitchSelectorProvider<CR>", "Switch Selector" },
                },
            }, { prefix = "<leader>" })
        end,
    },
}
