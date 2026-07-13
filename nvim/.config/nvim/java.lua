local fn = require 'functions'

local ensure_loaded = fn.load_once('plugins.lsp.java', function()
  vim.pack.add {
    pkg('JavaHello/spring-boot.nvim', { version = '218c0c26c14d99feca778e4d13f5ec3e8b1b60f0' }),
    pkg 'MunifTanjim/nui.nvim',
    pkg 'mfussenegger/nvim-dap',
    pkg 'nvim-java/nvim-java',
  }

  require('java').setup {}
  vim.lsp.enable 'jdtls'

  vim.lsp.config('jdtls', {
    settings = {
      java = {
        configuration = {
          runtimes = {
            {
              name = 'JavaSE-21',
              path = '/home/jose/.asdf/installs/ivm-java/openjdk-21.0.4',
              default = true,
            },
            {
              name = 'JavaSE-25',
              path = '/home/jose/.asdf/installs/ivm-java/openjdk-25.0.2',
              default = false,
            },
          },
        },
      },
    },
  })
end)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('LazyJavaTools', { clear = true }),
  pattern = 'java',
  once = true,
  callback = ensure_loaded,
})
