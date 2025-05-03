return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		animate = { enabled = false },
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true, replace_netrw = true },
		indent = { enabled = true },
		input = { enabled = true },
		picker = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		dim = { enabled = true },
		gitbrowse = { enabled = true },
		terminal = { enabled = true },
		toggle = { enabled = true },
		lazygit = { enabled = true },
	},
	keys = {
		{
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			desc = "Open Explorer",
		},
		{
			"<leader>bd",
			function()
				Snacks.bufdelete()
			end,
			desc = "Deletes current buffer",
		},
		{
			"<leader>lg",
			function()
				Snacks.lazygit.open()
			end,
			desc = "Opens lazygit",
		},
	},
}
