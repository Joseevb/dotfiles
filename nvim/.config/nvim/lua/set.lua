vim.g.mapleader = ' '
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.signcolumn = 'yes'
vim.o.autoindent = true
vim.o.swapfile = false
vim.o.undofile = true
vim.o.incsearch = true
vim.o.winborder = 'rounded'
vim.o.scrolloff = 8
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.mouse = 'a'
vim.o.wrap = true
vim.o.linebreak = true
vim.o.showbreak = '↪ '
vim.o.showtabline = 1

vim.o.foldmethod = 'expr'
-- Use LSP folding if available, fall back to Treesitter
-- vim.o.foldexpr = 'vim.lsp.foldexpr()' -- LSP folding (set per-buffer after LSP attaches)
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- Treesitter folds (better than expr)
vim.o.foldtext = '' -- Use Neovim's default fold text behavior
vim.o.foldlevel = 99 -- Start unfolded
vim.o.foldlevelstart = 99
vim.o.foldnestmax = 4
vim.o.foldminlines = 1

-- Fill char for folds
vim.opt.fillchars:append { fold = ' ', foldopen = '▾', foldclose = '▸', foldsep = '│' }
