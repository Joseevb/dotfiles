return {
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "simeji/winresizer", keys = { { "<leader>R", ":WinResizerStartResize<CR>", desc = "Enter resize mode" } } },
	{
		"dmtrKovalenko/fold-imports.nvim",
		opts = {},
		event = "BufEnter",
	},
	{
		"folke/ts-comments.nvim",
		event = "BufEnter",
		opts = {},
	},
	{ "tpope/vim-repeat", event = "VeryLazy" },
}
