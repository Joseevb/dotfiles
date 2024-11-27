vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smarttab = true -- Insert appropriate number of spaces
vim.opt.smartindent = true -- Auto-indent new lines
vim.opt.autoindent = true -- Retain the previous line's indentation

vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case-sensitive if the search query contains uppercase

vim.opt.termguicolors = true

vim.opt.scrolloff = 8 -- Minimum lines above/below the cursor
vim.opt.sidescrolloff = 8 -- Minimum columns to the left/right of the cursor
vim.opt.signcolumn = "yes" -- Always show sign column to avoid shifting
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.o.autowriteall = true

vim.opt.foldmethod = "syntax" -- Syntax-based folding
vim.opt.foldlevel = 99 -- Open all folds by default

vim.opt.cursorline = true

vim.opt.wrap = true
vim.opt.linebreak = true -- Break at words, not characters
vim.opt.showbreak = "↪ " -- Indicate wrapped lines

vim.opt.list = true
vim.opt.listchars = { tab = "»·", trail = "·", extends = "→", precedes = "←" }
