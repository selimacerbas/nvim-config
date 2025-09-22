return {
	"barrett-ruth/live-server.nvim",
	-- Will lazy-load on these user commands
	cmd = { "LiveServerStart", "LiveServerStop" },

	-- Try to ensure the CLI exists; fall back to a helpful warning
	build = function()
		if vim.fn.executable("live-server") == 0 then
			local pkgmgr = vim.fn.executable("pnpm") == 1 and "pnpm" or (vim.fn.executable("npm") == 1 and "npm" or nil)

			if pkgmgr then
				local args = pkgmgr == "pnpm" and { "add", "-g", "live-server" } or { "i", "-g", "live-server" }
				vim.notify("Installing live-server globally via " .. pkgmgr .. " …")
				vim.fn.jobstart(vim.list_extend({ pkgmgr }, args), { detach = true })
			else
				vim.notify(
					"Please install Node.js, then install live-server globally: `npm i -g live-server`",
					vim.log.levels.WARN
				)
			end
		end
	end,

	opts = {}, -- uses plugin defaults

	-- Keymaps registered with which-key, without stepping on common leader groups
	keys = function()
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

		local function restart()
			vim.cmd("LiveServerStop")
			vim.defer_fn(function()
				vim.cmd("LiveServerStart")
			end, 100)
		end

		-- Register pretty names in which-key if present
		local ok, wk = pcall(require, "which-key")
		if ok then
			wk.add({
				{ "<leader>L", group = "Live Server" },
				{ "<leader>Ls", "<cmd>LiveServerStart<cr>", desc = "Start server (cwd)" },
				{ "<leader>Lx", "<cmd>LiveServerStop<cr>", desc = "Stop server" },
				{ "<leader>Lr", restart, desc = "Restart server" },
				{
					"<leader>Lo",
					function()
						open_browser("http://localhost:5555")
					end,
					desc = "Open in browser",
				},
			})
		end

		-- Also return keys so Lazy can lazy-load on press
		return {
			{
				"<leader>Ls",
				"<cmd>LiveServerStart<cr>",
				desc = "Live Server: Start",
				silent = true,
			},
			{
				"<leader>Lx",
				"<cmd>LiveServerStop<cr>",
				desc = "Live Server: Stop",
				silent = true,
			},
			{
				"<leader>Lr",
				restart,
				desc = "Live Server: Restart",
				silent = true,
			},
			{
				"<leader>Lo",
				function()
					open_browser("http://localhost:5555")
				end,
				desc = "Live Server: Open",
				silent = true,
			},
		}
	end,
}
