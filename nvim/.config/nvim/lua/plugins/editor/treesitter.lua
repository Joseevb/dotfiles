local ts_hooks = function()
  vim.defer_fn(function()
    vim.cmd.TSUpdate()
  end, 100)
end

local map = vim.keymap.set

local hooks = function()
  ts_hooks()
end

vim.api.nvim_create_autocmd('PackChanged', { callback = hooks })
vim.pack.add {
  pkg('nvim-treesitter/nvim-treesitter', { version = 'main' }),
  pkg 'nvim-treesitter/nvim-treesitter-context',
  pkg 'nvim-treesitter/nvim-treesitter-textobjects',
  pkg 'windwp/nvim-ts-autotag',
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

require('treesitter-context').setup {
  mode = 'cursor',
  max_lines = 3,
}

require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true,
    selection_modes = {
      ['@parameter.outer'] = 'v', -- charwise
      ['@function.outer'] = 'V', -- linewise
    },
    include_surrounding_whitespace = false,
  },
}

local ts_textobjects = require 'nvim-treesitter-textobjects.select'

map({ 'x', 'o' }, 'af', function()
  ts_textobjects.select_textobject('@function.outer', 'textobjects')
end)
map({ 'x', 'o' }, 'if', function()
  ts_textobjects.select_textobject('@function.inner', 'textobjects')
end)
map({ 'x', 'o' }, 'ac', function()
  ts_textobjects.select_textobject('@class.outer', 'textobjects')
end)
map({ 'x', 'o' }, 'ic', function()
  ts_textobjects.select_textobject('@class.inner', 'textobjects')
end)
map({ 'x', 'o' }, 'as', function()
  ts_textobjects.select_textobject('@local.scope', 'locals')
end)

require('nvim-ts-autotag').setup {}
