-- pipeline.nvim + Telescope pickers (+ themed) + lualine badge
return {
    {
        "topaxi/pipeline.nvim",
        cmd = { "Pipeline" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "folke/which-key.nvim",
            "nvim-telescope/telescope.nvim",
        },
        build = "make", -- or install `yq` instead (see README)
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                if wk.add then
                    wk.add({ { "<leader>p", group = "Pipeline" } })
                end
            end
        end,
        keys = {
            { "<leader>op", "<cmd>Pipeline toggle<CR>",                               desc = "Pipeline: Toggle panel" },
            { "<leader>oo", "<cmd>Pipeline open<CR>",                                 desc = "Pipeline: Open panel" },
            { "<leader>oc", "<cmd>Pipeline close<CR>",                                desc = "Pipeline: Close panel" },

            -- Themed Telescope pickers
            { "<leader>or", function() require("pipeline.telescope").runs() end,      desc = "Pipeline: Runs (Telescope)" },
            { "<leader>ow", function() require("pipeline.telescope").workflows() end, desc = "Pipeline: Dispatch workflow/pipeline" },
        },

        ---@type pipeline.Config
        opts = {
            refresh_interval = 10,
            dispatch_branch  = "default",
            allowed_hosts    = {}, -- add enterprise hosts if needed
            providers        = {
                github = { default_host = "github.com", resolve_host = function(h) return h end },
                gitlab = { default_host = "gitlab.com", resolve_host = function(h) return h end },
            },

            -- 🔧 our wrapper option (used only by the Telescope helpers below)
            telescope_theme  = "ivy", -- change to "dropdown" if you prefer
        },

        config = function(_, opts)
            require("pipeline").setup(opts)

            -- which-key buffer hints inside Pipeline panel
            local ok_wk, wk = pcall(require, "which-key")
            if ok_wk then
                vim.api.nvim_create_autocmd("BufEnter", {
                    callback = function(ev)
                        if vim.bo[ev.buf].filetype ~= "pipeline" then return end
                        if wk.add then
                            wk.add({
                                { "q",  desc = "Close panel",                           mode = "n", buffer = ev.buf },
                                { "gp", desc = "Open pipeline in browser",              mode = "n", buffer = ev.buf },
                                { "gr", desc = "Open run in browser",                   mode = "n", buffer = ev.buf },
                                { "gj", desc = "Open job of run in browser",            mode = "n", buffer = ev.buf },
                                { "d",  desc = "Dispatch workflow (workflow_dispatch)", mode = "n", buffer = ev.buf },
                            })
                        else
                            wk.register({
                                q = "Close panel",
                                gp = "Open pipeline in browser",
                                gr = "Open run in browser",
                                gj = "Open job in browser",
                                d = "Dispatch workflow",
                            }, { mode = "n", buffer = ev.buf })
                        end
                    end,
                })
            end

            ---------------------------------------------------------------------
            -- Telescope integration (with theme)
            ---------------------------------------------------------------------
            local Job     = require("plenary.job")
            local pickers = require("telescope.pickers")
            local finders = require("telescope.finders")
            local conf    = require("telescope.config").values
            local actions = require("telescope.actions")
            local state   = require("telescope.actions.state")
            local themes  = require("telescope.themes")

            local function themed_opts(title)
                if opts.telescope_theme == "dropdown" then
                    return themes.get_dropdown({ prompt_title = title, previewer = false })
                else
                    return themes.get_ivy({ prompt_title = title })
                end
            end

            local function detect_repo()
                local url = vim.trim(vim.fn.system({ "git", "config", "--get", "remote.origin.url" }))
                if url == "" then return nil end
                local host, owner, repo = url:match("^git@([^:]+):([^/]+)/([^%.]+)%.?git?$")
                if not host then host, owner, repo = url:match("^https?://([^/]+)/([^/]+)/([^%.]+)%.?git?$") end
                return host and { host = host, owner = owner, repo = repo } or nil
            end

            local function open_url(url)
                if vim.ui and vim.ui.open and pcall(vim.ui.open, url) then return end
                if vim.fn.has("mac") == 1 then
                    vim.fn.jobstart({ "open", url }, { detach = true })
                elseif vim.fn.has("win32") == 1 then
                    vim.fn.jobstart({ "cmd", "/c", "start", url }, { detach = true })
                else
                    vim.fn.jobstart({ "xdg-open", url }, { detach = true })
                end
            end

            local M = {}

            -- Runs picker (GitHub: gh run list --json … ; GitLab: glab ci list --output json)
            function M.runs()
                local repo = detect_repo()
                local is_gh = repo and repo.host:find("github")
                local cmd, parse

                if is_gh then
                    local fields = table.concat({
                        "databaseId", "displayTitle", "conclusion", "status",
                        "headBranch", "headSha", "startedAt", "updatedAt",
                        "url", "workflowName", "number"
                    }, ",")
                    cmd = { "gh", "run", "list", "--json", fields, "-L", "50", "-R",
                        string.format("%s/%s/%s", repo.host, repo.owner, repo.repo) }
                    parse = function(stdout)
                        local ok, arr = pcall(vim.json.decode, stdout); if not ok then return {} end
                        local out = {}
                        for _, r in ipairs(arr or {}) do
                            local icon = (r.conclusion == "success" and "✓")
                                or ((r.conclusion == "failure" or r.conclusion == "startup_failure") and "X")
                                or (r.conclusion == "cancelled" and "⊘")
                                or (r.status == "in_progress" and "●")
                                or "○"
                            table.insert(out, {
                                value = r,
                                url = r.url,
                                ordinal = string.format("%s %s [%s] #%s", icon, r.workflowName or "workflow",
                                    r.headBranch or "-", r.number or ""),
                                display = string.format("%s  %-18s  %-12s  %s", icon, r.workflowName or "workflow",
                                    r.headBranch or "-", r.displayTitle or r.headSha or ""),
                            })
                        end
                        return out
                    end
                else
                    cmd = { "glab", "ci", "list", "--output", "json", "--per-page", "50" }
                    parse = function(stdout)
                        local ok, arr = pcall(vim.json.decode, stdout); if not ok then return {} end
                        local out = {}
                        for _, p in ipairs(arr or {}) do
                            local icon = (p.status == "success" and "✓")
                                or (p.status == "failed" and "X")
                                or (p.status == "canceled" and "⊘")
                                or (p.status == "running" and "●")
                                or "○"
                            table.insert(out, {
                                value = p,
                                url = p.web_url,
                                ordinal = string.format("%s Pipeline #%s [%s]", icon, p.id or "?", p.ref or "-"),
                                display = string.format("%s  %-18s  %-12s  %s", icon, "pipeline", p.ref or "-",
                                    "Pipeline #" .. (p.id or "?")),
                            })
                        end
                        return out
                    end
                end

                Job:new({
                    command = cmd[1],
                    args = vim.list_slice(cmd, 2),
                    on_exit = function(j, code)
                        vim.schedule(function()
                            if code ~= 0 then
                                vim.notify(table.concat(j:stderr_result(), "\n"), vim.log.levels.WARN); return
                            end
                            local entries = parse(table.concat(j:result(), "\n"))
                            pickers.new(themed_opts("Pipeline: Runs"), {
                                finder = finders.new_table({ results = entries }),
                                sorter = conf.generic_sorter({}),
                                attach_mappings = function(bufnr, _)
                                    actions.select_default:replace(function()
                                        local e = state.get_selected_entry(); actions.close(bufnr)
                                        if e and e.url then open_url(e.url) end
                                    end)
                                    for _, m in ipairs({ "i", "n" }) do
                                        vim.keymap.set(m, "<C-y>", function()
                                            local e = state.get_selected_entry()
                                            if e and e.url then
                                                vim.fn.setreg("+", e.url); vim.notify("Copied URL")
                                            end
                                        end, { buffer = bufnr })
                                    end
                                    return true
                                end,
                            }):find()
                        end)
                    end,
                }):start()
            end

            -- Workflows (GitHub) / Pipelines (GitLab) dispatcher
            function M.workflows()
                local repo = detect_repo()
                local is_gh = repo and repo.host:find("github")
                if is_gh then
                    local cmd = {
                        "gh", "workflow", "list", "--json", "id,name,path,state,url", "-L", "200", "-R",
                        string.format("%s/%s/%s", repo.host, repo.owner, repo.repo)
                    }
                    Job:new({
                        command = cmd[1],
                        args = vim.list_slice(cmd, 2),
                        on_exit = function(j, code)
                            vim.schedule(function()
                                if code ~= 0 then
                                    vim.notify(table.concat(j:stderr_result(), "\n"), vim.log.levels.WARN); return
                                end
                                local ok, arr = pcall(vim.json.decode, table.concat(j:result(), "\n"))
                                if not ok then
                                    vim.notify("Failed to decode gh workflow list", vim.log.levels.ERROR); return
                                end
                                local entries = {}
                                for _, w in ipairs(arr or {}) do
                                    table.insert(entries, {
                                        value = w,
                                        url = w.url,
                                        ordinal = (w.name or w.path or ("#" .. tostring(w.id))),
                                        display = string.format("%-32s  %-8s  %s",
                                            w.name or w.path or ("#" .. tostring(w.id)), w.state or "-", w.path or ""),
                                    })
                                end
                                pickers.new(themed_opts("Pipeline: Dispatch"), {
                                    finder = finders.new_table({ results = entries }),
                                    sorter = conf.generic_sorter({}),
                                    attach_mappings = function(bufnr, _)
                                        actions.select_default:replace(function()
                                            local e = state.get_selected_entry(); actions.close(bufnr)
                                            if not e then return end
                                            local ref = vim.fn.input("Ref (empty = default): ")
                                            local args = { "gh", "workflow", "run", tostring(e.value.id) }
                                            if ref ~= "" then vim.list_extend(args, { "--ref", ref }) end
                                            vim.fn.jobstart(args, { detach = true })
                                            vim.notify("Dispatched workflow: " .. (e.value.name or e.value.path))
                                        end)
                                        for _, m in ipairs({ "i", "n" }) do
                                            vim.keymap.set(m, "<C-b>", function()
                                                local e = state.get_selected_entry(); if e and e.url then open_url(e.url) end
                                            end, { buffer = bufnr })
                                        end
                                        return true
                                    end,
                                }):find()
                            end)
                        end,
                    }):start()
                else
                    local branch = vim.fn.input("GitLab branch to run pipeline on: ")
                    if branch == "" then return end
                    vim.fn.jobstart({ "glab", "ci", "run", "-b", branch }, { detach = true })
                    vim.notify("Triggered GitLab pipeline on " .. branch)
                end
            end

            package.loaded["pipeline.telescope"] = M
        end,
    },
}
