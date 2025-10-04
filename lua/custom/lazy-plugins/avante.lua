return {
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        -- build from source on *nix; use PowerShell wrapper on Windows
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
            { -- paste images into Avante or normal buffers
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
            -- optional, improves Avante input UX if present
            "folke/snacks.nvim",
            "folke/which-key.nvim",
        },

        -- which-key group (no re-declare of plugin)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok and wk.add then
                wk.add({
                    { "<leader>a", group = "Avante" },
                })
            end
        end,

        -- Keymaps (all under <leader>a; no size bindings)
        keys = {
            -- your originals
            { "<leader>aa", "<cmd>AvanteAsk<CR>",                    desc = "Ask AI",             mode = "n", silent = true },
            { "<leader>a?", "<cmd>AvanteModels<CR>",                 desc = "Select Model",       mode = "n", silent = true },
            { "<leader>aB", "<cmd>AvanteBuild<CR>",                  desc = "Build Dependencies", mode = "n", silent = true },
            { "<leader>ac", "<cmd>AvanteChat<CR>",                   desc = "Chat Session",       mode = "n", silent = true },
            { "<leader>an", "<cmd>AvanteChatNew<CR>",                desc = "New Chat",           mode = "n", silent = true },
            { "<leader>ah", "<cmd>AvanteHistory<CR>",                desc = "Chat History",       mode = "n", silent = true },
            { "<leader>aC", "<cmd>AvanteClear<CR>",                  desc = "Clear Chat History", mode = "n", silent = true },
            { "<leader>ae", "<cmd>AvanteEdit<CR>",                   desc = "Edit Response",      mode = "n", silent = true },
            { "<leader>af", "<cmd>AvanteFocus<CR>",                  desc = "Focus Sidebar",      mode = "n", silent = true },
            { "<leader>ar", "<cmd>AvanteRefresh<CR>",                desc = "Refresh Sidebar",    mode = "n", silent = true },
            { "<leader>at", "<cmd>AvanteToggle<CR>",                 desc = "Toggle Sidebar",     mode = "n", silent = true },
            { "<leader>aS", "<cmd>AvanteStop<CR>",                   desc = "Stop AI Request",    mode = "n", silent = true },
            { "<leader>ap", "<cmd>AvanteSwitchProvider<CR>",         desc = "Switch Provider",    mode = "n", silent = true },
            { "<leader>aR", "<cmd>AvanteShowRepoMap<CR>",            desc = "Show Repo Map",      mode = "n", silent = true },
            { "<leader>as", "<cmd>AvanteSwitchSelectorProvider<CR>", desc = "Switch Selector",    mode = "n", silent = true },

            -- added quality-of-life
            {
                "<leader>aZ",
                function() pcall(function() require("avante.api").zen_mode() end) end,
                desc = "Zen Mode (CLI-like)",
                mode = "n",
                silent = true
            },
            {
                "<leader>aM",
                function()
                    local ok, cfg = pcall(require, "avante.config"); if not ok then return end
                    local now = (cfg.options.mode or "agentic")
                    local next = (now == "agentic") and "legacy" or "agentic"
                    cfg.override({ mode = next })
                    vim.notify("Avante mode → " .. next)
                end,
                desc = "Toggle Agentic/Legacy Mode",
                mode = "n",
                silent = true
            },
            {
                "<leader>aD",
                function()
                    local ok, cfg = pcall(require, "avante.config"); if not ok then return end
                    local e = (cfg.options.dual_boost and cfg.options.dual_boost.enabled) or false
                    cfg.override({ dual_boost = vim.tbl_deep_extend("force", cfg.options.dual_boost or {},
                        { enabled = not e }) })
                    vim.notify("Dual-Boost → " .. (not e and "ON" or "OFF"))
                end,
                desc = "Toggle Dual-Boost",
                mode = "n",
                silent = true
            },
            {
                "<leader>aL",
                function()
                    local dir = (vim.fn.stdpath("cache") .. "/avante_prompts")
                    if vim.fn.isdirectory(dir) == 0 then
                        vim.notify("No prompt logs yet", vim.log.levels.WARN); return
                    end
                    vim.cmd("vsplit " .. vim.fn.fnameescape(dir))
                end,
                desc = "Open Prompt Logs",
                mode = "n",
                silent = true
            },
            {
                "<leader>ai",
                function()
                    -- open or create instructions file at project root (avante.md)
                    local okp, path = pcall(require, "avante.path"); if not okp then return end
                    local root = path.get_project_root() or vim.loop.cwd()
                    local file = (root .. "/" .. (require("avante.config").options.instructions_file or "avante.md"))
                    if vim.fn.filereadable(file) == 0 then vim.fn.writefile({ "# avante.md – project guidance" }, file) end
                    vim.cmd("edit " .. vim.fn.fnameescape(file))
                end,
                desc = "Open avante.md (Project Instructions)",
                mode = "n",
                silent = true
            },
        },

        opts = {
            -- keep your chosen default provider; docs default to "claude"
            provider = "openai",

            -- IMPORTANT: Make the provider list robust & tool-safe
            providers = {
                openai = {
                    endpoint           = "https://api.openai.com/v1",
                    -- Tip: use a stable model. If your current model 404s, fall back to `gpt-4o-mini`.
                    model              = "gpt-4o-mini",
                    timeout            = 30000,
                    extra_request_body = { temperature = 0.8, max_completion_tokens = 8192 },
                },
                claude = {
                    endpoint = "https://api.anthropic.com",
                    model = "claude-3-5-sonnet-20241022",
                    extra_request_body = { temperature = 0.7, max_tokens = 4096 },
                },
                gemini = {
                    endpoint = "https://generativelanguage.googleapis.com", model = "gemini-2.5-pro",
                },
                ollama = {
                    endpoint = "http://127.0.0.1:11434",
                    model = "llama3.1:8b",
                    timeout = 60000,
                    extra_request_body = { options = { temperature = 0.4, num_ctx = 16384, keep_alive = "5m" } },
                },
                openrouter = {
                    __inherited_from = "openai",
                    endpoint = "https://openrouter.ai/api/v1",
                    api_key_name = "OPENROUTER_API_KEY",
                    model = "anthropic/claude-3.5-sonnet",
                },
                groq = {
                    __inherited_from = "openai",
                    endpoint = "https://api.groq.com/openai/v1/",
                    api_key_name = "GROQ_API_KEY",
                    model = "llama-3.1-70b-versatile",
                    extra_request_body = { max_tokens = 32768 },
                },
                perplexity = {
                    __inherited_from = "openai",
                    endpoint = "https://api.perplexity.ai",
                    api_key_name = "PPLX_API_KEY",
                    model = "llama-3.1-sonar-large-128k-online",
                    -- many search-first models don’t support tools well → keep tools off
                    disable_tools = true,
                },
                copilot = {
                    __inherited_from = "openai",
                    endpoint = "https://api.githubcopilot.com",
                    model = "gpt-4o-mini", -- Copilot backend; keep cheap
                    -- tool calls are flaky via Copilot endpoints
                    disable_tools = true,
                },
                deepseek = {
                    __inherited_from = "openai",
                    endpoint = "https://api.deepseek.com",
                    api_key_name = "DEEPSEEK_API_KEY",
                    model = "deepseek-coder",
                },
                qianwen = {
                    __inherited_from = "openai",
                    endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1",
                    api_key_name = "DASHSCOPE_API_KEY",
                    model = "qwen-coder-plus-latest",
                },
                mistral = {
                    __inherited_from = "openai",
                    endpoint = "https://api.mistral.ai/v1/",
                    api_key_name = "MISTRAL_API_KEY",
                    model = "mistral-large-latest",
                    extra_request_body = { max_tokens = 4096 },
                },
                -- Optional: Morph FastApply (see behaviour.enable_fastapply below)
                -- morph = { model = "morph-v3-large" },
            },

            -- Safer behaviour defaults
            mode = "agentic", -- or "legacy" if you prefer no tool use by default
            behaviour = {
                auto_suggestions = false,
                auto_set_highlight_group = true,
                auto_set_keymaps = false, -- you manage mappings yourself
                auto_apply_diff_after_generation = false,
                minimize_diff = true,
                enable_token_counting = true,
                auto_approve_tool_permissions = false, -- always prompt first
                -- enable_fastapply = true, -- uncomment if using Morph provider + MORPH_API_KEY
            },

            -- Write a per-project instructions file and keep templates overrideable
            instructions_file = "avante.md", -- auto-referenced at project root
            rules = {
                project_dir = ".avante/rules",
                global_dir  = vim.fn.expand("~/.config/avante/rules"),
            },

            -- Prompt logging = reproducibility & debugging
            prompt_logger = {
                enabled = true,
                log_dir = vim.fn.stdpath("cache") .. "/avante_prompts",
                fortune_cookie_on_success = false,
            },

            -- Picker/Input providers (auto-detect what you have installed)
            selector = (function()
                local has = function(m) return pcall(require, m) end
                return {
                    -- "native" | "fzf_lua" | "mini_pick" | "snacks" | "telescope"
                    provider = has("fzf-lua") and "fzf_lua"
                        or (has("mini.pick") and "mini_pick")
                        or (has("telescope") and "telescope")
                        or "native",
                    provider_opts = {},
                }
            end)(),
            input = (function()
                local has = function(m) return pcall(require, m) end
                return {
                    provider = has("snacks") and "snacks"
                        or (has("dressing") and "dressing")
                        or "native",
                    provider_opts = { title = "Avante Input" },
                }
            end)(),

            -- Web search engine for the built-in `web_search` tool
            web_search_engine = (function()
                local env = vim.env
                local provider =
                    (env.KAGI_API_KEY and "kagi")
                    or (env.BRAVE_API_KEY and "brave")
                    or (env.SERPAPI_API_KEY and "serpapi")
                    or (env.GOOGLE_SEARCH_API_KEY and env.GOOGLE_SEARCH_ENGINE_ID and "google")
                    or "tavily"
                return { provider = provider, proxy = nil }
            end)(),

            -- Safer diffs (avoid 'c' timeout conflicts)
            diff = {
                autojump = true,
                list_opener = "copen",
                override_timeoutlen = 500,
            },

            windows = {
                position = "right",
                wrap = true,
                input = { prefix = "> ", height = 8 },
                ask = { floating = false, start_insert = true, border = "rounded", focus_on_apply = "ours" },
                edit = { border = "rounded", start_insert = true },
            },

            -- Experimental: combine two models (toggle with <leader>aD)
            dual_boost = {
                enabled = false,
                first_provider = "openai",
                second_provider = "claude",
                prompt =
                "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
                timeout = 60000,
            },
        },

        config = function(_, opts)
            -- core lib
            require("avante_lib").load()

            -- build prompt/templates on first run if missing
            local function templates_missing()
                local ok_path, path = pcall(require, "avante.path")
                if not ok_path or type(path.get_templates_dir) ~= "function" then return true end
                local ok_dir, dir = pcall(path.get_templates_dir)
                if not ok_dir or type(dir) ~= "string" then return true end
                local fs = vim.uv or vim.loop
                return fs.fs_stat(dir) == nil
            end
            if templates_missing() then
                vim.schedule(function()
                    vim.notify("Avante: building templates (running :AvanteBuild)…", vim.log.levels.WARN)
                    pcall(vim.cmd, "AvanteBuild")
                end)
            end

            -- Optional MCP integration (safe if mcphub.nvim is not installed)
            local function mcp_system_prompt()
                local ok, hubmod = pcall(require, "mcphub"); if not ok then return "" end
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

            -- Keep splits visually stable while opening sidebars/popups
            vim.opt.splitkeep = "screen"

            -- Avoid fragile input hint popup timing
            pcall(function()
                local sidebar = require("avante.sidebar")
                if type(sidebar.show_input_hint) == "function" then
                    vim.g._avante_orig_show_input_hint = sidebar.show_input_hint
                    sidebar.show_input_hint = function(_) end
                end
            end)

            -- nvim-cmp: show avante’s completions if sources exist (safe no-op otherwise)
            pcall(function()
                local cmp = require("cmp")
                local s = cmp.get_config().sources or {}
                local names = {}
                for _, src in ipairs(s) do names[src.name] = true end
                local function add(name)
                    if not names[name] then table.insert(s, { name = name, priority = 900 }) end
                end
                -- these sources are provided by avante when nvim-cmp is present
                add("avante_commands")
                add("avante_mentions")
                add("avante_shortcuts")
                add("avante_files")
                cmp.setup({ sources = s })
            end)
        end,
    },
}
