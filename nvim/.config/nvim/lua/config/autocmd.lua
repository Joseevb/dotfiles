vim.api.nvim_set_hl(0, "YankHighlight", {
	background = "#6c7086",
	bold = true,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({
			timeout = 200,
			higroup = "YankHighlight",
		})
	end,
})
