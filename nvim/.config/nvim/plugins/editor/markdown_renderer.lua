local fn = require 'functions'

local ensure_loaded = fn.load_once('plugins.editor.markdown_renderer', function()
  vim.pack.add {
    pkg 'nvim-treesitter/nvim-treesitter',
    pkg 'nvim-mini/mini.icons',
    pkg 'MeanderingProgrammer/render-markdown.nvim',
  }

  require('render-markdown').setup {
    completions = { lsp = { enabled = true } },
    file_types = { 'markdown', 'vimwiki', 'md' },
    latex = {
      enabled = true,
      render_modes = false,
      converter = { 'utftex', 'latex2text' },
      highlight = 'RenderMarkdownMath',
      position = 'center',
      top_pad = 0,
      bottom_pad = 0,
    },
  }

  vim.treesitter.language.register('markdown', 'vimwiki')
end)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('LazyRenderMarkdown', { clear = true }),
  pattern = { 'markdown', 'vimwiki', 'md' },
  once = true,
  callback = ensure_loaded,
})
