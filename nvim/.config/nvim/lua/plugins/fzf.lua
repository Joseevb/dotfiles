return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-mini/mini.icons" },
		opts = { "hide" },
		keys = {
			{ "<leader>ss", "<cmd>FzfLua<CR>", desc = "Open FzfLua" },
			{ "<leader>sw", "<cmd>FzfLua grep_cword<CR>", desc = "Search word" },
			{ "<leader>sW", "<cmd>FzfLua grep_cWORD<CR>", desc = "Search WORD under cursor" },
			{ "<leader>sf", "<cmd>FzfLua files<CR>", desc = "Search files" },
			{ "<leader>sb", "<cmd>FzfLua buffers<CR>", desc = "Search buffers" },
			{ "<leader>sz", "<cmd>FzfLua zoxide<CR>", desc = "Search zoxide" },
			{
				"<leader>sp",
				":ProjectFzf<CR>",
				desc = "Projects",
			},
		},
	},
	{
		"jakobwesthoff/project-fzf.nvim",
		dependencies = {
			"ahmedkhalf/project.nvim",
			"ibhagwan/fzf-lua",
		},
		opts = {},
	},
}
