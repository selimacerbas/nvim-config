return {
    {
        "matarina/pyrola.nvim",
        build = ":UpdateRemotePlugins",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "folke/which-key.nvim",
        },
        opts = {
            kernel_map    = { python = "python3" }, -- change default if you like
            split_horizen = false,                  -- vertical (right) by default
            split_ratio   = 0.30,                   -- default vertical width = 30%
        },
        config = function(_, opts)
            local pyrola = require("pyrola")
            pyrola.setup(vim.deepcopy and vim.deepcopy(opts) or opts)

            -- light TS ensure
            pcall(function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "python" },
                    auto_install = true,
                })
            end)

            ---------------------------------------------------------------------
            -- Resilience: revive Pyrola once if REPL window was closed
            ---------------------------------------------------------------------
            local function revive_pyrola()
                package.loaded["pyrola"] = nil
                pyrola = require("pyrola")
                pyrola.setup(opts)
            end

            local function safe_send_stmt()
                local ok, err = pcall(function() require("pyrola").send_statement_definition() end)
                if ok then return end
                if tostring(err):match("Invalid window id") then
                    revive_pyrola()
                    pcall(function() require("pyrola").send_statement_definition() end)
                else
                    vim.notify("Pyrola error: " .. tostring(err), vim.log.levels.ERROR)
                end
            end

            ---------------------------------------------------------------------
            -- Vertical sizing + keep REPL width fixed
            ---------------------------------------------------------------------
            local state = { last_vertical_ratio = opts.split_ratio or 0.30 }

            local function is_term(buf)
                return vim.api.nvim_get_option_value("buftype", { buf = buf }) == "terminal"
            end

            local function find_repl_win()
                for _, w in ipairs(vim.api.nvim_list_wins()) do
                    local b = vim.api.nvim_win_get_buf(w)
                    if is_term(b) then
                        local name = vim.api.nvim_buf_get_name(b)
                        if name:match("jupyter") or name:match("pyrola") or name:match("console") then
                            return w
                        end
                    end
                end
            end

            local function go_win(w)
                if w and vim.api.nvim_win_is_valid(w) then
                    vim.api.nvim_set_current_win(w)
                    return true
                end
                vim.notify("REPL not found. Use <leader>jl to open it.", vim.log.levels.WARN)
                return false
            end

            local function lock_width(win)
                pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = win })
            end

            local function use_vertical(ratio)
                local w = find_repl_win()
                if not go_win(w) then return end
                lock_width(w)
                vim.cmd("wincmd L") -- ensure right side
                vim.cmd("vertical resize " .. math.floor(vim.o.columns * ratio))
                lock_width(w)
            end

            local function set_vertical_30()
                state.last_vertical_ratio = 0.30; use_vertical(0.30)
            end
            local function set_vertical_40()
                state.last_vertical_ratio = 0.40; use_vertical(0.40)
            end
            local function set_vertical_50()
                state.last_vertical_ratio = 0.50; use_vertical(0.50)
            end

            -- re-apply width when other windows close or screen resizes
            vim.api.nvim_create_autocmd({ "WinClosed", "VimResized" }, {
                callback = function()
                    local w = find_repl_win()
                    if w and vim.api.nvim_win_is_valid(w) then
                        lock_width(w)
                        vim.schedule(function()
                            use_vertical(state.last_vertical_ratio)
                        end)
                    end
                end,
            })

            -- close REPL & reset so next send reopens cleanly
            local function close_repl_reset()
                local w = find_repl_win()
                if w and vim.api.nvim_win_is_valid(w) then vim.api.nvim_win_close(w, true) end
                revive_pyrola()
                vim.notify("REPL closed. Next send will reopen it.", vim.log.levels.INFO)
            end

            ---------------------------------------------------------------------
            -- Kernel picker (bind to current &filetype)
            ---------------------------------------------------------------------
            local function pick_kernel_for_ft()
                local ft = vim.bo.filetype
                local function apply(choice)
                    if not choice then return end
                    opts.kernel_map = opts.kernel_map or {}
                    opts.kernel_map[ft] = choice
                    revive_pyrola()
                    vim.notify(("Kernel for %s → %s"):format(ft, choice))
                    close_repl_reset()
                end
                local function handle(out, err, code)
                    if code ~= 0 or not out or out == "" then
                        vim.notify("kernelspec list failed: " .. (err or "unknown"), vim.log.levels.ERROR); return
                    end
                    local okj, data = pcall(vim.json.decode, out)
                    if not okj or not data or not data.kernelspecs then
                        vim.notify("Could not parse kernelspec JSON", vim.log.levels.ERROR); return
                    end
                    local names = {}
                    for name, _ in pairs(data.kernelspecs) do table.insert(names, name) end
                    table.sort(names)
                    if #names == 0 then
                        vim.notify("No kernels found", vim.log.levels.WARN); return
                    end
                    vim.ui.select(names, { prompt = ("Select kernel for %s"):format(ft) }, apply)
                end
                if vim.system then
                    vim.system({ "jupyter", "kernelspec", "list", "--json" }, { text = true }, function(res)
                        vim.schedule(function() handle(res.stdout or "", res.stderr or "", res.code or 0) end)
                    end)
                else
                    local out = vim.fn.system("jupyter kernelspec list --json")
                    handle(out, "", vim.v.shell_error)
                end
            end

            ---------------------------------------------------------------------
            -- VISUAL send on <leader>jv (official API) + tiny selection safeguard
            ---------------------------------------------------------------------
            local function send_visual_selection()
                local ok, err = pcall(function() require("pyrola").send_visual_to_repl() end)
                if ok then return end
                if tostring(err):match("Invalid window id") then
                    revive_pyrola()
                    pcall(function() require("pyrola").send_visual_to_repl() end)
                else
                    vim.notify("Pyrola error: " .. tostring(err), vim.log.levels.ERROR)
                end
            end

            -- -- Prevent Space from shrinking the selection when starting a <leader> combo (VISUAL only)
            -- vim.keymap.set("x", "<Space>", "<Nop>", { silent = true })
            --
            -- Hard-map visual send so it works even before which-key loads
            vim.keymap.set("x", "<leader>jv", send_visual_selection,
                { silent = true, noremap = true, desc = "Send visual selection" })
            --
            ---------------------------------------------------------------------
            -- which-key groups
            ---------------------------------------------------------------------
            local wk_ok, wk = pcall(require, "which-key")
            if wk_ok then
                local add = wk.add or wk.register

                -- Normal: under <leader>j
                add({ { "<leader>j", group = "REPL (Pyrola)" } }, { mode = "n" })
                add({
                    { "<leader>jl", safe_send_stmt, desc = "Send statement/block" },
                    { "<leader>ji", function() require("pyrola").inspect() end, desc = "Inspect under cursor" },
                    { "<leader>jk", pick_kernel_for_ft, desc = "Select kernel…" },
                    { "<leader>jq", close_repl_reset, desc = "Close REPL (reset)" },
                    { "<leader>j0", set_vertical_30, desc = "Vertical width 30%" },
                    { "<leader>j1", set_vertical_40, desc = "Vertical width 40%" },
                    { "<leader>j2", set_vertical_50, desc = "Vertical width 50%" },
                }, { mode = "n", silent = true, noremap = true })

                -- Visual: show under <leader>j
                add({ { "<leader>j", group = "REPL (Pyrola)" } }, { mode = "x" })
                add({
                    { "<leader>jv", send_visual_selection, desc = "Send visual selection" },
                }, { mode = "x", silent = true, noremap = true })
            end
        end,
    },
}
