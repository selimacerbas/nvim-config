return {
  "barrett-ruth/live-server.nvim",
  cmd = { "LiveServerStart", "LiveServerStop" },
  -- build = "pnpm add -g live-server",
  opts = {},

  -- which-key v3: register the group early
  init = function()
    local ok, wk = pcall(require, "which-key")
    if ok and wk.add then
      wk.add({ { "<leader>L", group = "Live Server" } })
    end
  end,

  -- v3-friendly keymaps (simple commands; plugin will lazy-load before they run)
  keys = {
    { "<leader>Ls", "<cmd>LiveServerStartCwd<CR>",           desc = "Live Server: Start (cwd)",          mode = "n", silent = true, noremap = true },
    { "<leader>LD", "<cmd>LiveServerStartHere<CR>",          desc = "Live Server: Start (file dir)",     mode = "n", silent = true, noremap = true },
    { "<leader>LP", "<cmd>LiveServerStartPortPrompt<CR>",    desc = "Live Server: Start on port…",       mode = "n", silent = true, noremap = true },
    { "<leader>Lt", "<cmd>LiveServerStartPortTelescope<CR>", desc = "Live Server: Start on port (Telescope)", mode = "n", silent = true, noremap = true },
    { "<leader>Lo", "<cmd>LiveServerOpenRoot<CR>",           desc = "Live Server: Open root",            mode = "n", silent = true, noremap = true },
    { "<leader>Lf", "<cmd>LiveServerOpenFile<CR>",           desc = "Live Server: Open current file",    mode = "n", silent = true, noremap = true },
    { "<leader>Lr", "<cmd>LiveServerRestart<CR>",            desc = "Live Server: Restart",              mode = "n", silent = true, noremap = true },
    { "<leader>Lx", "<cmd>LiveServerStop<CR>",               desc = "Live Server: Stop",                 mode = "n", silent = true, noremap = true },
  },

  config = function(_, opts)
    -- plugin doesn't strictly need setup, but call it if you want to pass opts
    pcall(function() require("live-server").setup(opts) end)

    -- ── state ──────────────────────────────────────────────────────────────────
    vim.g.live_server_port    = vim.g.live_server_port or 5555

    -- ── helpers ────────────────────────────────────────────────────────────────
    local function current_port()
      return tonumber(vim.g.live_server_port) or 5555
    end

    local function open_browser(url)
      local has = vim.fn.has
      if has("mac") == 1 then
        vim.fn.jobstart({ "open", url }, { detach = true })
      elseif has("win32") == 1 then
        vim.fn.jobstart({ "cmd.exe", "/c", "start", url }, { detach = true })
      else
        vim.fn.jobstart({ "xdg-open", url }, { detach = true })
      end
    end

    local function open_root()
      open_browser(("http://localhost:%d/"):format(current_port()))
    end

    local function open_current_file()
      local file = vim.fn.expand("%:p")
      if file == "" then return end
      local rel = vim.fn.fnamemodify(file, ":."):gsub("^%./", "")
      open_browser(("http://localhost:%d/%s"):format(current_port(), rel))
    end

    local function do_start()
      vim.cmd("LiveServerStart")
    end

    local function do_stop()
      vim.cmd("LiveServerStop")
    end

    local function restart()
      do_stop()
      vim.defer_fn(do_start, 100)
    end

    local function start_in_file_dir()
      local dir = vim.fn.expand("%:p:h")
      if dir ~= "" then
        vim.cmd("lcd " .. vim.fn.fnameescape(dir))
      end
      do_start()
    end

    local function start_on_port_prompt()
      vim.ui.input({ prompt = "Port to use:", default = tostring(current_port()) }, function(input)
        local port = tonumber(input or "")
        if not port then return end
        local prev = vim.env.PORT
        vim.g.live_server_port = port
        vim.env.PORT = tostring(port) -- live-server respects PORT/--port
        do_start()
        vim.defer_fn(function() vim.env.PORT = prev end, 200)
      end)
    end

    local function start_on_port_picker()
      local ok, pickers = pcall(require, "telescope.pickers")
      if not ok then return start_on_port_prompt() end -- fallback to prompt

      local finders      = require("telescope.finders")
      local conf         = require("telescope.config").values
      local actions      = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local candidates = {
        { 3000, "React/Next default" },
        { 5173, "Vite default" },
        { 5555, "live-server.nvim default" },
        { 5500, "VSCode Live Server default" },
        { 8000, "Python http.server" },
        { 8080, "Common dev port" },
        { 4200, "Angular CLI" },
        { 4321, "Alt dev port" },
      }

      pickers.new({}, {
        prompt_title = "Live Server: pick a port",
        finder = finders.new_table({
          results = candidates,
          entry_maker = function(e)
            local port, label = e[1], e[2]
            return {
              value = port,
              display = string.format("%-6d %s", port, label),
              ordinal = tostring(port) .. " " .. label,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(bufnr, _)
          actions.select_default:replace(function()
            actions.close(bufnr)
            local port = action_state.get_selected_entry().value
            local prev = vim.env.PORT
            vim.g.live_server_port = tonumber(port)
            vim.env.PORT = tostring(port)
            do_start()
            vim.defer_fn(function() vim.env.PORT = prev end, 200)
          end)
          return true
        end,
      }):find()
    end

    -- ── user commands used by the keymaps ──────────────────────────────────────
    vim.api.nvim_create_user_command("LiveServerStartCwd", do_start, {})
    vim.api.nvim_create_user_command("LiveServerStartHere", start_in_file_dir, {})
    vim.api.nvim_create_user_command("LiveServerStartPortPrompt", start_on_port_prompt, {})
    vim.api.nvim_create_user_command("LiveServerStartPortTelescope", start_on_port_picker, {})
    vim.api.nvim_create_user_command("LiveServerOpenRoot", open_root, {})
    vim.api.nvim_create_user_command("LiveServerOpenFile", open_current_file, {})
    vim.api.nvim_create_user_command("LiveServerRestart", restart, {})
    -- LiveServerStop already provided by the plugin
  end,
}
