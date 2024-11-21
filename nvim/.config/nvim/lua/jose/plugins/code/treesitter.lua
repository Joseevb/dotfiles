return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"python",
			"query",
			"regex",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"c",
			"query",
			"sql",
			"yaml",
		},
		highlight = {
			enable = true, -- Ensure syntax highlighting is enabled
			additional_vim_regex_highlighting = true, -- Disable fallback regex highlighting
		},
		indent = {
			enable = true, -- Ensure indenting works with treesitter
		},
		autotag = {
			enable = true, -- Enable auto-tagging for inline HTML in JS/TSX
		},
	},

	config = function()
		vim.api.nvim_create_autocmd("BufReadPost", {
			group = vim.api.nvim_create_augroup("TSHighlight", { clear = true }),
			pattern = "*",
			command = "TSBufEnable highlight",
		})
	end,
}
