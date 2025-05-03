return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	-- dependencies = { "nvim-tree/nvim-web-devicons" },
	-- or if using mini.icons/mini.nvim
	dependencies = { "echasnovski/mini.icons" },
	opts = {
		"hide",
		"fzf-tmux",
		fzf_tmux_opts = { ["-p"] = "80%,80%", ["--margin"] = "0,0" },
	},
	keys = {
		{
			"<leader>ff",
			function()
				FzfLua.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fw",
			function()
				FzfLua.grep()
			end,
			desc = "Find Word",
		},
		{
			"<leader>fr",
			function()
				FzfLua.resume()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fb",
			function()
				FzfLua.buffers()
			end,
			desc = "Find Buffers",
		},
		{
			"<leader>fg",
			function()
				FzfLua.git_files()
			end,
			desc = "Find Git Files",
		},
	},
}
