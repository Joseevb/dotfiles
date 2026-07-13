-- Project-local config with session-preserving restart
local M = {}

local project_config = {
  dir = nil,
  augroup = vim.api.nvim_create_augroup('ProjectConfig', { clear = true }),
}
local native_require = require
local flags = require 'project_config'

local function run_git(cwd, args)
  local result = vim.system(vim.list_extend({ 'git', '-C', cwd }, args), { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end

  local path = vim.trim(result.stdout or '')
  return path ~= '' and path or nil
end

local function get_git_toplevel(cwd)
  return run_git(cwd, { 'rev-parse', '--path-format=absolute', '--show-toplevel' })
end

local function get_main_worktree_root(cwd)
  local output = run_git(cwd, { 'worktree', 'list', '--porcelain' })
  if not output then
    return nil
  end

  for line in output:gmatch '[^\r\n]+' do
    local path = line:match '^worktree%s+(.+)$'
    if path then
      return path
    end
  end

  return nil
end

local function has_project_init(path)
  return path and vim.fn.filereadable(vim.fs.joinpath(path, '.nvim', 'init.lua')) == 1
end

local function get_root_project_config_file(cwd)
  local git_toplevel = get_git_toplevel(cwd)
  if not git_toplevel then
    return nil
  end

  return vim.fs.joinpath(git_toplevel, '.nvim', 'init.lua')
end

local function get_project_config_template()
  return flags.template_lines()
end

local function ensure_project_config_file(file)
  local config_dir = vim.fs.dirname(file)
  if vim.fn.isdirectory(config_dir) == 0 then
    vim.fn.mkdir(config_dir, 'p')
  end

  if vim.fn.filereadable(file) == 0 then
    vim.fn.writefile(get_project_config_template(), file)
  end

  return file
end

local function get_config_dir(cwd)
  local local_config = vim.fs.find('.nvim', { path = cwd, upward = true, type = 'directory', limit = 1 })[1]
  if local_config and vim.fn.filereadable(vim.fs.joinpath(local_config, 'init.lua')) == 1 then
    return local_config
  end

  local git_toplevel = get_git_toplevel(cwd)
  if has_project_init(git_toplevel) then
    return vim.fs.joinpath(git_toplevel, '.nvim')
  end

  local main_worktree_root = get_main_worktree_root(cwd)
  if has_project_init(main_worktree_root) then
    return vim.fs.joinpath(main_worktree_root, '.nvim')
  end

  return nil
end

local function watch_config_dir(config_dir)
  vim.api.nvim_clear_autocmds { group = project_config.augroup }
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = project_config.augroup,
    pattern = {
      vim.fs.joinpath(config_dir, '*.lua'),
      vim.fs.joinpath(config_dir, '**', '*.lua'),
    },
    callback = function()
      vim.notify('Project config changed, restarting...', vim.log.levels.INFO)
      vim.cmd 'RestartProject'
    end,
  })
end

-- Save session before restart
local function save_session()
  local session_file = vim.fn.stdpath 'state' .. '/project_restart_session.vim'
  vim.opt.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
  vim.cmd('mksession! ' .. vim.fn.fnameescape(session_file))
  return session_file
end

-- Load project config (simplified version)
function M.load_project()
  local cwd = vim.fn.getcwd()
  local config_dir = get_config_dir(cwd)
  project_config.dir = config_dir
  flags.reset_flags()

  if not config_dir then
    vim.api.nvim_clear_autocmds { group = project_config.augroup }
    return
  end

  local init_file = config_dir .. '/init.lua'

  -- Custom require for project modules
  local function project_require(name)
    local path = config_dir .. '/' .. name:gsub('%.', '/') .. '.lua'
    local init_path = config_dir .. '/' .. name:gsub('%.', '/') .. '/init.lua'

    local file = vim.fn.filereadable(path) == 1 and path or vim.fn.filereadable(init_path) == 1 and init_path or nil

    if not file then
      return native_require(name)
    end

    local chunk, err = loadfile(file)
    if not chunk then
      error(err)
    end

    local env = setmetatable({ require = project_require }, { __index = _G })
    setfenv(chunk, env)
    return chunk()
  end

  local chunk, err = loadfile(init_file)
  if not chunk then
    vim.notify('Failed to load project config: ' .. err, vim.log.levels.ERROR)
    return
  end

  local env = setmetatable({ require = project_require }, { __index = _G })
  setfenv(chunk, env)

  local ok, runtime_err = pcall(chunk)
  if not ok then
    vim.notify('Project config error: ' .. tostring(runtime_err), vim.log.levels.ERROR)
    return
  end

  watch_config_dir(config_dir)
end

-- Hot-reload: save session, restart, restore session
vim.api.nvim_create_user_command('RestartProject', function()
  local session_file = save_session()
  -- Restart and source the session file
  vim.cmd('restart source ' .. vim.fn.fnameescape(session_file))
end, { desc = 'Restart Nvim with project config and restore session' })

vim.api.nvim_create_user_command('ProjectConfig', function()
  local file = get_root_project_config_file(vim.fn.getcwd())
  if not file then
    vim.notify('ProjectConfig: not inside a git repository', vim.log.levels.ERROR)
    return
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(ensure_project_config_file(file)))
  M.load_project()
  vim.notify('Opened project config: ' .. file, vim.log.levels.INFO)
end, { desc = 'Open or create the repo project config' })

-- Also map it
vim.keymap.set('n', '<C-A-r>', '<cmd>RestartProject<cr>', { desc = 'Restart with session' })

return M
