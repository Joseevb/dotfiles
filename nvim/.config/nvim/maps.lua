local map = vim.keymap.set
local fn = require 'functions'

-- Paste over selection without overwriting register
map('x', '<C-p>', [["_dP]], {
	desc = 'Paste without overwriting register',
})

-- System clipboard
map({ 'n', 'x' }, '<leader>y', '"+y', {
	desc = 'Yank to system clipboard',
})

map('n', '<leader>Y', '"+Y', {
	desc = 'Yank line to system clipboard',
})

map({ 'n', 'x' }, '<leader>p', '"+p', {
	desc = 'Paste from system clipboard',
})

map({ 'n', 'x' }, '<leader>P', '"+P', {
	desc = 'Paste before from system clipboard',
})

map({ 'n', 'x' }, '<leader>d', '"+d', {
	desc = 'Delete to system clipboard',
})

map('n', '<leader>D', '"+dd', {
	desc = 'Delete line to system clipboard',
})

map({ 'n', 'x' }, '<leader>c', '"+c', {
	desc = 'Change to system clipboard',
})

map('n', '<leader>C', '"+cc', {
	desc = 'Change line to system clipboard',
})

-- Line movement
map('x', 'J', ":move '>+1<CR>gv=gv", {
	desc = 'Move selection down',
	silent = true,
})

map('x', 'K', ":move '<-2<CR>gv=gv", {
	desc = 'Move selection up',
	silent = true,
})

-- Navigation
map('n', 'n', 'nzzzv', {
	desc = 'Search next and center',
})

map('n', 'N', 'Nzzzv', {
	desc = 'Search previous and center',
})

-- Indentation
map('x', '>', '>gv', {
	desc = 'Indent selected block',
})

map('x', '<', '<gv', {
	desc = 'Unindent selected block',
})

-- Selection
map('n', '<leader>sa', 'ggVG', {
	desc = 'Select all text',
})

-- Buffer management
map('n', '<C-b>q', '<cmd>bdelete<CR>', {
	desc = 'Delete buffer',
})

map('n', '<C-b>Q', '<cmd>bdelete!<CR>', {
	desc = 'Force delete buffer',
})

-- Terminal
map('t', '<C-]>', '<C-\\><C-n>', {
	desc = 'Escape terminal mode',
})

-- Misc
map('n', '<C-c>', '<Esc><cmd>noh<CR>', {
	desc = 'Clear search highlight',
	silent = true,
})

map('n', 'zp', function()
	fn.peek_fold()
end, {
	desc = 'Preview fold',
})

map('n', '<leader>ns', function()
	require 'utils.scratch'.open_scratch()
end, {
	desc = 'New scratch file',
})
