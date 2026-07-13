vim.pack.add { pkg 'catppuccin/nvim' }

require('catppuccin').setup {
  lsp_styles = {
    underlines = {
      errors = { 'undercurl' },
      hints = { 'undercurl' },
      warnings = { 'undercurl' },
      information = { 'undercurl' },
    },
  },
  auto_integrations = false,
  integrations = {
    dap = true,
    dap_ui = true,
    diffview = true,
    gitgraph = true,
    gitsigns = true,
    grug_far = true,
    lsp_styles = {
      virtual_text = {
        errors = { 'italic' },
        hints = { 'italic' },
        warnings = { 'italic' },
        information = { 'italic' },
        ok = { 'italic' },
      },
      underlines = {
        errors = { 'underline' },
        hints = { 'underline' },
        warnings = { 'underline' },
        information = { 'underline' },
        ok = { 'underline' },
      },
      inlay_hints = {
        background = true,
      },
    },
    mason = true,
    mini = true,
    render_markdown = true,
    treesitter_context = true,
  },
  custom_highlights = function(colors)
    return {
      Pmenu = { bg = colors.base },
      PmenuSel = { bg = colors.surface0, fg = colors.text },
      PmenuSbar = { bg = colors.surface0 },
      PmenuThumb = { bg = colors.overlay0 },
      PmenuBorder = { bg = colors.base, fg = colors.blue },
      PmenuMatch = { fg = colors.blue, style = { 'bold' } },
      PmenuMatchSel = { fg = colors.blue, bg = colors.surface0, style = { 'bold' } },

      NormalFloat = { bg = colors.base },
      FloatBorder = { bg = colors.base, fg = colors.blue },
      FloatTitle = { bg = colors.base, fg = colors.blue },
    }
  end,
}

vim.cmd.colorscheme 'catppuccin'
