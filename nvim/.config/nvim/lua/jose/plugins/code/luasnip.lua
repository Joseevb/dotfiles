return {
	"L3MON4D3/LuaSnip",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"mlaursen/vim-react-snippets",
	},
	build = "make install_jsregexp",
	opts = {},
	config = function(_, opts)
		require("luasnip").setup(opts)

		require("vim-react-snippets").lazy_load()
		require("luasnip.loaders.from_vscode").lazy_load()
	end,
}
