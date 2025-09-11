return {
	{ src = "https://github.com/nvim-mini/mini.icons", setup_name = "mini.icons" },
	{ src = "https://github.com/nvim-mini/mini.completion", setup_name = "mini.completion" },
	{
		src = "https://github.com/nvim-mini/mini.snippets",
		setup_name = "mini.snippets",
		lazy = true,
		opts = function()
			local gen_loader = require("mini.snippets").gen_loader
			return {
				snippets = {
					gen_loader.from_lang(),
				},
			}
		end,
	},
	{ src = "https://github.com/nvim-mini/mini.tabline", setup_name = "mini.tabline" },
	{ src = "https://github.com/nvim-mini/mini-git", setup_name = "mini.git" },
	{ src = "https://github.com/nvim-mini/mini.diff", setup_name = "mini.diff" },
	{ src = "https://github.com/nvim-mini/mini.statusline", setup_name = "mini.statusline" },
}
