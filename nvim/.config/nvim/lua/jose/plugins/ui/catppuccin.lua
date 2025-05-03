return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	opts = {
		flavour = "macchiato", -- latte, frappe, macchiato, mocha
		background = { -- :h background
			light = "latte",
			dark = "macchiato",
		},
		transparent_background = true, -- disables setting the background color.
		show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
		term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
		dim_inactive = {
			enabled = false, -- dims the background color of inactive window
			shade = "dark",
			percentage = 0.15, -- percentage of the shade to apply to the inactive window
		},
		no_italic = false, -- force no italic
		no_bold = false, -- force no bold
		no_underline = false, -- force no underline
		styles = { -- handles the styles of general hi groups (see `:h highlight-args`):
			comments = { "italic" }, -- change the style of comments
			conditionals = { "italic" },
			loops = { "bold" },
			functions = { "italic" },
			keywords = { "italic" },
			strings = {},
			variables = { "bold" },
			numbers = {},
			booleans = { "bold" },
			properties = {},
			types = { "italic" },
			operators = {},
		},
		color_overrides = {},
		custom_highlights = {},
		integrations = {
			cmp = true,
			gitsigns = true,
			nvimtree = true,
			treesitter = true,
			notify = true,
			mini = {
				enabled = true,
				indentscope_color = "",
			},
			harpoon = true,
			neotree = true,
			mason = true,
			neotest = true,
			copilot_vim = true,
			dap = true,
			dap_ui = true,
			native_lsp = {
				enabled = true,
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
			snacks = {
				enabled = false,
				indent_scope_color = "", -- catppuccin color (eg. `lavender`) Default: text
			},
			colorful_winsep = {
				enabled = false,
				color = "red",
			},
			telescope = { enabled = true },
			dadbod_ui = true,
			which_key = true,
			fzf = true,
			-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
		},
	},
}
