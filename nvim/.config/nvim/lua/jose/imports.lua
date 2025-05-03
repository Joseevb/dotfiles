-- imports.lua
-- Define fold regions of imports, includes, etc for nvim
-- Support language:     keyword:
--       java            import
--       c/cpp           #include
--       python          import/from ... import
--       php             use
-- Copyright (C) 2023 elementdavv<elementdavv@hotmail.com>
-- Distributed under terms of the GPL3 license.

-- Set foldmethod and foldexpr
vim.cmd('set foldlevel=20')
vim.cmd('set foldmethod=expr')
vim.cmd('set foldexpr=nvim_treesitter#foldexpr()')

-- Autocommands for file types
vim.api.nvim_exec([[
  augroup ImportFolds
    autocmd!
    autocmd FileType java setlocal foldexpr=v:lua.FileTypeExpr
    autocmd FileType c,cpp setlocal foldexpr=v:lua.FileTypeExpr
    autocmd FileType python setlocal foldexpr=v:lua.FileTypeExpr
    autocmd FileType php setlocal foldexpr=v:lua.FileTypeExpr
  augroup END
]], false)

-- State variables
local hasdoc = 0
local hasimport = 0

-- Check block comments
local function DocExpr(linenumber)
  local aline = vim.fn.getline(linenumber)
  if aline:match('^%s*/%*.*%*/$') then  -- single line comment
    if hasdoc > 0 then
      return '='
    else
      return '0'
    end
  elseif aline:match('^%s*/%*.*$') then  -- start of doc fold
    hasdoc = hasdoc + 1
    return 'a1'
  elseif aline:match('^%s*%*/%s*$') then  -- end of doc fold
    hasdoc = hasdoc - 1
    return 's1'
  elseif hasdoc > 0 then  -- continue of doc fold
    return '='
  end
  return '0'
end

-- Check imports/includes
local function ImportExpr(linenumber, reg)
  local aline = vim.fn.getline(linenumber)
  if aline:match(reg) then
    if hasimport == 1 then
      if ImportContinued(linenumber, reg) then
        return '='  -- in between imports
      else
        hasimport = 0
        return 's1'  -- last import
      end
    else
      if ImportContinued(linenumber, reg) then
        hasimport = 1  -- create region for at least 2 imports
        return 'a1'
      else
        return '0'  -- only 1 import, not create region
      end
    end
  end
  if hasimport == 1 then
    return '='
  end
  return '0'
end

-- Check if import continued on next line, blank lines ignored
local function ImportContinued(linenumber, reg)
  local nextline = linenumber
  while true do
    nextline = nextline + 1
    local bline = vim.fn.getline(nextline)
    if bline:match(reg) then
      return true
    end
    if bline:match('^%s*$') then
      -- continue
    else
      return false
    end
  end
end

-- Main fold expression function
function FileTypeExpr(lnum)
  local ft = vim.bo.filetype
  if ft == 'java' or ft == 'php' then
    local docexpr = DocExpr(lnum)
    if docexpr ~= '0' then
      return docexpr
    end
  end

  local reg = ''
  if ft == 'java' then
    reg = '^%s*import'
  elseif ft == 'cpp' then
    reg = '^%s*#include'
  elseif ft == 'python' then
    reg = '^%s*(from.*import|import)'
  elseif ft == 'php' then
    reg = '^%s*use'
  end
  local importexpr = ImportExpr(lnum, reg)
  if importexpr ~= '0' then
    return importexpr
  end

  return vim.fn['nvim_treesitter#foldexpr']()
end
