-- lua/ui_sizing.lu
-- lua/custom/ui-sizing.lua
local M = {}

-- Per-session memory (fallbacks by filetype)
M.state = {
    ft_w = {}, -- e.g. ["python"] = 0.25
    ft_h = {}, -- e.g. ["terminal"] = 0.35
}

local function is_float(win)
    local cfg = vim.api.nvim_win_get_config(win)
    return cfg and cfg.relative ~= "" and cfg.relative ~= nil
end

-- ===== WIDTH =====
local function apply_current_width(ratio, do_notify)
    local win = vim.api.nvim_get_current_win()
    if not vim.api.nvim_win_is_valid(win) or is_float(win) then return end

    local cols  = vim.o.columns
    local width = math.max(20, math.floor(cols * ratio))

    vim.api.nvim_win_call(win, function()
        vim.cmd("vertical resize " .. width)
    end)

    vim.w.ui_sizing_wratio = ratio
    vim.b.ui_sizing_wratio = ratio
    M.state.ft_w[vim.bo.filetype or ""] = ratio

    if do_notify then pcall(vim.notify, ("UI Sizing (W) → %d%%"):format(math.floor(ratio * 100))) end
end

function M.set_width_ratio(ratio) apply_current_width(ratio, true) end

-- ===== HEIGHT =====
local function total_ui_height()
    -- Prefer UI grid height when available; fall back to 'lines'
    local ui = vim.api.nvim_list_uis()
    return (ui and ui[1] and ui[1].height) or vim.o.lines
end

local function apply_current_height(ratio, do_notify)
    local win = vim.api.nvim_get_current_win()
    if not vim.api.nvim_win_is_valid(win) or is_float(win) then return end

    local total = total_ui_height()
    -- Leave headroom for status/tab/cmdline rows
    local height = math.max(5, math.floor(total * ratio) - 2)

    vim.api.nvim_win_call(win, function()
        vim.cmd("resize " .. height)
    end)

    vim.w.ui_sizing_hratio = ratio
    vim.b.ui_sizing_hratio = ratio
    M.state.ft_h[vim.bo.filetype or ""] = ratio

    if do_notify then pcall(vim.notify, ("UI Sizing (H) → %d%%"):format(math.floor(ratio * 100))) end
end

function M.set_height_ratio(ratio) apply_current_height(ratio, true) end

-- ===== REAPPLY ON CHANGES =====
local function reapply_for_current()
    local wr = vim.w.ui_sizing_wratio or vim.b.ui_sizing_wratio or M.state.ft_w[vim.bo.filetype or ""]
    local hr = vim.w.ui_sizing_hratio or vim.b.ui_sizing_hratio or M.state.ft_h[vim.bo.filetype or ""]
    if wr then apply_current_width(wr, false) end
    if hr then apply_current_height(hr, false) end
end

function M.setup_autocmds()
    local grp = vim.api.nvim_create_augroup("UI_Sizing_Autos", { clear = true })
    vim.api.nvim_create_autocmd(
        { "VimResized", "WinEnter", "BufWinEnter", "TabEnter", "WinResized" },
        { group = grp, callback = reapply_for_current }
    )
end

-- ===== USER COMMANDS =====
function M.setup_user_commands()
    vim.api.nvim_create_user_command("UISize", function(opts)
        local pct = tonumber(opts.args); if not pct then return end
        local ratio = math.max(1, math.min(100, pct)) / 100
        M.set_width_ratio(ratio)
    end, {
        nargs = 1,
        complete = function() return { "15", "25", "35", "45" } end,
        desc = "Resize focused window WIDTH to given percentage",
    })

    vim.api.nvim_create_user_command("UISizeH", function(opts)
        local pct = tonumber(opts.args); if not pct then return end
        local ratio = math.max(1, math.min(100, pct)) / 100
        M.set_height_ratio(ratio)
    end, {
        nargs = 1,
        complete = function() return { "15", "25", "35", "45" } end,
        desc = "Resize focused window HEIGHT to given percentage",
    })
end

function M.setup()
    M.setup_autocmds()
    M.setup_user_commands()
end

return M
