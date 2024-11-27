-- Set leader key
vim.g.mapleader = " "

-- General Mappings
vim.keymap.set("n", "<leader>e", function()
	vim.cmd({ cmd = "Oil", args = { "--float" } })
end, { desc = "Open Oil file explorer" })

vim.keymap.set("n", "<C-c>", vim.cmd.Esc, { desc = "Escape key alternative" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down in visual mode" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up in visual mode" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Search next and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Search previous and center" })

-- Clipboard Mappings
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
vim.keymap.set("n", "<C-p>", [["+p]], { desc = "Paste from system clipboard" })
vim.keymap.set("v", "<C-p>", [["+p]], { desc = "Paste from system clipboard in visual mode" })

-- Find and Replace
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace word under cursor globally" }
)

-- Formatting and Indentation
vim.keymap.set("v", ">", ">gv", { desc = "Indent selected block" })
vim.keymap.set("v", "<", "<gv", { desc = "Unindent selected block" })

-- Select All
vim.keymap.set("n", "<leader>sa", "ggVG", { desc = "Select all text" })

-- Plugin-Specific Mappings
-- Live Server
vim.keymap.set("n", "<leader>ls", ":term live-server .<CR>", { desc = "Start live server" })

-- Dadbod SQL
vim.keymap.set("n", "<leader>od", vim.cmd.DBUI, { desc = "Open Dadbod UI" })

-- LSP Mappings
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { noremap = true, silent = true, desc = "Code actions" })
