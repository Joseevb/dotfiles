local map = vim.keymap.set
local fn = require 'functions'

local ensure_loaded = fn.load_once('plugins.ai.opencode', function()
	vim.pack.add { pkg 'nickjvandyke/opencode.nvim' }

	vim.o.autoread = true
	vim.g.opencode_opts = {
		server = {
			start = function()
				vim.cmd.OpenCodeTerminal()
			end,
		},
	}

	require 'opencode'
end)

map({ 'n' }, '<leader>aa', function()
	if not ensure_loaded() then
		return
	end

	vim.cmd.OpenCodeTerminal()
end, { desc = 'Toggle OpenCode' })

map({ 'n', 'x' }, '<leader>as', function()
	if not ensure_loaded() then
		return
	end

	require 'opencode'.select()
end, { desc = 'Select OpenCode Prompt' })

map({ 'n', 'x' }, '<leader>ap', function()
	if not ensure_loaded() then
		return
	end

	require 'opencode'.ask('@this: ', { submit = true })
end, { desc = 'Send message to OpenCode' })

map({ 'n', 'x' }, '<leader>ac', function()
	if not ensure_loaded() then
		return
	end

	require 'opencode'.ask '@this: '
end, { desc = 'Send Range to OpenCode with prompt' })
