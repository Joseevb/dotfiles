local map = vim.keymap.set
local fn = require 'functions'

local ensure_loaded = fn.load_once('plugins.editor.grug', function()
  vim.pack.add { pkg 'MagicDuck/grug-far.nvim' }
  require('grug-far').setup {}
end)

map({ 'n', 'v' }, '<leader>sr', function()
  if not ensure_loaded() then
    return
  end

  require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } }
end, { desc = 'Search and Replace (Grug)' })
