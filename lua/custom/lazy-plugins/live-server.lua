return {
	"barrett-ruth/live-server.nvim",
	cmd = { "LiveServerStart", "LiveServerStop" },
	-- keep your build helper if you want auto-install of the CLI
	-- build = 'pnpm add -g live-server',
	opts = {},

	keys = function()
		-- ── state ──────────────────────────────────────────────────────────────────
		-- Remember the chosen port, and whether we started it via our wrappers.
		vim.g.live_server_port = vim.g.live_server_port or 5555
		vim.g.live_server_running = vim.g.live_server_running or false

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
			if file == "" then
				return
			end
			local rel = vim.fn.fnamemodify(file, ":."):gsub("^%./", "")
			open_browser(("http://localhost:%d/%s"):format(current_port(), rel))
		end

		local function mark_running(is_running)
			vim.g.live_server_running = is_running
		end

		local function do_start()
			vim.cmd("LiveServerStart")
			mark_running(true)
		end

		local function do_stop()
			vim.cmd("LiveServerStop")
			mark_running(false)
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

		-- Ask for a port via input() and start
		local function start_on_port_prompt()
			vim.ui.input({ prompt = "Port to use:", default = tostring(current_port()) }, function(input)
				local port = tonumber(input or "")
				if not port then
					return
				end
				local prev = vim.env.PORT
				vim.g.live_server_port = port
				vim.env.PORT = tostring(port) -- live-server respects PORT/--port
				do_start()
				vim.defer_fn(function()
					vim.env.PORT = prev
				end, 200) -- restore env
			end)
		end

		-- Telescope picker of common ports
		local function start_on_port_picker()
			local ok, pickers = pcall(require, "telescope.pickers")
			if not ok then
				return start_on_port_prompt()
			end -- fallback

			local finders = require("telescope.finders")
			local conf = require("telescope.config").values
			local actions = require("telescope.actions")
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

			pickers
				.new({}, {
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
							vim.defer_fn(function()
								vim.env.PORT = prev
							end, 200)
						end)
						return true
					end,
				})
				:find()
		end

		-- which-key labels (no-op if not installed)
		local ok, wk = pcall(require, "which-key")
		if ok then
			wk.add({
				{ "<leader>L", group = "Live Server" },
				{ "<leader>Ls", do_start, desc = "Start (cwd)" },
				{ "<leader>LD", start_in_file_dir, desc = "Start (this file’s dir)" },
				{ "<leader>LP", start_on_port_prompt, desc = "Start on port…" },
				{ "<leader>Lt", start_on_port_picker, desc = "Start on port (Telescope)" },
				{ "<leader>Lo", open_root, desc = "Open root" },
				{ "<leader>Lf", open_current_file, desc = "Open current file" },
				{ "<leader>Lr", restart, desc = "Restart" },
				{ "<leader>Lx", do_stop, desc = "Stop" },
			})
		end

		-- actual mappings so Lazy can lazy-load on keypress
		return {
			{ "<leader>Ls", do_start, desc = "Live Server: Start (cwd)", silent = true },
			{ "<leader>LD", start_in_file_dir, desc = "Live Server: Start (file dir)", silent = true },
			{ "<leader>LP", start_on_port_prompt, desc = "Live Server: Start on port…", silent = true },
			{ "<leader>Lt", start_on_port_picker, desc = "Live Server: Start on port (Telescope)", silent = true },
			{ "<leader>Lo", open_root, desc = "Live Server: Open root", silent = true },
			{ "<leader>Lf", open_current_file, desc = "Live Server: Open current file", silent = true },
			{ "<leader>Lr", restart, desc = "Live Server: Restart", silent = true },
			{ "<leader>Lx", do_stop, desc = "Live Server: Stop", silent = true },
		}
	end,
}
