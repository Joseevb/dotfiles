local fn = require 'functions'
local map = vim.keymap.set

local ensure_loaded = fn.load_once('plugins.lsp.dap', function()
  vim.pack.add {
    pkg 'jay-babu/mason-nvim-dap.nvim',
    pkg 'theHamsta/nvim-dap-virtual-text',
    pkg('mfussenegger/nvim-dap', { source = 'codeberg' }),
    pkg 'nvim-neotest/nvim-nio',
    pkg 'rcarriga/nvim-dap-ui',
  }

  vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DiagnosticError', linehl = '', numhl = '' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '🔵', texthl = 'DiagnosticInfo', linehl = '', numhl = '' })
  vim.fn.sign_define('DapBreakpointRejected', { text = '🚫', texthl = 'DiagnosticError', linehl = '', numhl = '' })
  vim.fn.sign_define('DapLogPoint', { text = '📝', texthl = 'DiagnosticSignInfo', linehl = '', numhl = '' })
  vim.fn.sign_define('DapStopped', { text = '▶️', texthl = 'DiagnosticSignWarn', linehl = '', numhl = '' })

  require('nvim-dap-virtual-text').setup {
    enabled = true,
    enabled_commands = true,
    highlight_changed_variables = true,
    highlight_new_as_changed = false,
    show_stop_reason = true,
    commented = false,
    only_first_definition = true,
    all_references = false,
    virt_text_pos = 'eol',
  }

  fn.load_after({ 'mason', 'mason-lspconfig' }, 'mason-nvim-dap', {
    ensure_installed = { 'js-debug-adapter' },
    automatic_installation = true,
    handlers = {
      function(config)
        require('mason-nvim-dap').default_setup(config)
      end,
    },
  }, function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    for _, language in ipairs { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' } do
      dap.configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file (tsx)',
          runtimeExecutable = 'tsx',
          args = { '${file}' },
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
          skipFiles = { '<node_internals>/**', 'node_modules/**' },
        },
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file (node)',
          program = '${file}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to process',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
          sourceMaps = true,
        },
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Debug Jest tests',
          runtimeExecutable = 'node',
          runtimeArgs = {
            './node_modules/jest/bin/jest.js',
            '--runInBand',
            '--testPathPattern',
            '${fileBasenameNoExtension}',
          },
          rootPath = '${workspaceFolder}',
          cwd = '${workspaceFolder}',
          console = 'integratedTerminal',
          internalConsoleOptions = 'neverOpen',
          sourceMaps = true,
        },
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Debug Vitest tests',
          runtimeExecutable = 'npx',
          runtimeArgs = {
            'vitest',
            'run',
            '--reporter=verbose',
            '${fileBasenameNoExtension}',
          },
          cwd = '${workspaceFolder}',
          console = 'integratedTerminal',
          internalConsoleOptions = 'neverOpen',
          sourceMaps = true,
        },
      }
    end

    dapui.setup {}

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end)
end)

map('n', '<leader>db', function()
  if not ensure_loaded() then
    return
  end

  require('dap').toggle_breakpoint()
end, { desc = 'Toggle Breakpoint' })

map('n', '<leader>dc', function()
  if not ensure_loaded() then
    return
  end

  require('dap').continue()
end, { desc = 'Start/Continue Debug Session' })
