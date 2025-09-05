return {
    {
        "matarina/pyrola.nvim",
        build = ":UpdateRemotePlugins",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "folke/which-key.nvim",
        },
        opts = {
            kernel_map    = { python = "python3" },
            split_horizen = false, -- vertical (right)
            split_ratio   = 0.30, -- 30% width
        },
        config = function(_, opts)
            local pyrola = require("pyrola")
            pyrola.setup(vim.deepcopy and vim.deepcopy(opts) or opts)

            -- Treesitter (light ensure)
            pcall(function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "python" },
                    auto_install = true,
                })
            end)

            ---------------------------------------------------------------------
            -- Focus helpers (stay in your code window)
            ---------------------------------------------------------------------
            local function restore_focus(prev_win, prev_view)
                if vim.api.nvim_win_is_valid(prev_win) then
                    pcall(vim.api.nvim_set_current_win, prev_win)
                    pcall(vim.fn.winrestview, prev_view)
                    pcall(vim.cmd, "stopinsert")
                end
            end

            local function with_cursor_stay(fn)
                return function(...)
                    local prev_win  = vim.api.nvim_get_current_win()
                    local prev_view = vim.fn.winsaveview()
                    local ok, err   = pcall(fn, ...)
                    -- small retry to beat async focus steals
                    for _, ms in ipairs({ 10, 60, 150 }) do
                        vim.defer_fn(function() restore_focus(prev_win, prev_view) end, ms)
                    end
                    if not ok then vim.notify("Pyrola error: " .. tostring(err), vim.log.levels.ERROR) end
                end
            end

            ---------------------------------------------------------------------
            -- State + REPL detection
            ---------------------------------------------------------------------
            local state = {
                ratio      = opts.split_ratio or 0.30,
                minimized  = false,
                min_width  = 10, -- << safe minimal width to avoid screen clearing
                repl_buf   = nil, -- tracked terminal buffer
                repl_win   = nil, -- last known REPL window id
                last_width = nil,
            }

            local function is_term(buf)
                return vim.api.nvim_get_option_value("buftype", { buf = buf }) == "terminal"
            end

            local function looks_like_repl(buf)
                local name = vim.api.nvim_buf_get_name(buf)
                return is_term(buf) and (
                    name:match("jupyter") or name:match("ipython") or name:match("python")
                    or name:match("pyrola") or name:match("console") or name:match("term://")
                )
            end

            local function find_repl_win()
                for _, w in ipairs(vim.api.nvim_list_wins()) do
                    local b = vim.api.nvim_win_get_buf(w)
                    if looks_like_repl(b) then return w end
                end
            end

            local function park_right_and_size(win, width)
                if not win or not vim.api.nvim_win_is_valid(win) then return end
                local prev = vim.api.nvim_get_current_win()
                vim.api.nvim_set_current_win(win)
                vim.cmd("wincmd L")
                local w = width or math.max(20, math.floor(vim.o.columns * state.ratio))
                pcall(vim.api.nvim_win_set_width, win, w)
                pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = win })
                if prev ~= win then vim.api.nvim_set_current_win(prev) end
            end

            local function track_repl(win)
                if not win or not vim.api.nvim_win_is_valid(win) then return end
                local buf = vim.api.nvim_win_get_buf(win)
                if looks_like_repl(buf) then
                    state.repl_buf = buf
                    state.repl_win = win
                    -- keep lots of history and keep buffer when window closes
                    pcall(vim.api.nvim_set_option_value, "scrollback", 100000, { buf = buf })
                    pcall(vim.api.nvim_set_option_value, "bufhidden", "hide", { buf = buf })
                end
            end

            -- Park & remember whenever a REPL-like terminal opens
            vim.api.nvim_create_autocmd("TermOpen", {
                callback = function(args)
                    if looks_like_repl(args.buf) then
                        local w = vim.fn.bufwinid(args.buf)
                        if w ~= -1 then
                            track_repl(w)
                            park_right_and_size(w)
                        end
                    end
                end,
            })

            -- Keep width on resize/close. If minimized, keep it at min_width.
            vim.api.nvim_create_autocmd({ "VimResized", "WinClosed" }, {
                callback = function()
                    vim.schedule(function()
                        local w = state.repl_win and vim.api.nvim_win_is_valid(state.repl_win) and state.repl_win or
                        find_repl_win()
                        if not w then return end
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

            ---------------------------------------------------------------------
            -- Toggle: minimize/restore (no hide/close, so window id stays valid)
            ---------------------------------------------------------------------
            local function toggle_minimize_repl()
                local w = state.repl_win and vim.api.nvim_win_is_valid(state.repl_win) and state.repl_win or
                find_repl_win()
                if not w then
                    if state.repl_buf and vim.api.nvim_buf_is_valid(state.repl_buf) then
                        vim.cmd("vsplit")
                        vim.cmd("wincmd L")
                        w = vim.api.nvim_get_current_win()
                        pcall(vim.api.nvim_set_current_buf, state.repl_buf)
                        track_repl(w)
                    else
                        vim.notify("No REPL yet. Send once with <leader>jl.", vim.log.levels.WARN)
                        return
                    end
                end

                local prev = vim.api.nvim_get_current_win()
                local prev_view = vim.fn.winsaveview()
                track_repl(w)

                if not state.minimized then
                    local curw = vim.api.nvim_win_get_width(w)
                    state.last_width = (curw and curw > state.min_width) and curw or
                    math.max(20, math.floor(vim.o.columns * state.ratio))
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

            ---------------------------------------------------------------------
            -- Core actions (no closing/hiding anywhere)
            ---------------------------------------------------------------------
            local function safe_send_stmt()
                local ok, err = pcall(function()
                    local w = state.repl_win and vim.api.nvim_win_is_valid(state.repl_win) and state.repl_win or
                    find_repl_win()
                    if w then
                        track_repl(w)
                        if not state.minimized then park_right_and_size(w) end
                    end
                    require("pyrola").send_statement_definition()
                    w = find_repl_win() or w
                    if w then track_repl(w) end
                end)
                if not ok then
                    if tostring(err):match("Invalid window id") then
                        package.loaded["pyrola"] = nil
                        pyrola = require("pyrola")
                        pyrola.setup(opts)
                        pcall(function() require("pyrola").send_statement_definition() end)
                    else
                        vim.notify("Pyrola error: " .. tostring(err), vim.log.levels.ERROR)
                    end
                end
            end

            local function safe_send_visual()
                local ok, err = pcall(function()
                    local w = state.repl_win and vim.api.nvim_win_is_valid(state.repl_win) and state.repl_win or
                    find_repl_win()
                    if w then
                        track_repl(w)
                        if not state.minimized then park_right_and_size(w) end
                    end
                    require("pyrola").send_visual_to_repl()
                    w = find_repl_win() or w
                    if w then track_repl(w) end
                end)
                if not ok then
                    if tostring(err):match("Invalid window id") then
                        package.loaded["pyrola"] = nil
                        pyrola = require("pyrola")
                        pyrola.setup(opts)
                        pcall(function() require("pyrola").send_visual_to_repl() end)
                    else
                        vim.notify("Pyrola error: " .. tostring(err), vim.log.levels.ERROR)
                    end
                end
            end

            ---------------------------------------------------------------------
            -- Kernel picker (unchanged)
            ---------------------------------------------------------------------
            local function pick_kernel_for_ft()
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
            end

            ---------------------------------------------------------------------
            -- which-key v3 + fallback
            ---------------------------------------------------------------------
            local wk_ok, wk = pcall(require, "which-key")
            if wk_ok and wk.add then
                wk.add({
                    { "<leader>j", group = "REPL (Pyrola)" },
                    { "<leader>jl", with_cursor_stay(safe_send_stmt), desc = "Send statement/block (stay)", mode = "n" },
                    { "<leader>jv", with_cursor_stay(safe_send_visual), desc = "Send visual selection (stay)", mode = "x" },
                    { "<leader>ji", with_cursor_stay(function() require("pyrola").inspect() end), desc = "Inspect under cursor (stay)", mode = "n" },
                    { "<leader>jk", pick_kernel_for_ft, desc = "Select kernel…", mode = "n" },
                    { "<leader>jt", toggle_minimize_repl, desc = "Toggle REPL (min/restore)", mode = "n" },
                    {
                        "<leader>jq",
                        function()
                            local w = state.repl_win and vim.api.nvim_win_is_valid(state.repl_win) and state.repl_win or
                            find_repl_win()
                            if w then vim.api.nvim_win_close(w, true) end
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
                    end,                                                                                                                                   desc = "Vertical width 30%", mode = "n" },
                    { "<leader>j1", function()
                        state.minimized = false; state.ratio = 0.40; local w = find_repl_win(); if w then
                            park_right_and_size(w) end
                    end,                                                                                                                                   desc = "Vertical width 40%", mode = "n" },
                    { "<leader>j2", function()
                        state.minimized = false; state.ratio = 0.50; local w = find_repl_win(); if w then
                            park_right_and_size(w) end
                    end,                                                                                                                                   desc = "Vertical width 50%", mode = "n" },
                })
            else
                -- Fallback if which-key v3 isn't ready
                vim.keymap.set("n", "<leader>jl", with_cursor_stay(safe_send_stmt),
                    { silent = true, noremap = true, desc = "Send statement/block (stay)" })
                vim.keymap.set("x", "<leader>jv", with_cursor_stay(safe_send_visual),
                    { silent = true, noremap = true, desc = "Send visual selection (stay)" })
                vim.keymap.set("n", "<leader>ji", with_cursor_stay(function() require("pyrola").inspect() end),
                    { silent = true, noremap = true, desc = "Inspect under cursor (stay)" })
                vim.keymap.set("n", "<leader>jk", pick_kernel_for_ft,
                    { silent = true, noremap = true, desc = "Select kernel…" })
                vim.keymap.set("n", "<leader>jt", toggle_minimize_repl,
                    { silent = true, noremap = true, desc = "Toggle REPL (min/restore)" })
                vim.keymap.set("n", "<leader>jq", function()
                    local w = state.repl_win and vim.api.nvim_win_is_valid(state.repl_win) and state.repl_win or
                    find_repl_win()
                    if w then vim.api.nvim_win_close(w, true) end
                    package.loaded["pyrola"] = nil
                    pyrola = require("pyrola")
                    pyrola.setup(opts)
                    vim.notify("REPL closed. Next send will reopen it.", vim.log.levels.INFO)
                end, { silent = true, noremap = true, desc = "Close REPL (reset)" })
            end

            -- Don’t auto-equalize split sizes
            vim.o.equalalways = false
        end,
    },
}
