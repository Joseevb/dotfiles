local fn = require 'functions'

local ensure_loaded = fn.load_once('plugins.ai.supermaven', function()
  vim.pack.add { pkg 'supermaven-inc/supermaven-nvim' }
  require('supermaven-nvim').setup {}
end)

vim.api.nvim_create_autocmd('InsertEnter', {
  group = vim.api.nvim_create_augroup('LazySupermaven', { clear = true }),
  once = true,
  callback = ensure_loaded,
})
