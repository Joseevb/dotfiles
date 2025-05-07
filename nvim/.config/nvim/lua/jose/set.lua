-- ================================
-- General Settings
-- ================================
vim.opt.nu = true -- Show line number
vim.opt.relativenumber = true -- Relative line numbers for easier movement

vim.opt.cursorline = true --- Get Catppuccin palette

vim.opt.wrap = true -- Wrap long lines
vim.opt.linebreak = true -- Break lines at words, not characters
vim.opt.showbreak = "↪ " -- Indicator for wrapped lines

vim.opt.termguicolors = true -- Enable 24-bit RGB color in the terminal

vim.opt.updatetime = 50 -- Faster updates for plugins like CursorHold events

vim.opt.mouse = "a"

-- ================================
-- Tabs and Indentation
-- ================================
vim.opt.tabstop = 4 -- Number of spaces for a tab
vim.opt.softtabstop = 4 -- Spaces per Tab keypress
vim.opt.shiftwidth = 4 -- Spaces for auto-indent
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smarttab = true -- Automatically insert correct number of spaces
vim.opt.smartindent = true -- Auto-indent new lines
vim.opt.autoindent = true -- Retain previous line's indentation

-- ================================
-- Search Settings
-- ================================
vim.opt.hlsearch = false -- Disable search highlighting
vim.opt.incsearch = true -- Show matches as you type
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case-sensitive if search query contains uppercase

-- ================================
-- Buffer and Tab Management
-- ================================
-- vim.opt.hidden = true -- Allow switching buffers without saving
-- vim.opt.switchbuf = { "usetab", "newtab" } -- Reuse or open new tabs for buffers
-- vim.opt.showtabline = 2 -- Always show the tabline
--
-- vim.opt.sessionoptions:append("buffers") -- Persist buffers across sessions
--
-- -- Tabline customization: Show all open buffers
-- vim.o.tabline = "%!v:lua.Tabline()"
--
-- function _G.Tabline()
-- 	local s = ""
-- 	for i = 1, vim.fn.bufnr("$") do
-- 		if vim.fn.bufexists(i) == 1 and vim.fn.buflisted(i) == 1 then
-- 			local bufname = vim.fn.fnamemodify(vim.fn.bufname(i), ":t")
-- 			local bufnum = vim.fn.bufnr(i)
-- 			if bufname == "" then
-- 				bufname = "[No Name]"
-- 			end
-- 			local is_current = (i == vim.fn.bufnr("%"))
-- 			local hl = is_current and "%#TabLineSel#" or "%#TabLine#"
-- 			s = s .. hl .. " " .. bufnum .. ": " .. bufname .. " "
-- 		end
-- 	end
-- 	return s .. "%#TabLineFill#"
-- end

-- ================================
-- Backup and Undo
-- ================================
vim.opt.swapfile = false -- Disable swap files
vim.opt.backup = false -- Disable backup files
vim.opt.undofile = true -- Enable persistent undo

-- ================================
-- Scrolling and Sign Column
-- ================================
vim.opt.scrolloff = 16 -- Keep 8 lines visible above/below the cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns visible to the left/right
vim.opt.signcolumn = "yes" -- Always show the sign column to avoid shifting

vim.opt.isfname:append("@-@") -- Allow "@" in filenames

-- ================================
-- Folding
-- ================================
-- Will be managed by UFO plugin
-- vim.opt.foldmethod = "expr" -- Use syntax-based folding
-- vim.opt.foldexpr = "v:lua.vim.lsp.foldexpr()"
-- -- Default to treesitter folding
-- vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- -- Prefer LSP folding if client supports it
-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(args)
-- 		local client = vim.lsp.get_client_by_id(args.data.client_id)
-- 		if client and client:supports_method("textDocument/foldingRange") then
-- 			local win = vim.api.nvim_get_current_win()
-- 			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
-- 		end
-- 	end,
-- })

-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- ================================
-- Lists and Special Characters
-- ================================
-- vim.opt.list = true -- Show invisible characters
-- vim.opt.listchars = {
-- 	tab = "»·", -- Tab characters
-- 	trail = "·", -- Trailing spaces
-- 	extends = "→", -- Line too long
-- 	precedes = "←", -- Line continuation on left
-- }

-- ================================
-- Suggested Additions
-- ================================

-- Automatically save changes before switching buffers or exiting
vim.o.autowriteall = true

-- Highlight current search match
vim.opt.hlsearch = true -- Highlight search matches

-- Split window behavior
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below

-- Display ruler and command line
vim.opt.ruler = true -- Show cursor position in the status line
vim.opt.cmdheight = 2 -- More space for displaying messages

-- Key timeout settings for better responsiveness
vim.opt.timeoutlen = 500 -- Time to wait for a mapped sequence (ms)
vim.opt.ttimeoutlen = 10 -- Time to wait for a key code sequence (ms)
