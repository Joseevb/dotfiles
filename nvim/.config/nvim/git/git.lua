local map = vim.keymap.set
local fn = require 'functions'

local function git(args)
	local result = vim.system(vim.list_extend({ 'git' }, args), { text = true }):wait()
	if result.code ~= 0 then
		return nil
	end

	return vim.trim(result.stdout)
end

local function branch_has_pr()
	if vim.fn.executable 'gh' ~= 1 then
		return false
	end

	local result = vim.system({ 'gh', 'pr', 'view', '--json', 'number' }, { text = true }):wait()
	return result.code == 0
end

local function origin_default_branch()
	local ref = git { 'symbolic-ref', '--quiet', '--short', 'refs/remotes/origin/HEAD' }
	if ref then
		return ref
	end

	local remote = git { 'remote', 'show', 'origin' }
	if not remote then
		return nil
	end

	local branch = remote:match 'HEAD branch:%s*(%S+)'
	if branch then
		return 'origin/' .. branch
	end
end

local function open_default_branch_diff()
	local base = origin_default_branch()
	if not base then
		vim.notify('No origin default branch found for Diffview', vim.log.levels.WARN)
		return
	end

	vim.cmd('DiffviewOpen ' .. base .. '...HEAD')
end

local ensure_gitsigns = fn.load_once('plugins.git.gitsigns', function()
	vim.pack.add {
		pkg 'lewis6991/gitsigns.nvim',
	}

	require 'gitsigns'.setup {
		watch_gitdir = {
			follow_files = true,
		},
	}
end)

-- Gitsigns is lightweight and should be available automatically.
-- The heavier git UI plugins below stay lazy-loaded.
ensure_gitsigns()

local ensure_loaded = fn.load_once('plugins.git.git', function()
	ensure_gitsigns()

	vim.pack.add {
		pkg 'sindrets/diffview.nvim',
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
				local cmd = 'DiffviewOpen ' .. commit.hash .. '^!'
				vim.notify(cmd)
				vim.cmd(cmd)
			end,

			on_select_range_commit = function(from, to)
				local cmd = 'DiffviewOpen ' .. from.hash .. '~1..' .. to.hash
				vim.notify(cmd)
				vim.cmd(cmd)
			end,
		},
	}

	require 'review_mode'.setup {
		gitsigns = {
			enabled = true,
		},
	}

	vim.schedule(function()
		if branch_has_pr() then
			vim.cmd.ReviewMode()
		end
	end)
end)

map('n', '<leader>gl', function()
	if not ensure_loaded() then
		return
	end

	require 'gitgraph'.draw({}, {
		all = true,
		max_count = 5000,
	})
end, {
	desc = 'Open Git Graph',
})

map('n', '<leader>gm', function()
	if not ensure_loaded() then
		return
	end

	vim.cmd.ReviewMode()
end, {
	desc = 'Review mode',
})

map('n', '<leader>gN', function()
	if not ensure_loaded() then
		return
	end

	vim.cmd.ReviewModeStop()
end, {
	desc = 'Review mode stop',
})

map('n', '<leader>gd', function()
	if not ensure_loaded() then
		return
	end

	vim.cmd.DeltaView()
end, {
	desc = 'See git diff',
})

map('n', '<leader>gD', function()
	if not ensure_loaded() then
		return
	end

	open_default_branch_diff()
end, {
	desc = 'Diffview against default branch',
})

map('n', '<leader>gf', function()
	if not ensure_loaded() then
		return
	end

	vim.cmd.DeltaMenu()
end, {
	desc = 'See modified files',
})

map('n', '<leader>gQ', function()
	if not ensure_gitsigns() then
		return
	end

	require 'gitsigns'.setqflist 'all'
end, {
	desc = 'List gitsigns hunks',
})
