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
						desc = " Files",
						group = "Label",
						action = "FzfLua files",
						key = "f",
					},
					{
						desc = "󰒓 Config",
						group = "DiagnosticHint",
						action = "FzfLua files cwd=" .. CONFIG_PATH,
						key = "c",
					},
					{
						desc = " Dotfiles",
						group = "Number",
						action = "FzfProjects dotfiles",
						key = "d",
					},
				},
			},
		},
	},
}
