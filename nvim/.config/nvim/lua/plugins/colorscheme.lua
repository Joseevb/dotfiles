return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		opts = {
			lsp_styles = {
				underlines = {
					errors = { "undercurl" },
					hints = { "undercurl" },
					warnings = { "undercurl" },
					information = { "undercurl" },
				},
			},
			custom_highlights = function(colors)
				return {
					NormalFloat = { bg = colors.none },
					FloatBorder = { bg = colors.none, fg = colors.blue },
					FloatTitle = { bg = colors.none },
				}
			end,
			auto_integrations = true,
			integrations = {
				blink_cmp = { style = "bordered" },
				aerial = true,
				alpha = true,
				cmp = true,
				dashboard = true,
				flash = true,
				fzf = true,
				grug_far = true,
				gitsigns = true,
				headlines = true,
				illuminate = true,
				indent_blankline = { enabled = true },
				leap = true,
				lsp_trouble = true,
				lsp_styles = {
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
						ok = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
						ok = { "underline" },
					},
					inlay_hints = {
						background = true,
					},
				},
				mason = true,
				markview = true,
				mini = true,
				navic = { enabled = true, custom_bg = "lualine" },
				neotest = true,
				neotree = true,
				noice = true,
				notify = true,
				snacks = true,
				telescope = true,
				treesitter_context = true,
				which_key = true,
			},
		},
		config = function()
			vim.cmd([[colorscheme catppuccin]])
		end,
	},
}
