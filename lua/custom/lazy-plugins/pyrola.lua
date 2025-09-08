return {
    {
        "matarina/pyrola.nvim",
        build = ":UpdateRemotePlugins",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "folke/which-key.nvim",
        },
        opts = {
            kernel_map    = { python = "python3" }, -- sane default
            split_horizen = false,
            split_ratio   = 0.30,
        },
        config = function(_, opts)
            -- --- env checks / doctor ------------------------------------------------
            local function has_pynvim() return pcall(vim.fn.py3eval, "1") end
            local function have_jupyter() return vim.fn.executable("jupyter") == 1 end
            local function warn(msg) vim.notify(msg, vim.log.levels.WARN, { title = "Pyrola" }) end
            local function err(msg) vim.notify(msg, vim.log.levels.ERROR, { title = "Pyrola" }) end

            vim.api.nvim_create_user_command("PyrolaDoctor", function()
                local lines = {
                    "pynvim host: " .. (has_pynvim() and "OK" or "MISSING (pip install --user pynvim)"),
                    "jupyter cli: " .. (have_jupyter() and "OK" or "MISSING (pip install --user jupyter)"),
                    "rplugin.vim: " ..
                    (vim.loop.fs_stat(vim.fn.stdpath("data") .. "/rplugin.vim") and "present" or "missing"),
                    ("kernel_map.python: %s"):format((opts.kernel_map or {}).python or "nil"),
                }
                vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Pyrola Doctor" })
            end, {})

            if not has_pynvim() then
                err("Python host not available. Run: pip install --user pynvim, then :UpdateRemotePlugins and restart.")
            end
            if not have_jupyter() then
                warn("Jupyter not on PATH. Kernel picker may fail. Install jupyter for kernelspec listing.")
            end
            opts.kernel_map = opts.kernel_map or {}
            if opts.kernel_map.python ~= "python3" then
                warn(("Overriding kernel_map.python (%s) → python3"):format(tostring(opts.kernel_map.python)))
                opts.kernel_map.python = "python3"
            end

            -- --- plugin setup -------------------------------------------------------
            local pyrola = require("pyrola")
            pyrola.setup(vim.deepcopy and vim.deepcopy(opts) or opts)

            pcall(function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "python" },
                    auto_install = true,
                })
            end)

            -- --- focus helpers ------------------------------------------------------
            local function restore_focus(prev_win, prev_view)
                if vim.api.nvim_win_is_valid(prev_win) then
                    pcall(vim.api.nvim_set_current_win, prev_win)
                    pcall(vim.fn.winrestview, prev_view)
                    pcall(vim.cmd, "stopinsert")
                end
            end
            local function with_cursor_stay(fn)
                return function(...)
                    local prev_win, prev_view = vim.api.nvim_get_current_win(), vim.fn.winsaveview()
                    local ok, e = pcall(fn, ...)
                    for _, ms in ipairs({ 10, 60, 150 }) do
                        vim.defer_fn(function() restore_focus(prev_win, prev_view) end, ms)
                    end
                    if not ok then vim.notify("Pyrola error: " .. tostring(e), vim.log.levels.ERROR) end
                end
            end

            -- --- state --------------------------------------------------------------
            local state = {
                ratio            = opts.split_ratio or 0.30,
                minimized        = false,
                min_width        = 10,
                repl_buf         = nil,
                repl_win         = nil,
                last_width       = nil,
                expect_repl_open = false, -- adopt TermOpen within window
            }

            -- --- window helpers (hardened) -----------------------------------------
            local function is_floating(win)
                if not win or not vim.api.nvim_win_is_valid(win) then return false end
                local cfg = vim.api.nvim_win_get_config(win)
                return cfg and cfg.relative ~= "" and cfg.relative ~= "editor"
            end
            local function valid_split(win)
                return win and vim.api.nvim_win_is_valid(win) and not is_floating(win)
            end
            local function with_win(win, fn)
                if not valid_split(win) then return false end
                if vim.api.nvim_win_call then
                    local ok, e = pcall(vim.api.nvim_win_call, win, function() fn(win) end)
                    return ok, e
                else
                    local prev = vim.api.nvim_get_current_win()
                    local ok1 = pcall(vim.api.nvim_set_current_win, win)
                    if not ok1 then return false end
                    local ok2, e = pcall(fn, win)
                    pcall(vim.api.nvim_set_current_win, prev)
                    return ok2, e
                end
            end

            -- --- buffer detection / scope ------------------------------------------
            local function is_term(buf)
                return vim.api.nvim_get_option_value("buftype", { buf = buf }) == "terminal"
            end
            local function is_pyrola_buf(buf)
                return is_term(buf) and (vim.b[buf].pyrola_repl == true)
            end
            local function looks_like_python_repl_buf(buf)
                if not is_term(buf) then return false end
                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                if ft == "toggleterm" then return false end
                local name = vim.api.nvim_buf_get_name(buf)
                return name:match("ipython") or name:match("jupyter") or name:match("python") or name:match("pyrola")
            end

            local function manage_this_win(win)
                if not valid_split(win) then return false end
                local buf = vim.api.nvim_win_get_buf(win)
                return is_pyrola_buf(buf)
            end

            local function find_repl_win()
                for _, w in ipairs(vim.api.nvim_list_wins()) do
                    if manage_this_win(w) then return w end
                end
            end

            local function track_repl(win)
                if not manage_this_win(win) then return end
                local buf = vim.api.nvim_win_get_buf(win)
                state.repl_buf, state.repl_win = buf, win
                pcall(vim.api.nvim_set_option_value, "scrollback", 100000, { buf = buf })
                pcall(vim.api.nvim_set_option_value, "bufhidden", "hide", { buf = buf })
            end

            local function park_right_and_size(win, width)
                if not valid_split(win) then
                    if state.repl_win == win then state.repl_win = nil end
                    return
                end
                local target = width or math.max(20, math.floor(vim.o.columns * state.ratio))
                with_win(win, function()
                    vim.cmd("wincmd L")
                    pcall(vim.api.nvim_win_set_width, win, target)
                    pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = win })
                end)
            end

            local function adopt_first_python_repl_if_any()
                for _, w in ipairs(vim.api.nvim_list_wins()) do
                    if valid_split(w) then
                        local b = vim.api.nvim_win_get_buf(w)
                        if looks_like_python_repl_buf(b) then
                            vim.b[b].pyrola_repl = true
                            state.repl_buf, state.repl_win = b, w
                            return true
                        end
                    end
                end
                return false
            end

            local function will_open_repl_soon()
                state.expect_repl_open = true
                vim.defer_fn(function() state.expect_repl_open = false end, 3000) -- generous window
            end

            -- --- user commands: adopt/release --------------------------------------
            vim.api.nvim_create_user_command("PyrolaAdopt", function()
                local win = vim.api.nvim_get_current_win()
                local buf = vim.api.nvim_win_get_buf(win)
                if is_term(buf) and valid_split(win) then
                    vim.b[buf].pyrola_repl = true
                    track_repl(win)
                    park_right_and_size(win)
                    vim.notify("Pyrola adopted this terminal.", vim.log.levels.INFO)
                else
                    vim.notify("Not a terminal split window.", vim.log.levels.WARN)
                end
            end, {})
            vim.api.nvim_create_user_command("PyrolaRelease", function()
                if state.repl_buf and vim.api.nvim_buf_is_valid(state.repl_buf) then
                    vim.b[state.repl_buf].pyrola_repl = false
                end
                state.repl_buf, state.repl_win = nil, nil
                vim.notify("Pyrola released the managed terminal.", vim.log.levels.INFO)
            end, {})

            -- --- autocmds (hardened & float-safe) ----------------------------------
            vim.api.nvim_create_autocmd("TermOpen", {
                callback = function(args)
                    if not state.expect_repl_open then return end
                    local win = vim.fn.bufwinid(args.buf)
                    if win == -1 or not valid_split(win) then return end
                    local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
                    if ft == "toggleterm" then return end -- never adopt ToggleTerm
                    vim.b[args.buf].pyrola_repl = true
                    track_repl(win)
                    park_right_and_size(win)
                end,
            })

            vim.api.nvim_create_autocmd({ "VimResized", "WinClosed" }, {
                callback = function()
                    vim.schedule(function()
                        local w = (state.repl_win and valid_split(state.repl_win)) and state.repl_win or find_repl_win()
                        if not valid_split(w) then
                            state.repl_win = nil; return
                        end
                        track_repl(w)
                        if state.minimized then
                            pcall(vim.api.nvim_win_set_width, w, state.min_width)
                            pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = w })
                        else
                            park_right_and_size(w)
                        end
                    end)
                end,
            })

            -- --- toggle minimize/restore -------------------------------------------
            local function toggle_minimize_repl()
                local w = (state.repl_win and valid_split(state.repl_win)) and state.repl_win or find_repl_win()
                if not w then
                    if state.repl_buf and vim.api.nvim_buf_is_valid(state.repl_buf) then
                        vim.cmd("vsplit")
                        vim.cmd("wincmd L")
                        w = vim.api.nvim_get_current_win()
                        pcall(vim.api.nvim_set_current_buf, state.repl_buf)
                        if valid_split(w) then
                            vim.b[state.repl_buf].pyrola_repl = true
                            track_repl(w)
                        end
                    else
                        vim.notify("No REPL yet. Send once with <leader>jl.", vim.log.levels.WARN)
                        return
                    end
                end
                if not valid_split(w) then return end

                local prev, prev_view = vim.api.nvim_get_current_win(), vim.fn.winsaveview()
                track_repl(w)
                if not state.minimized then
                    local curw = vim.api.nvim_win_get_width(w)
                    state.last_width = (curw and curw > state.min_width) and curw
                        or math.max(20, math.floor(vim.o.columns * state.ratio))
                    state.minimized = true
                    pcall(vim.api.nvim_win_set_width, w, state.min_width)
                    pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = w })
                else
                    state.minimized = false
                    local restore = state.last_width or math.max(20, math.floor(vim.o.columns * state.ratio))
                    park_right_and_size(w, restore)
                end
                restore_focus(prev, prev_view)
            end

            -- --- send actions (robust adoption + no race) --------------------------
            local function post_send_adopt_and_park()
                vim.defer_fn(function()
                    local w = find_repl_win()
                    if not w then
                        if adopt_first_python_repl_if_any() then
                            w = find_repl_win()
                        end
                    end
                    if w then
                        track_repl(w)
                        if not state.minimized then park_right_and_size(w) end
                    end
                end, 120)
            end

            local function safe_send_stmt()
                local ok, e = pcall(function()
                    state.expect_repl_open = true
                    vim.defer_fn(function() state.expect_repl_open = false end, 3000)
                    require("pyrola").send_statement_definition()
                    post_send_adopt_and_park()
                end)
                if not ok then vim.notify("Pyrola error: " .. tostring(e), vim.log.levels.ERROR) end
            end

            local function safe_send_visual()
                local ok, e = pcall(function()
                    state.expect_repl_open = true
                    vim.defer_fn(function() state.expect_repl_open = false end, 3000)
                    require("pyrola").send_visual_to_repl()
                    post_send_adopt_and_park()
                end)
                if not ok then vim.notify("Pyrola error: " .. tostring(e), vim.log.levels.ERROR) end
            end

            -- --- which-key / keymaps -----------------------------------------------
            local wk_ok, wk = pcall(require, "which-key")
            if wk_ok and wk.add then
                wk.add({
                    { "<leader>j",  group = "REPL (Pyrola)" },
                    { "<leader>jl", with_cursor_stay(safe_send_stmt),                             desc = "Send statement/block (stay)",  mode = "n" },
                    { "<leader>jv", with_cursor_stay(safe_send_visual),                           desc = "Send visual selection (stay)", mode = "x" },
                    { "<leader>ji", with_cursor_stay(function() require("pyrola").inspect() end), desc = "Inspect under cursor (stay)",  mode = "n" },
                    {
                        "<leader>jk",
                        function()
                            -- kernel picker (unchanged logic)
                            local ft = vim.bo.filetype
                            local function apply_choice(choice)
                                if not choice then return end
                                opts.kernel_map = opts.kernel_map or {}
                                opts.kernel_map[ft] = choice
                                package.loaded["pyrola"] = nil
                                pyrola = require("pyrola")
                                pyrola.setup(opts)
                                vim.notify(("Kernel for %s → %s"):format(ft, choice))
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
                                vim.ui.select(names, { prompt = ("Select kernel for %s"):format(ft) }, apply_choice)
                            end
                            if vim.system then
                                vim.system({ "jupyter", "kernelspec", "list", "--json" }, { text = true }, function(res)
                                    vim.schedule(function() handle(res.stdout or "", res.stderr or "", res.code or 0) end)
                                end)
                            else
                                local out = vim.fn.system("jupyter kernelspec list --json")
                                handle(out, "", vim.v.shell_error)
                            end
                        end,
                        desc = "Select kernel…",
                        mode = "n"
                    },
                    { "<leader>jt", toggle_minimize_repl,                                                                                                  desc = "Toggle REPL (min/restore)", mode = "n" },
                    {
                        "<leader>jq",
                        function()
                            local w = (state.repl_win and valid_split(state.repl_win)) and state.repl_win or
                            find_repl_win()
                            if w then vim.api.nvim_win_close(w, true) end
                            if state.repl_buf and vim.api.nvim_buf_is_valid(state.repl_buf) then
                                vim.b[state.repl_buf].pyrola_repl = false
                            end
                            state.repl_buf, state.repl_win = nil, nil
                            package.loaded["pyrola"] = nil
                            pyrola = require("pyrola")
                            pyrola.setup(opts)
                            vim.notify("REPL closed. Next send will reopen it.", vim.log.levels.INFO)
                        end,
                        desc = "Close REPL (reset)",
                        mode = "n"
                    },
                    { "<leader>j0", function()
                        state.minimized = false; state.ratio = 0.30; local w = find_repl_win(); if w then
                            park_right_and_size(w) end
                    end,                                                                                                                                   desc = "Vertical width 30%",        mode = "n" },
                    { "<leader>j1", function()
                        state.minimized = false; state.ratio = 0.40; local w = find_repl_win(); if w then
                            park_right_and_size(w) end
                    end,                                                                                                                                   desc = "Vertical width 40%",        mode = "n" },
                    { "<leader>j2", function()
                        state.minimized = false; state.ratio = 0.50; local w = find_repl_win(); if w then
                            park_right_and_size(w) end
                    end,                                                                                                                                   desc = "Vertical width 50%",        mode = "n" },
                })
            else
                vim.keymap.set("n", "<leader>jl", with_cursor_stay(safe_send_stmt),
                    { silent = true, noremap = true, desc = "Send statement/block (stay)" })
                vim.keymap.set("x", "<leader>jv", with_cursor_stay(safe_send_visual),
                    { silent = true, noremap = true, desc = "Send visual selection (stay)" })
                vim.keymap.set("n", "<leader>ji", with_cursor_stay(function() require("pyrola").inspect() end),
                    { silent = true, noremap = true, desc = "Inspect under cursor (stay)" })
                vim.keymap.set("n", "<leader>jk",
                    function() vim.notify("Use :PyrolaDoctor to ensure jupyter is installed, then reopen.",
                            vim.log.levels.INFO) end, { silent = true, noremap = true, desc = "Select kernel…" })
                vim.keymap.set("n", "<leader>jt", toggle_minimize_repl,
                    { silent = true, noremap = true, desc = "Toggle REPL (min/restore)" })
                vim.keymap.set("n", "<leader>jq", function()
                    local w = (state.repl_win and valid_split(state.repl_win)) and state.repl_win or find_repl_win()
                    if w then vim.api.nvim_win_close(w, true) end
                    if state.repl_buf and vim.api.nvim_buf_is_valid(state.repl_buf) then
                        vim.b[state.repl_buf].pyrola_repl = false
                    end
                    state.repl_buf, state.repl_win = nil, nil
                    package.loaded["pyrola"] = nil
                    pyrola = require("pyrola")
                    pyrola.setup(opts)
                    vim.notify("REPL closed. Next send will reopen it.", vim.log.levels.INFO)
                end, { silent = true, noremap = true, desc = "Close REPL (reset)" })
            end
        end,
    },
}
