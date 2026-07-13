vim.pack.add({
	pkg 'mcauley-penney/visual-whitespace.nvim',
}, { load = false })

-- configuring with lazy load on entering visual mode
vim.api.nvim_create_autocmd('ModeChanged', {
	pattern = '*:[vV\22]',
	once = true,
	callback = function()
		vim.cmd.packadd 'visual-whitespace.nvim'
		require 'visual-whitespace'.setup {}
	end,
})
