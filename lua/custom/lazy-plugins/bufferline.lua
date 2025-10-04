return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"folke/which-key.nvim",
		},

		-- Register the top-level group early so which-key shows it before the plugin loads
		init = function()
			local ok, wk = pcall(require, "which-key")
			if ok and wk.add then
				wk.add({ { "<leader>e", group = "Tabs" } })
			end
		end,

		opts = {
			options = {
				mode = "tabs", -- show Neovim *tabpages* instead of buffers
				numbers = "none",
				diagnostics = "nvim_lsp", -- show LSP counts on tabs
				separator_style = "slant",
				show_buffer_close_icons = true,
				show_close_icon = false,
				always_show_bufferline = false, -- hide when only one tab
				offsets = {
					{ filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true },
					{ filetype = "NvimTree", text = "Explorer", highlight = "Directory", separator = true },
					{ filetype = "undotree", text = "Undo Tree", highlight = "Directory", separator = true },
				},
				hover = { enabled = true, delay = 200, reveal = { "close" } },
			},
		},

		-- v3 which-key friendly keymaps
		keys = {
			{
				"<leader>en",
				"<cmd>BufferLineCycleNext<CR>",
				desc = "Tabs: Next",
				mode = "n",
				silent = true,
				noremap = true,
			},
			{
				"<leader>ep",
				"<cmd>BufferLineCyclePrev<CR>",
				desc = "Tabs: Prev",
				mode = "n",
				silent = true,
				noremap = true,
			},
			{
				"<leader>ek",
				"<cmd>BufferLinePick<CR>",
				desc = "Tabs: Pick",
				mode = "n",
				silent = true,
				noremap = true,
			},
			{
				"<leader>eK",
				"<cmd>BufferLinePickClose<CR>",
				desc = "Tabs: Pick to Close",
				mode = "n",
				silent = true,
				noremap = true,
			},
			{
				"<leader>eo",
				"<cmd>BufferLineCloseOthers<CR>",
				desc = "Tabs: Close Others",
				mode = "n",
				silent = true,
				noremap = true,
			},
			{
				"<leader>el",
				"<cmd>BufferLineCloseLeft<CR>",
				desc = "Tabs: Close Left",
				mode = "n",
				silent = true,
				noremap = true,
			},
			{
				"<leader>er",
				"<cmd>BufferLineCloseRight<CR>",
				desc = "Tabs: Close Right",
				mode = "n",
				silent = true,
				noremap = true,
			},
			{
				"<leader>em",
				"<cmd>BufferLineMoveNext<CR>",
				desc = "Tabs: Move Next",
				mode = "n",
				silent = true,
				noremap = true,
			},
			{
				"<leader>eM",
				"<cmd>BufferLineMovePrev<CR>",
				desc = "Tabs: Move Prev",
				mode = "n",
				silent = true,
				noremap = true,
			},
		},

		config = function(_, opts)
			require("bufferline").setup(opts)
			-- no extra which-key calls needed; group was registered in init, and key descs come from keys{}
		end,
	},
}
