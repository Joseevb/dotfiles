return {
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		lazy = true,
		setup_name = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"c",
				"cpp",
				"lua",
				"python",
				"rust",
				"tsx",
				"typescript",
				"javascript",
				"css",
				"html",
				"json",
				"yaml",
				"markdown",
				"xml",
				"java",
			},
			sync_install = true,
			auto_install = true,
			ignore_install = {
				"ipkg",
			},
			modules = {},
			highlight = {
				enable = true,
			},
		},
	},
	{ src = "https://github.com/windwp/nvim-ts-autotag", setup_name = "nvim-ts-autotag", lazy = true },
}
