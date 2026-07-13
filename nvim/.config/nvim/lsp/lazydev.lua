vim.pack.add {
  pkg 'folke/lazydev.nvim',
}

require('lazydev').setup {
  library = { 'nvim-dap-ui' },
}
