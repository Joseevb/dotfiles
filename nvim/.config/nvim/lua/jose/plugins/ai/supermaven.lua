return {
	"supermaven-inc/supermaven-nvim",
	opts = {
		keymaps = {
			accept_suggestion = "<Tab>",
			clear_suggestion = "<C-]>",
			accept_word = "<C-j>",
		},
		ignore_filetypes = { cpp = true }, -- or { "cpp", }
		color = {
			suggestion_color = "#555555", -- A darker gray instead of white (#ffffff)
			cterm = 244,
		},
		log_level = "info", -- set to "off" to disable logging completely
		disable_inline_completion = false, -- disables inline completion for use with cmp
		disable_keymaps = false, -- disables built in keymaps for more manual control
		condition = function()
			return false
		end,
	},
}
