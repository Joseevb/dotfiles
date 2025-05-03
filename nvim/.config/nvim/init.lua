-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Create an augroup for highlight_yank
local highlight_yank_group = vim.api.nvim_create_augroup("highlight_yank", {})

-- Define the autocmd within the augroup
vim.api.nvim_create_autocmd("TextYankPost", {
	group = highlight_yank_group,
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

-- Create or retrieve the 'open_folds' augroup
-- local open_folds_group = vim.api.nvim_create_augroup("open_folds", { clear = true })
--
-- -- Define the autocommand within the 'open_folds' group
-- vim.api.nvim_create_autocmd({ "BufReadPost", "FileReadPost" }, {
--     group = open_folds_group,
--     pattern = "*",
--     command = "normal! zR",
-- })

-- Create an augroup for prettier
-- local prettier_group = vim.api.nvim_create_augroup('Prettier', {})

-- Define the autocmd within the augroup
-- vim.api.nvim_create_autocmd('BufWritePost', {
--   group = prettier_group,
--   pattern = '*',
--   command = 'Prettier'
-- })

-- Enable auto reloading of files changed outside of Neovim
vim.opt.autoread = true
-- Check for changes in files when gaining focus or switching buffers
vim.cmd([[
  autocmd FocusGained,BufEnter * checktime
]])

-- Path to the file in your Neovim config directory
local config_dir = vim.fn.stdpath("config")
local file_path = config_dir .. "/colorscheme"

-- Store the last modification time we've seen
local last_mod_time = 0

-- Function that checks if the file has changed and updates the colorscheme
local function update_colorscheme()
	local stat = vim.loop.fs_stat(file_path)
	if stat and stat.mtime.sec > last_mod_time then
		last_mod_time = stat.mtime.sec -- update our stored mod time
		local file = io.open(file_path, "r")
		if file then
			local theme = file:read("*l")
			file:close()
			if theme and #theme > 0 then
				-- Change the colorscheme dynamically
				vim.cmd("colorscheme " .. theme)
				print("Colorscheme updated to " .. theme)
			end
		end
	end
end

-- Create a timer that calls update_colorscheme every 2000 milliseconds (2 seconds)
local timer = vim.loop.new_timer()
timer:start(0, 2000, vim.schedule_wrap(update_colorscheme))

require("jose")
