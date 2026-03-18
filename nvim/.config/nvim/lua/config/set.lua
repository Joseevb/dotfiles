vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.signcolumn = "yes"
vim.o.autoindent = true
vim.o.swapfile = false
vim.o.undofile = true
vim.o.incsearch = true
vim.o.winborder = "rounded"
vim.o.scrolloff = 8
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = "a"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "
vim.o.showtabline = 1
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldmethod = "expr"
vim.o.winblend = 0

-- vim.o.foldtext = "v:lua.custom_fold_text()"
-- function _G.custom_fold_text()
-- 	local line = vim.fn.getline(vim.v.foldstart)
-- 	local num_lines = vim.v.foldend - vim.v.foldstart + 1
--
-- 	-- Detect if fold starts with import
-- 	if line:match("^%s*import") or line:match("^%s*from") then
-- 		return " Imports … [" .. num_lines .. " lines]"
-- 	end
--
-- 	return string.format(" %s … [%d lines]", line:gsub("^%s*", ""), num_lines)
-- end
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.g.mapleader = " "

vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "🔵", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "🚫", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
