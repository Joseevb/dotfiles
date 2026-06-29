local map = vim.keymap.set
local fn = require 'functions'

map({ 'n', 'v', 'x' }, '<C-p>', [["_dP]], { desc = 'Paste without overwriting clipboard' })

-- sys clipboard
map({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
map({ 'n', 'v' }, '<leader>Y', '"+Y', { desc = 'Yank line to system clipboard' })
map({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
map({ 'n', 'v' }, '<leader>P', '"+P', { desc = 'Paste from system clipboard' })
map({ 'n', 'v' }, '<leader>d', '"+d', { desc = 'Delete to system clipboard' })
map({ 'n', 'v' }, '<leader>D', '"+D', { desc = 'Delete line to system clipboard' })
map({ 'n', 'v' }, '<leader>c', '"+c', { desc = 'Cut to system clipboard' })
map({ 'n', 'v' }, '<leader>C', '"+C', { desc = 'Cut line to system clipboard' })

-- line movement
map('v', 'J', "<cmd>m '>+1<CR>gv=gv", { desc = 'Move line down in visual mode' })
map('v', 'K', "<cmd>m '<-2<CR>gv=gv", { desc = 'Move line up in visual mode' })

-- navigation
map('n', 'gt', ']t', { noremap = true, silent = true, desc = 'Next tag' })
map('n', 'gT', '[t', { noremap = true, silent = true, desc = 'Previous tag' })
map('n', 'n', 'nzzzv', { desc = 'Search next and center' })
map('n', 'N', 'Nzzzv', { desc = 'Search previous and center' })

-- indentation
map('v', '>', '>gv', { desc = 'Indent selected block' })
map('v', '<', '<gv', { desc = 'Unindent selected block' })

-- selection
map('n', '<leader>sa', 'ggVG', { desc = 'Select all text' })

-- buff management
map('n', '<C-b>q', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })
map('n', '<C-b>Q', '<cmd>bdelete!<CR>', { desc = 'Force delete buffer' })

-- others
map('t', '<Esc>', '<C-\\><C-n>', { desc = 'Escape terminal mode' })
map('n', '<C-c>', '<Esc><cmd>noh<CR>', { desc = 'Escape key alternative', silent = true })

map('n', 'zp', function()
  fn.peek_fold()
end, { desc = 'Preview fold' })

map('n', '<leader>ns', function()
  require('utils.scratch').open_scratch()
end, { desc = 'New Scratch File' })
