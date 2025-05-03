local builtin = require("telescope.builtin")

return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {},
	keys = {
		{ "<leader>ff", builtin.find_files, desc = "Find Files" },
		{ "<leader>fb", builtin.buffers, desc = "Find Buffers" },
		{ "<leader>fh", builtin.help_tags, desc = "Find Help" },
		{ "<C-g>", builtin.git_files, desc = "Find Git Files" },
		{ "<leader>fw", builtin.live_grep, desc = "Find Word" },
		{ "<leader>fW", builtin.grep_string, desc = "Find CWord" },
		{ "<leader>fg", builtin.live_grep, desc = "Find Grep" },
	},
}
