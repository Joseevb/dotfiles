local map = vim.keymap.set

map("n", "<leader>e", "<cmd>Oil --float<CR>", { desc = "Open Oil" })
map("n", "<leader>ss", "<cmd>FzfLua<CR>", { desc = "Open FzfLua" })
map("n", "<leader>sw", "<cmd>FzfLua grep_cword<CR>", { desc = "Search word" })
map("n", "<leader>sW", "<cmd>FzfLua grep_cWORD<CR>", { desc = "Search word under cursor" })
map("n", "<leader>sf", "<cmd>FzfLua files<CR>", { desc = "Search files" })
map("n", "<leader>sb", "<cmd>FzfLua buffers<CR>", { desc = "Search buffers" })
map("n", "<leader>sz", "<cmd>FzfLua zoxide<CR>", { desc = "Search buffers" })
map("x", "<C-p>", [["_dP]], { desc = "Paste without overwriting clipboard" })
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down in visual mode" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up in visual mode" })
map("n", "gt", "]t", { noremap = true, silent = true, desc = "Next tag" })
map("n", "gT", "[t", { noremap = true, silent = true, desc = "Previous tag" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Search next and center" })
map("n", "N", "Nzzzv", { desc = "Search previous and center" })
map("v", ">", ">gv", { desc = "Indent selected block" })
map("v", "<", "<gv", { desc = "Unindent selected block" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })
map("n", "<C-c>", "<Esc>:noh<CR>", { desc = "Escape key alternative", silent = true })
map("n", "<leader>sa", "ggVG", { desc = "Select all text" })
map("n", "<leader>bq", ":bdelete<CR>", { desc = "Delete buffer" })

map("n", "<leader>ff", function()
	require("conform").format({ lsp_format = "fallback" })
end, { desc = "LSP format buffer" })

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

	local _, winid = vim.lsp.util.open_floating_preview(lines, "lua", {
		border = "rounded",
		focusable = true,
	})

	vim.api.nvim_set_current_win(winid)
end

map("n", "zp", _G.peek_fold, { desc = "Preview fold" })
