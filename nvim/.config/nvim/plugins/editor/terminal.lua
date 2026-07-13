local map = vim.keymap.set

vim.pack.add { pkg 'CRAG666/betterTerm.nvim' }

local betterTerm = require 'betterTerm'

betterTerm.setup {
	show_tabs = true,
	clear_env = false,
	startInserted = true,
	size = 15,
	position = 'bot',
}

map({ 'n', 't' }, '<M-;>', function()
	betterTerm.open()
end, {
	desc = 'Toggle terminal',
	silent = true,
})

map('t', '<M-l>', function()
	betterTerm.cycle(1)
end, { desc = 'Cycle terminal to the right' })


map('t', '<M-h>', function()
	betterTerm.cycle(-1)
end, { desc = 'Cycle terminal to the left' })
