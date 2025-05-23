local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "jose.plugins" },
		{ import = "jose.plugins.code" },
		{ import = "jose.plugins.code.lsp" },
		{ import = "jose.plugins.ui" },
		{ import = "jose.plugins.ai" },
		{ import = "jose.plugins.ai.codecompanion" },
	},
})
