vim.pack.add {
  pkg 'nvim-mini/mini.ai',
  pkg 'nvim-mini/mini.jump2d',
  pkg 'nvim-mini/mini.pick',
  pkg 'nvim-mini/mini.clue',
  pkg 'nvim-mini/mini.icons',
  pkg 'nvim-mini/mini.files',
  pkg 'nvim-mini/mini.notify',
  pkg 'nvim-mini/mini.cmdline',
  pkg 'nvim-mini/mini.tabline',
  pkg 'nvim-mini/mini.surround',
  pkg 'nvim-mini/mini.statusline',
  pkg 'nvim-mini/mini.hipatterns',
  pkg 'nvim-mini/mini.indentscope',
}

local map = vim.keymap.set

-- Pick
local pick = require 'mini.pick'
pick.setup {}

map('n', '<leader>sf', pick.builtin.files, { desc = 'Find files' })
map('n', '<leader>sb', pick.builtin.buffers, { desc = 'Find buffers' })
map('n', '<leader>sw', pick.builtin.grep_live, { desc = 'Live grep' })
map('n', '<leader>sp', function()
  require('utils.projects').pick()
end, { desc = 'Find projects' })
map('n', '<leader>sg', function()
  require('utils.git_files').pick()
end, { desc = 'Find Modified files' })

-- Jump2d
require('mini.jump2d').setup {}

-- AI
require('mini.ai').setup {}

-- Surround
require('mini.surround').setup {}

-- Clue
local miniclue = require 'mini.clue'
miniclue.setup {
  triggers = {
    -- Leader triggers
    { mode = { 'n', 'x' }, keys = '<Leader>' },

    -- `[` and `]` keys
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = ']' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = { 'n', 'x' }, keys = 'g' },

    -- Marks
    { mode = { 'n', 'x' }, keys = "'" },
    { mode = { 'n', 'x' }, keys = '`' },

    -- Registers
    { mode = { 'n', 'x' }, keys = '"' },
    { mode = { 'i', 'c' }, keys = '<C-r>' },

    -- Window commands
    { mode = 'n', keys = '<C-w>' },

    -- `z` key
    { mode = { 'n', 'x' }, keys = 'z' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.square_brackets(),
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
}

-- Files
require('mini.files').setup {
  options = {
    permanent_delete = false,
    use_as_default_explorer = true,
  },
  windows = {
    preview = true,
    width_preview = 120,
  },
}

map({ 'n' }, '<leader>e', function()
  if not MiniFiles.close() then
    -- Wasn't open, so open at current file
    MiniFiles.open(vim.api.nvim_buf_get_name(0))
  end
end, { desc = 'Toggle mini.files at current file' })

-- Notify
require('mini.notify').setup {}

-- Cmdline
require('mini.cmdline').setup {}

-- StatusLine
require('mini.statusline').setup {}

-- TabLine
require('mini.tabline').setup {}

-- HiPatterns
local hi = require 'mini.hipatterns'

local M = {
  hl = {},
  colors = {
    slate = {
      [50] = 'f8fafc',
      [100] = 'f1f5f9',
      [200] = 'e2e8f0',
      [300] = 'cbd5e1',
      [400] = '94a3b8',
      [500] = '64748b',
      [600] = '475569',
      [700] = '334155',
      [800] = '1e293b',
      [900] = '0f172a',
      [950] = '020617',
    },
    gray = {
      [50] = 'f9fafb',
      [100] = 'f3f4f6',
      [200] = 'e5e7eb',
      [300] = 'd1d5db',
      [400] = '9ca3af',
      [500] = '6b7280',
      [600] = '4b5563',
      [700] = '374151',
      [800] = '1f2937',
      [900] = '111827',
      [950] = '030712',
    },
  },
}

local hipatterns_opts = {
  highlighters = {
    hex_color = hi.gen_highlighter.hex_color { priority = 2000 },
    shorthand = {
      pattern = '()#%x%x%x()%f[^%x%w]',
      group = function(_, _, data)
        local match = data.full_match
        local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
        local hex_color = '#' .. r .. r .. g .. g .. b .. b
        return hi.compute_hex_color_group(hex_color, 'bg')
      end,
      extmark_opts = { priority = 2000 },
    },
  },
}

-- Tailwind setup
local tailwind = {
  enabled = true,
  ft = {
    'astro',
    'css',
    'heex',
    'html',
    'html-eex',
    'javascript',
    'javascriptreact',
    'rust',
    'svelte',
    'typescript',
    'typescriptreact',
    'vue',
  },
  style = 'full', -- "full" | "compact"
}

if tailwind.enabled then
  -- Clear highlights on colorscheme change
  vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
      M.hl = {}
    end,
  })

  hipatterns_opts.highlighters.tailwind = {
    pattern = function()
      if not vim.tbl_contains(tailwind.ft, vim.bo.filetype) then
        return
      end
      if tailwind.style == 'full' then
        return '%f[%w:-]()[%w:-]+%-[a-z%-]+%-%d+()%f[^%w:-]'
      else
        return '%f[%w:-][%w:-]+%-()[a-z%-]+%-%d+()%f[^%w:-]'
      end
    end,
    group = function(_, _, m)
      local match = m.full_match
      local color, shade = match:match '[%w-]+%-([a-z%-]+)%-(%d+)'
      shade = tonumber(shade)
      local bg = vim.tbl_get(M.colors, color, shade)
      if bg then
        local hl_name = 'MiniHipatternsTailwind' .. color .. shade
        if not M.hl[hl_name] then
          M.hl[hl_name] = true
          local bg_shade = shade == 500 and 950 or shade < 500 and 900 or 100
          local fg = vim.tbl_get(M.colors, color, bg_shade)
          vim.api.nvim_set_hl(0, hl_name, { bg = '#' .. bg, fg = '#' .. fg })
        end
        return hl_name
      end
    end,
    extmark_opts = { priority = 2000 },
  }
end

hi.setup(hipatterns_opts)

-- Indent scope
require('mini.indentscope').setup {}
