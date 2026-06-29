local fn = require 'functions'
local projects = require 'utils.projects'
local scratch = require 'utils.scratch'

projects.setup()

vim.api.nvim_create_user_command('PackUpdate', function()
	vim.pack.update()
end, { desc = 'Update all plugins' })

-- The command
vim.api.nvim_create_user_command('PackDelete', function(opts)
	local plugin = opts.args
	if plugin == '' then
		vim.notify('Usage: PackDelete <plugin-name>', vim.log.levels.ERROR)
		return
	end

	vim.pack.del { plugin }
	vim.notify('Deleted: ' .. plugin, vim.log.levels.INFO)
end, {
	nargs = 1,
	complete = fn.pack_delete_complete,
	desc = 'Delete an installed plugin',
})

-- See installed packages

vim.api.nvim_create_user_command('PackGet', function()
	local plugins = fn.get_plugin_repos()
	table.sort(plugins)
	print(table.concat(plugins, '\n'))
end, { desc = 'Prints all the installed plugins' })

-- Open Scratch File
vim.api.nvim_create_user_command('Scratch', function()
	scratch.open_scratch()
end, { desc = 'Opens a Scratch File of the specified filetype' })

-- Open OpenCode in a terminal
vim.api.nvim_create_user_command('OpenCodeTerminal', function()
	local name = 'opencode://terminal'
	local width = 70
	local bufnr = vim.g.opencode_terminal_bufnr

	if type(bufnr) == 'number' and vim.api.nvim_buf_is_valid(bufnr) then
		local job_id = vim.b[bufnr].terminal_job_id
		local is_running = type(job_id) == 'number' and vim.fn.jobwait({ job_id }, 0)[1] == -1

		if is_running then
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_buf(win) == bufnr then
					vim.api.nvim_win_close(win, false)
					return
				end
			end

			vim.cmd('rightbelow vertical ' .. width .. 'split')
			vim.api.nvim_win_set_buf(0, bufnr)
			vim.cmd.startinsert()
			return
		end

		vim.api.nvim_buf_delete(bufnr, { force = true })
		vim.g.opencode_terminal_bufnr = nil
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		bufnr = vim.api.nvim_win_get_buf(win)

		if vim.api.nvim_buf_get_name(bufnr) == name then
			vim.api.nvim_win_close(win, false)
			return
		end
	end

	for _, listed_bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(listed_bufnr) == name then
			vim.cmd('rightbelow vertical ' .. width .. 'split')
			vim.api.nvim_win_set_buf(0, listed_bufnr)
			vim.cmd.startinsert()
			return
		end
	end

	vim.cmd('rightbelow vertical ' .. width .. 'new')
	vim.g.opencode_terminal_bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_name(0, name)

	vim.fn.jobstart({ 'opencode', '--port' }, {
		term = true,
		env = {
			STARSHIP_DISABLE = '1',
		},
	})

	vim.bo.buflisted = false
	vim.bo.bufhidden = 'hide'

	vim.cmd.startinsert()
end, {})

vim.api.nvim_create_user_command('Projects', function()
  projects.pick()
end, { desc = 'Pick a recent project' })
