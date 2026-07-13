local M = {}

local gh = 'https://github.com/'
local codeberg = 'https://codeberg.org/'

---@class PkgOpts
---@field name? string Plugin name. Used as directory name by vim.pack.
---@field version? string|vim.VersionRange Branch, tag, commit hash, or version range accepted by vim.pack.
---@field source? 'gh'|'codeberg'|string  Source platform or custom URL prefix (default: 'gh')
---@field data? any Arbitrary data associated with a plugin.

---Build a package spec for vim.pack.add()
---@param repo string  Repo in 'owner/name' format
---@param opts? PkgOpts  Optional spec fields
---@return string|vim.pack.Spec  URL string or full spec table
function M.pkg(repo, opts)
  if not opts then
    return gh .. repo
  end

  local source = opts.source
  local src_base = gh

  if source == 'codeberg' then
    src_base = codeberg
  elseif type(source) == 'string' and source ~= 'gh' and source ~= '' then
    src_base = source:sub(-1) == '/' and source or (source .. '/')
  end

  return vim.tbl_extend('force', {}, opts, {
    source = nil,
    src = src_base .. repo,
  })
end

_G.pkg = M.pkg

---Get plugin names from vim.pack.get()
function M.get_installed_plugins()
  local plugins = {}
  local pack = vim.pack.get()

  for _, plugin in ipairs(pack) do
    if plugin.spec and plugin.spec.name then
      table.insert(plugins, plugin.spec.name)
    end
  end

  return plugins
end

-- Completion function
function M.pack_delete_complete(arglead)
  local matches = {}

  for _, plugin in ipairs(vim.pack.get()) do
    local name = plugin.spec and plugin.spec.name

    if name and vim.startswith(name:lower(), arglead:lower()) then
      table.insert(matches, name)
    end
  end

  return matches
end

---Get all installed plugin repo paths (owner/name) from vim.pack
---@return string[] repos List of owner/name strings
function M.get_plugin_repos()
  local packages = vim.pack.get()
  local repos = {}

  for _, pkg in ipairs(packages) do
    if pkg.spec and pkg.spec.src then
      local src = pkg.spec.src
      -- Extract owner/name from various URL formats
      local repo = src
        :gsub('%.git$', '') -- Remove .git suffix
        :gsub('^https?://[^/]+/', '') -- Remove https://host/
        :gsub('^git@[^:]+:', '') -- Remove git@host:

      if repo:match '^[^/]+/[^/]+$' then
        table.insert(repos, repo)
      end
    end
  end

  return repos
end

---Load a plugin after its dependencies are ready
---@param deps string[]  Dependency module names to require first
---@param plugin string  Plugin module to require after deps
---@param setup? table|fun(mod: any) Setup config table or module setup function
---@param callback? fun()  Optional callback after setup completes
function M.load_after(deps, plugin, setup, callback)
  local opts = { timeout_ms = 10000, interval_ms = 50 }
  local start = vim.uv.hrtime()

  local function try_load()
    for _, dep in ipairs(deps) do
      local ok = pcall(require, dep)
      if not ok then
        local elapsed = (vim.uv.hrtime() - start) / 1e6
        if elapsed > opts.timeout_ms then
          vim.notify("load_after: timeout waiting for '" .. dep .. "'", vim.log.levels.ERROR)
          return
        end
        vim.defer_fn(try_load, opts.interval_ms)
        return
      end
    end

    local ok, mod = pcall(require, plugin)
    if not ok then
      vim.notify("load_after: failed to load '" .. plugin .. "': " .. mod, vim.log.levels.ERROR)
      return
    end

    if setup then
      if type(setup) == 'function' then
        setup(mod)
      else
        mod.setup(setup)
      end
    end

    -- Run callback after successful setup
    if callback then
      callback()
    end

    return mod
  end

  try_load()
end

---Create a loader that runs setup only once.
---@param name string
---@param loader fun()
---@return fun(): boolean
function M.load_once(name, loader)
  local loaded = false

  return function()
    if loaded then
      return true
    end

    local ok, err = pcall(loader)
    if not ok then
      vim.notify('Failed to load ' .. name .. ': ' .. err, vim.log.levels.ERROR)
      return false
    end

    loaded = true
    return true
  end
end

--- Opens a virtual window with the content of a fold with syntax highlight
function M.peek_fold()
  local lnum = vim.fn.line '.'

  -- Check if we're on a closed fold
  if vim.fn.foldclosed(lnum) == -1 then
    vim.notify('Not on a closed fold', vim.log.levels.INFO)
    return
  end

  local start_lnum = vim.fn.foldclosed(lnum)
  local end_lnum = vim.fn.foldclosedend(lnum)

  local lines = vim.fn.getline(start_lnum, end_lnum)
  if type(lines) == 'string' then
    lines = { lines }
  end

  local ft = vim.bo.filetype -- use current buffer's filetype

  local _, winid = vim.lsp.util.open_floating_preview(lines, ft, {
    border = 'rounded',
    focusable = true,
  })

  vim.api.nvim_set_current_win(winid)
end

return M
