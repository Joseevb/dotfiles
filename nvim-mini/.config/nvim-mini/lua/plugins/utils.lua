return {
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{
		src = "https://github.com/nvimdev/dashboard-nvim",
		setup_name = "dashboard",
		opts = {
			theme = "hyper",
			config = {
				week_header = {
					enable = true,
				},
				shortcut = {
					{ desc = "󰊳 Update", group = "@property", action = "PackUpdate", key = "u" },
					{
						icon = " ",
						icon_hl = "@variable",
						desc = "Files",
						group = "Label",
						action = "FzfLua files",
						key = "f",
					},
					{
						desc = " Apps",
						group = "DiagnosticHint",
						action = "Telescope app",
						key = "a",
					},
					{
						desc = " dotfiles",
						group = "Number",
						action = "FzfLua dotfiles",
						key = "d",
					},
				},
			},
		},
	},
}
