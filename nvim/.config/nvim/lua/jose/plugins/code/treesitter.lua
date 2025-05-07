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
			"css",
			"desktop",
			"all",
		},
		sync_install = false,
		auto_install = true,
		highlight = {
			enable = true, -- Ensure syntax highlighting is enabled
			additional_vim_regex_highlighting = true, -- Disable fallback regex highlighting
		},
		indent = {
			enable = true, -- Ensure indenting works with treesitter
		},
		autotag = {
			enable = true, -- Enable auto-tagging for inline HTML in JS/TSX
			filetypes = {
				"html",
				"javascript",
				"typescript",
				"svelte",
				"vue",
				"tsx",
				"jsx",
				"rescript",
				"css",
				"lua",
				"xml",
				"php",
				"markdown",
			},
		},
	},
}
