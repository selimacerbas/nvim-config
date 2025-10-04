return {
	{
		"michaelb/sniprun",
		build = "sh install.sh",
		cmd = { "SnipRun", "SnipInfo", "SnipReset", "SnipClose", "SnipLive", "SnipReplMemoryClean" },
		keys = function()
			local function run_buffer()
				local view = vim.fn.winsaveview()
				vim.cmd(":%SnipRun")
				vim.fn.winrestview(view)
			end
			return {
				-- which-key group root
				{ "<leader>r", group = "Run/REPL (SnipRun)" },

				-- Run
				{
					"<leader>rr",
					"<Plug>SnipRun",
					mode = { "n", "x" },
					desc = "Run line/selection",
					remap = true,
					silent = true,
				},
				{
					"<leader>ro",
					"<Plug>SnipRunOperator",
					mode = "n",
					desc = "Run with motion (operator)",
					remap = true,
					silent = true,
				},
				{ "<leader>rR", run_buffer, mode = "n", desc = "Run entire file (%)" },

				-- Info / control
				{ "<leader>ri", "<cmd>SnipInfo<cr>", mode = "n", desc = "SnipInfo (current ft)" },
				{ "<leader>rs", "<cmd>SnipReset<cr>", mode = "n", desc = "Stop/Reset runners" },
				{ "<leader>rc", "<cmd>SnipClose<cr>", mode = "n", desc = "Close SnipRun windows" },

				-- Live mode toggle (available because we enable it below)
				{ "<leader>rl", "<cmd>SnipLive<cr>", mode = "n", desc = "Toggle Live mode" },
				-- (Optional cleanup)
				{ "<leader>rm", "<cmd>SnipReplMemoryClean<cr>", mode = "n", desc = "Clean REPL memory" },
			}
		end,
		opts = function()
			return {
				-- Stable, readable outputs
				display = { "Classic", "VirtualTextOk", "Terminal"},
				display_options = {
					terminal_position = "vertical",
					terminal_width = 60,
					terminal_height = 18,
				},
				ansi_escape = true,
				inline_messages = false,

				-- Live mode can be toggled on demand
				live_mode_toggle = "enable",
				live_display = { "VirtualText" },

				-- ✅ Your choice: FIFO Python REPL (no klepto)
		  selected_interpreters = { "Python3_fifo" },
		  repl_enable = { "Python3_fifo", "Lua_nvim", "JS_TS_Deno" },

		  -- Optional: lock SnipRun to your venv for Python FIFO
		  -- interpreter_options = { Python3_fifo = { venv = { ".venv" } } },
	  }
  end,
  config = function(_, opts)
	  require("sniprun").setup(opts)

	  -- which-key labels
	  local ok, wk = pcall(require, "which-key")
	  if ok then
		  wk.add({
			  { "<leader>r",  group = "Run/REPL (SnipRun)" },
			  { "<leader>rr", desc = "Run line/selection" },
			  { "<leader>ro", desc = "Run with motion (operator)" },
			  { "<leader>rR", desc = "Run entire file (%)" },
			  { "<leader>ri", desc = "SnipInfo (current ft)" },
			  { "<leader>rs", desc = "Stop/Reset runners" },
			  { "<leader>rc", desc = "Close SnipRun windows" },
			  { "<leader>rl", desc = "Toggle Live mode" },
			  { "<leader>rm", desc = "Clean REPL memory" },
		  })
	  end
  end,  },
}
