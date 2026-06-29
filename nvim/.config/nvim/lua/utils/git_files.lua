local M = {}

local pick = require 'mini.pick'

function M.git_root()
	local result = vim.fn.systemlist { 'git', 'rev-parse', '--show-toplevel' }
	if vim.v.shell_error ~= 0 or not result[1] or result[1] == '' then
		vim.notify('Not in a git repo', vim.log.levels.WARN)
		return nil
	end

	return result[1]
end

function M.pick()
	local root = M.git_root()
	if not root then
		return
	end

	local files =
			vim.fn.systemlist { 'git', '-C', root, 'diff', '--name-only', '--diff-filter=M' }

	if vim.v.shell_error ~= 0 then
		vim.notify('Git diff failed', vim.log.levels.WARN)
		return
	end

	if vim.tbl_isempty(files) then
		vim.notify('No modified files', vim.log.levels.INFO)
		return
	end

	local items = vim.tbl_map(function(rel_path)
		return {
			text = rel_path,
			path = vim.fs.joinpath(root, rel_path),
		}
	end, files)

	pick.start {
		source = {
			name = 'Git modified files',
			items = items,
			choose = function(item)
				local path = item.path

				MiniPick.stop()

				vim.schedule(function()
					local buf = vim.fn.bufadd(path)
					vim.fn.bufload(buf)
					vim.api.nvim_set_current_buf(buf)
				end)
			end,
		},
	}
end

return M
