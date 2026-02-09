-- lua/custom/ui-sizing.lua
local M = {}

-- ----- CONFIG -----
M.config = {
  -- When true, new windows with the same filetype will inherit the last ratio you set for that filetype.
  -- Default OFF to prevent surprise reflows.
  enable_ft_fallback = false,

  -- Filetypes that are "sidebar-ish" where fallback (if enabled) is usually safe.
  fallback_allowlist = {
    NvimTree = true,
    ["neo-tree"] = true,
    Outline = true,
    qf = true,
    help = true,
    aerial = true,
    Trouble = true,
    toggleterm = true,
    terminal = true,
  },

  -- Keep this minimal; these are much less spammy than WinEnter/WinResized.
  reapply_events = { "VimResized", "BufWinEnter" },
}

-- Per session memory (optional filetype fallback)
M.state = {
  ft_w = {}, -- e.g. ["NvimTree"] = 0.25
  ft_h = {}, -- e.g. ["toggleterm"] = 0.35
}

-- Internal guard against recursive re-apply
M._applying = false
M._enabled = true

-- ----- HELPERS -----
local function is_float(win)
  local cfg = vim.api.nvim_win_get_config(win)
  return cfg and cfg.relative ~= "" and cfg.relative ~= nil
end

local function is_resizable(win)
  if not vim.api.nvim_win_is_valid(win) then return false end
  if is_float(win) then return false end
  -- Skip cmdwin
  if vim.fn.bufwinnr(":") == win then return false end
  return true
end

local function total_ui_height()
  local ui = vim.api.nvim_list_uis()
  return (ui and ui[1] and ui[1].height) or vim.o.lines
end

local function with_guard(fn)
  if M._applying or not M._enabled then return end
  M._applying = true
  local ok, err = pcall(fn)
  M._applying = false
  if not ok then
    pcall(vim.notify, "ui-sizing error: " .. tostring(err), vim.log.levels.WARN)
  end
end

local function desired_from_context(kind) -- "w" or "h"
  -- Only reapply if it was explicitly set on the window or buffer.
  local wv = (kind == "w") and vim.w.ui_sizing_wratio or vim.w.ui_sizing_hratio
  local bv = (kind == "w") and vim.b.ui_sizing_wratio or vim.b.ui_sizing_hratio
  if wv then return wv end
  if bv then return bv end

  -- Optional per-filetype fallback, and only for allowlisted fts
  if M.config.enable_ft_fallback and M.config.fallback_allowlist[vim.bo.filetype or ""] then
    if kind == "w" then return M.state.ft_w[vim.bo.filetype or ""] end
    if kind == "h" then return M.state.ft_h[vim.bo.filetype or ""] end
  end
  return nil
end

-- ----- APPLY -----
local function apply_current_width(ratio, do_notify)
  local win = vim.api.nvim_get_current_win()
  if not is_resizable(win) then return end

  local cols  = vim.o.columns
  local width = math.max(20, math.floor(cols * ratio))

  with_guard(function()
    -- Use API, avoids some autocmd churn vs commands
    if vim.api.nvim_win_set_width then
      vim.api.nvim_win_set_width(win, width)
    else
      vim.api.nvim_win_call(win, function()
        vim.cmd("vertical resize " .. width)
      end)
    end
  end)

  vim.w.ui_sizing_wratio = ratio
  vim.b.ui_sizing_wratio = ratio
  if M.config.enable_ft_fallback and M.config.fallback_allowlist[vim.bo.filetype or ""] then
    M.state.ft_w[vim.bo.filetype or ""] = ratio
  end

  if do_notify then pcall(vim.notify, ("UI Sizing (W) → %d%%"):format(math.floor(ratio * 100))) end
end

local function apply_current_height(ratio, do_notify)
  local win = vim.api.nvim_get_current_win()
  if not is_resizable(win) then return end

  local total = total_ui_height()
  local height = math.max(5, math.floor(total * ratio) - 2)

  with_guard(function()
    if vim.api.nvim_win_set_height then
      vim.api.nvim_win_set_height(win, height)
    else
      vim.api.nvim_win_call(win, function()
        vim.cmd("resize " .. height)
      end)
    end
  end)

  vim.w.ui_sizing_hratio = ratio
  vim.b.ui_sizing_hratio = ratio
  if M.config.enable_ft_fallback and M.config.fallback_allowlist[vim.bo.filetype or ""] then
    M.state.ft_h[vim.bo.filetype or ""] = ratio
  end

  if do_notify then pcall(vim.notify, ("UI Sizing (H) → %d%%"):format(math.floor(ratio * 100))) end
end

function M.set_width_ratio(ratio)  apply_current_width(ratio, true) end
function M.set_height_ratio(ratio) apply_current_height(ratio, true) end

-- ----- REAPPLY -----
local function reapply_for_current()
  if not M._enabled then return end
  local wr = desired_from_context("w")
  local hr = desired_from_context("h")
  -- Only reapply what was explicitly set; don't force both unless both were set.
  if wr then apply_current_width(wr, false) end
  if hr then apply_current_height(hr, false) end
end

-- ----- PUBLIC: CLEAR / TOGGLE -----
function M.clear_for_current()
  -- make this window flexible again
  vim.w.ui_sizing_wratio = nil
  vim.w.ui_sizing_hratio = nil
  vim.b.ui_sizing_wratio = nil
  vim.b.ui_sizing_hratio = nil
  pcall(vim.cmd, "setlocal nowinfixwidth nowinfixheight")
  pcall(vim.notify, "UI Sizing: cleared for this window/buffer")
end

function M.reset_all()
  M.state.ft_w, M.state.ft_h = {}, {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    pcall(vim.api.nvim_set_option_value, "winfixwidth", false, { win = win })
    pcall(vim.api.nvim_set_option_value, "winfixheight", false, { win = win })
    vim.api.nvim_win_call(win, function()
      vim.w.ui_sizing_wratio = nil
      vim.w.ui_sizing_hratio = nil
      if vim.api.nvim_win_is_valid(win) then end
    end)
  end
  -- buffer locals
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_call(buf, function()
        vim.b.ui_sizing_wratio = nil
        vim.b.ui_sizing_hratio = nil
      end)
    end
  end
  pcall(vim.notify, "UI Sizing: reset all")
end

function M.enable()  M._enabled = true  end
function M.disable() M._enabled = false end
function M.toggle()  M._enabled = not M._enabled end

-- ----- AUTOCMDS & COMMANDS -----
function M.setup_autocmds()
  local grp = vim.api.nvim_create_augroup("UI_Sizing_Autos", { clear = true })
  vim.api.nvim_create_autocmd(M.config.reapply_events, {
    group = grp,
    callback = reapply_for_current,
  })
end

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

  vim.api.nvim_create_user_command("UISizeClear", function() M.clear_for_current() end, {
    desc = "Clear any stored UI sizing for the current window/buffer",
  })

  vim.api.nvim_create_user_command("UISizeResetAll", function() M.reset_all() end, {
    desc = "Clear all UI sizing state for the entire session",
  })

  vim.api.nvim_create_user_command("UISizeOff", function() M.disable(); pcall(vim.notify, "UI Sizing: OFF") end, {})
  vim.api.nvim_create_user_command("UISizeOn",  function() M.enable();  pcall(vim.notify, "UI Sizing: ON")  end, {})
  vim.api.nvim_create_user_command("UISizeToggle", function() M.toggle(); pcall(vim.notify, "UI Sizing: toggled") end, {})
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  M.setup_autocmds()
  M.setup_user_commands()
end

return M
