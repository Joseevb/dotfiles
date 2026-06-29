local map = vim.keymap.set
local fn = require 'functions'

local ensure_loaded = fn.load_once('plugins.git.git', function()
	vim.pack.add {
		pkg 'sindrets/diffview.nvim',
		pkg 'lewis6991/gitsigns.nvim',
		pkg 'isakbm/gitgraph.nvim',
		pkg 'adrianmross/review-mode.nvim',
		pkg 'kokusenz/deltaview.nvim',
	}

	require 'gitgraph'.setup {
		git_cmd = 'git',
		symbols = {
			merge_commit = 'M',
			commit = '*',
		},
		format = {
			timestamp = '%H:%M:%S %d-%m-%Y',
			fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
		},
		hooks = {
			on_select_commit = function(commit)
				vim.notify('DiffviewOpen ' .. commit.hash .. '^!')
				vim.cmd('DiffviewOpen ' .. commit.hash .. '^!')
			end,
			on_select_range_commit = function(from, to)
				vim.notify('DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
				vim.cmd('DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
			end,
		},
	}

	require 'review_mode'.setup {
		gitsigns = {
			enabled = true,
		},
	}
end)

map({ 'n' }, '<leader>gl', function()
	if not ensure_loaded() then
		return
	end

	require 'gitgraph'.draw({}, { all = true, max_count = 5000 })
end, { desc = 'Open Git Graph' })

map({ 'n' }, '<leader>rm', function()
	if not ensure_loaded() then
		return
	end

	vim.cmd.ReviewMode()
end, { desc = 'Review mode' })

map({ 'n' }, '<leader>rN', function()
	if not ensure_loaded() then
		return
	end

	vim.cmd.ReviewModeStop()
end, { desc = 'Review mode stop' })

map({ 'n' }, '<leader>gd', function()
	if not ensure_loaded() then
		return
	end

	vim.cmd.DeltaView()
end, { desc = 'See git diff' })

map({ 'n' }, '<leader>gf', function()
	if not ensure_loaded() then
		return
	end

	vim.cmd.DeltaMenu()
end, { desc = 'See modified files' })
