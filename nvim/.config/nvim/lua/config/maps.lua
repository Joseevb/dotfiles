local map = vim.keymap.set

map({ "n", "v", "x" }, "<C-p>", [["_dP]], { desc = "Paste without overwriting clipboard" })

-- sys clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>d", '"+d', { desc = "Delete to system clipboard" })
map({ "n", "v" }, "<leader>D", '"+D', { desc = "Delete line to system clipboard" })
map({ "n", "v" }, "<leader>c", '"+c', { desc = "Cut to system clipboard" })
map({ "n", "v" }, "<leader>C", '"+C', { desc = "Cut line to system clipboard" })

-- line movement
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down in visual mode" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up in visual mode" })

-- navigation
map("n", "gt", "]t", { noremap = true, silent = true, desc = "Next tag" })
map("n", "gT", "[t", { noremap = true, silent = true, desc = "Previous tag" })
map("n", "n", "nzzzv", { desc = "Search next and center" })
map("n", "N", "Nzzzv", { desc = "Search previous and center" })

-- indentation
map("v", ">", ">gv", { desc = "Indent selected block" })
map("v", "<", "<gv", { desc = "Unindent selected block" })

-- selection
map("n", "<leader>sa", "ggVG", { desc = "Select all text" })

-- buff management
map("n", "<C-b>q", ":bdelete<CR>", { desc = "Delete buffer" })
map("n", "!<C-b>q", ":bdelete!<CR>", { desc = "Force delete buffer" })

-- others
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })
map("n", "<C-c>", "<Esc>:noh<CR>", { desc = "Escape key alternative", silent = true })

function _G.peek_fold()
	local lnum = vim.fn.line(".")

	-- Check if we're on a closed fold
	if vim.fn.foldclosed(lnum) == -1 then
		vim.notify("Not on a closed fold", vim.log.levels.INFO)
		return
	end

	local start_lnum = vim.fn.foldclosed(lnum)
	local end_lnum = vim.fn.foldclosedend(lnum)

	local lines = vim.fn.getline(start_lnum, end_lnum)
	if type(lines) == "string" then
		lines = { lines }
	end

	local ft = vim.bo.filetype -- use current buffer's filetype

	local _, winid = vim.lsp.util.open_floating_preview(lines, ft, {
		border = "rounded",
		focusable = true,
	})

	vim.api.nvim_set_current_win(winid)
end

map("n", "zp", peek_fold, { desc = "Preview fold" })
