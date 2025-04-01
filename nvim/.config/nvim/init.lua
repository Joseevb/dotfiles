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

require("jose")
