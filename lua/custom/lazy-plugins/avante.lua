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
            -- default selection (you can change this anytime with <leader>ap)
            provider  = "openai",

            -- all providers you want available
            providers = {
                -- OpenAI (default)
                openai = {
                    endpoint           = "https://api.openai.com/v1",
                    model              = "gpt-5-mini-2025-08-07", -- pick your favorite
                    timeout            = 30000,
                    -- put request-body fields under extra_request_body
                    extra_request_body = {
                        temperature = 1,
                        max_completion_tokens = 8192,
                        -- reasoning_effort = "medium", -- for reasoning models
                    },
                    -- api_key_name = "OPENAI_API_KEY", -- optional if env var is already named like this
                },

                -- Anthropic Claude
                claude = {
                    -- endpoint is built-in; you usually only need key + model
                    api_key_name       = "ANTHROPIC_API_KEY",
                    model              = "claude-3-5-sonnet-latest",
                    extra_request_body = { temperature = 0.7 },
                },

                -- Google Gemini
                gemini = {
                    api_key_name = "GEMINI_API_KEY",
                    model        = "gemini-2.5-pro",
                    -- gemini has its own body shape; Avante handles it internally.
                    -- extra request options can go here if you need them:
                    -- extra_request_body = { generationConfig = { stopSequences = {"END"} } }
                },

                -- Local (Ollama) — first-class provider in Avante now
                ollama = {
                    endpoint           = "http://127.0.0.1:11434", -- no trailing /v1
                    model              = "llama3.1:8b",
                    timeout            = 60000,
                    extra_request_body = {
                        options = { temperature = 0.4, num_ctx = 16384, keep_alive = "5m" },
                    },
                },

                -- OpenAI-compatible vendors (inherit from 'openai')
                openrouter = {
                    __inherited_from = "openai",
                    endpoint         = "https://openrouter.ai/api/v1",
                    api_key_name     = "OPENROUTER_API_KEY",
                    model            = "anthropic/claude-3.5-sonnet",
                },
                groq = {
                    __inherited_from   = "openai",
                    endpoint           = "https://api.groq.com/openai/v1/",
                    api_key_name       = "GROQ_API_KEY",
                    model              = "llama-3.1-70b-versatile",
                    extra_request_body = { max_tokens = 32768 },
                },
                perplexity = {
                    __inherited_from = "openai",
                    endpoint         = "https://api.perplexity.ai",
                    api_key_name     = "PPLX_API_KEY", -- or use secret manager (see note below)
                    model            = "llama-3.1-sonar-large-128k-online",
                },
                deepseek = {
                    __inherited_from = "openai",
                    endpoint         = "https://api.deepseek.com",
                    api_key_name     = "DEEPSEEK_API_KEY",
                    model            = "deepseek-coder",
                },
                qianwen = { -- Qwen (DashScope compatible)
                    __inherited_from = "openai",
                    endpoint         = "https://dashscope.aliyuncs.com/compatible-mode/v1",
                    api_key_name     = "DASHSCOPE_API_KEY",
                    model            = "qwen-coder-plus-latest",
                },
                mistral = {
                    __inherited_from   = "openai",
                    endpoint           = "https://api.mistral.ai/v1/",
                    api_key_name       = "MISTRAL_API_KEY",
                    model              = "mistral-large-latest",
                    extra_request_body = { max_tokens = 4096 },
                },
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
