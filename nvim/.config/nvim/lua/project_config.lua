local M = {}

---@alias ProjectFormatter
---| 'eslint'
---| 'prettier'
---| 'null-ls'

---@class ProjectFlags
---@field project_formatter? ProjectFormatter Name of the LSP client that format-on-save should use.
---@field project_format_on_save? boolean Whether LSP format-on-save should run for this project.

M.flags = {
  {
    name = 'project_formatter',
    type = 'string',
    description = 'Name of the LSP client that format-on-save should use.',
    docs_default = 'use any attached LSP formatter',
    runtime_default = nil,
    examples = { 'eslint', 'prettier', 'null-ls' },
  },
  {
    name = 'project_format_on_save',
    type = 'boolean',
    description = 'Whether LSP format-on-save should run for this project.',
    docs_default = 'enabled',
    runtime_default = true,
    examples = { 'true', 'false' },
  },
}

local function get_flag_definition(name)
  for _, flag in ipairs(M.flags) do
    if flag.name == name then
      return flag
    end
  end

  return nil
end

function M.get_flag(name, fallback)
  local value = vim.g[name]
  if value ~= nil then
    return value
  end

  if fallback ~= nil then
    return fallback
  end

  local flag = get_flag_definition(name)
  return flag and flag.runtime_default or nil
end

---@param values ProjectFlags
---@return ProjectFlags
function M.set_flags(values)
  for name, value in pairs(values) do
    vim.g[name] = value
  end

  return values
end

function M.reset_flags()
  for _, flag in ipairs(M.flags) do
    vim.g[flag.name] = nil
  end
end

function M.template_lines()
  local lines = {
    '-- Project-specific Neovim configuration.',
    '--',
    '-- How it is loaded:',
    '-- 1. Neovim looks for the nearest ancestor .nvim/init.lua from your current cwd.',
    '-- 2. If none is found, it tries the current git root .nvim/init.lua.',
    '-- 3. If none is found, it falls back to the main worktree root .nvim/init.lua.',
    '--',
    '-- How project flags work:',
    '-- 1. Call set_project_flags({ ... }) to set repo-local flags.',
    '-- 2. Omit a flag to keep the default behavior from your global config.',
    '-- 3. Flags are stored in vim.g so any part of your config can read them.',
    '-- 4. Add normal autocmds, mappings, or settings below as needed.',
    '--',
    '-- Available project flags:',
  }

  for _, flag in ipairs(M.flags) do
    table.insert(lines, '--')
    table.insert(lines, '-- ' .. flag.name .. ' (' .. flag.type .. ')')
    table.insert(lines, '--   ' .. flag.description)
    table.insert(lines, '--   Default behavior: ' .. flag.docs_default .. '.')
    table.insert(lines, '--   Examples: ' .. table.concat(flag.examples, ', '))
    table.insert(lines, '--   Usage:')
    table.insert(lines, '--     set_project_flags({')
    local example = flag.type == 'string' and ("'" .. flag.examples[1] .. "'") or flag.examples[1]
    table.insert(lines, '--       ' .. flag.name .. ' = ' .. example .. ',')
    table.insert(lines, '--     })')
  end

  table.insert(lines, '--')
  table.insert(lines, '-- Uncomment and edit this block to enable project flags:')
  table.insert(lines, '-- set_project_flags({')
  for _, flag in ipairs(M.flags) do
    local example = flag.type == 'string' and ("'" .. flag.examples[1] .. "'") or flag.examples[1]
    table.insert(lines, '-- 	' .. flag.name .. ' = ' .. example .. ',')
  end
  table.insert(lines, '-- })')
  table.insert(lines, '')

  return lines
end

---@type fun(name: string, fallback?: any): any
_G.get_project_flag = M.get_flag

---@type fun(values: ProjectFlags): ProjectFlags
_G.set_project_flags = M.set_flags

return M
