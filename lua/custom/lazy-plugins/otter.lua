-- lua/custom/lazy-plugins/markdown-otter.lua
return {
	{
		"jmbuhr/otter.nvim",
		ft = { "markdown", "rmd", "quarto", "qmd" },
		dependencies = {
			"folke/which-key.nvim",
			"nvim-treesitter/nvim-treesitter",
			{ "AckslD/nvim-FeMaco.lua", cmd = "FeMaco" }, -- optional popup editor
		},
		opts = {
			lsp = {
				diagnostic_update_events = { "BufWritePost", "InsertLeave" },
				root_dir = function(_, bufnr)
					return vim.fs.root(bufnr or 0, { ".git", "pyproject.toml", "package.json", "_quarto.yml" })
						or vim.loop.cwd()
				end,
			},
			buffers = { set_filetype = true, write_to_disk = false },
			handle_leading_whitespace = true,
		},
		config = function(_, opts)
			local otter = require("otter")
			otter.setup(opts)

			-- Auto-activate in Markdown-like buffers
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown", "rmd", "quarto", "qmd" },
				callback = function(ev)
					otter.activate(nil, true, true) -- enable completion + diagnostics for fenced langs

					-- which-key (buffer-local, no conflicts)
					local ok, wk = pcall(require, "which-key")
					if ok then
						wk.add({
							{ "<leader>mo", group = "Otter", buffer = ev.buf },
							{
								"<leader>moA",
								function()
									otter.activate(nil, true, true)
								end,
								desc = "Activate LSP in code blocks",
								buffer = ev.buf,
							},
							{
								"<leader>moE",
								"<cmd>FeMaco<CR>",
								desc = "Edit fenced block in popup (LSP)",
								buffer = ev.buf,
							},
							{
								"<leader>mox",
								function()
									require("otter").export()
								end,
								desc = "Export code blocks (overwrite)",
								buffer = ev.buf,
							},
							{
								"<leader>moX",
								function()
									require("otter").export_otter_as()
								end,
								desc = "Export blocks as…",
								buffer = ev.buf,
							},
						})
					end
				end,
			})
		end,
	},
}
