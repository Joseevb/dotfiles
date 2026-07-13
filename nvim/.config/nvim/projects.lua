local M = {}

M.root_markers = {
  '.nvim',
  '.project',
  '.project-root',
  'package.json',
  'deno.json',
  'deno.jsonc',
  'Cargo.toml',
  'go.mod',
  'pom.xml',
  'build.gradle',
  'build.gradle.kts',
  'settings.gradle',
  'settings.gradle.kts',
  'pyproject.toml',
  'composer.json',
  'mix.exs',
  'Gemfile',
  'Makefile',
  '.git',
}

local state_file = vim.fs.joinpath(vim.fn.stdpath 'state', 'projects.json')
local max_projects = 100

local function normalize(path)
  if not path or path == '' then
    return nil
  end

  return vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
end

local function is_dir(path)
  return path and vim.fn.isdirectory(path) == 1
end

local function parent(path)
  return vim.fs.dirname(path:gsub('/$', ''))
end

local function project_root_from_marker(path)
  local marker = vim.fs.find(M.root_markers, { path = path, upward = true, limit = 1 })[1]
  if not marker then
    return nil
  end

  return parent(marker)
end

function M.root(path, opts)
  opts = opts or {}
  path = normalize(path)
  if not path then
    return nil
  end

  local start = is_dir(path) and path or parent(path)
  if not start or not is_dir(start) then
    return nil
  end

  local root = project_root_from_marker(start)
  if not root and opts.fallback ~= false then
    root = start
  end

  return normalize(root)
end

local function read_state()
  if vim.fn.filereadable(state_file) == 0 then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(state_file), '\n'))
  if not ok or type(decoded) ~= 'table' then
    return {}
  end

  return decoded
end

local function write_state(projects)
  vim.fn.mkdir(vim.fs.dirname(state_file), 'p')
  vim.fn.writefile({ vim.json.encode(projects) }, state_file)
end

local function dedupe(projects)
  local seen = {}
  local result = {}

  for _, project in ipairs(projects) do
    local root = normalize(project)
    if root and is_dir(root) and not seen[root] then
      seen[root] = true
      result[#result + 1] = root

      if #result >= max_projects then
        break
      end
    end
  end

  return result
end

function M.record(path)
  local root = M.root(path or vim.fn.getcwd())
  if not root then
    return
  end

  local projects = read_state()
  table.insert(projects, 1, root)
  write_state(dedupe(projects))
end

function M.recent()
  local projects = read_state()

  for _, file in ipairs(vim.v.oldfiles or {}) do
    local root = M.root(file, { fallback = false })
    if root then
      projects[#projects + 1] = root
    end
  end

  return dedupe(projects)
end

function M.chdir(path)
  local root = M.root(path)
  if not root then
    vim.notify('Projects: invalid project root', vim.log.levels.ERROR)
    return
  end

  vim.cmd('cd ' .. vim.fn.fnameescape(root))
  M.record(root)

  local ok, project_loader = pcall(require, 'project_loader')
  if ok then
    project_loader.load_project()
  end

  vim.notify('Project: ' .. root, vim.log.levels.INFO)
end

function M.pick()
  local projects = M.recent()
  if #projects == 0 then
    vim.notify('Projects: no recent projects found', vim.log.levels.WARN)
    return
  end

  require('mini.pick').start {
    source = {
      name = 'Projects',
      items = projects,
      choose = M.chdir,
    },
  }
end

function M.setup()
  vim.schedule(function()
    M.record(vim.fn.getcwd())
  end)

  vim.api.nvim_create_autocmd('DirChanged', {
    group = vim.api.nvim_create_augroup('RecentProjects', { clear = true }),
    callback = function()
      M.record(vim.fn.getcwd())
    end,
  })
end

return M
