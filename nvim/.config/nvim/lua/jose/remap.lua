-- ================================
-- Leader Key
-- ================================
vim.g.mapleader = " " -- Set leader key to space

-- ================================
-- General Mappings
-- ================================

vim.keymap.set("n", "<C-c>", "<Esc>:noh<CR>", { desc = "Escape key alternative" })

-- Line Movement in Visual Mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down in visual mode" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up in visual mode" })

-- Centering View on Navigation
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Search next and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Search previous and center" })

-- ================================
-- Clipboard Mappings
-- ================================
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank entire line to system clipboard" })
vim.keymap.set("n", "<C-p>", [["+p]], { desc = "Paste from system clipboard" })
vim.keymap.set("v", "<C-p>", [["+p]], { desc = "Paste from system clipboard in visual mode" })

-- ================================
-- Search and Replace
-- ================================
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace word under cursor globally" }
)

-- ================================
-- Formatting and Indentation
-- ================================
vim.keymap.set("v", ">", ">gv", { desc = "Indent selected block" })
vim.keymap.set("v", "<", "<gv", { desc = "Unindent selected block" })

-- ================================
-- Buffer Management
-- ================================
-- vim.keymap.set("n", "<leader>bn", vim.cmd.bnext, { desc = "Next buffer" })
-- vim.keymap.set("n", "<leader>bp", vim.cmd.bprev, { desc = "Previous buffer" })
-- -- vim.keymap.set("n", "<leader>bd", vim.cmd.bdelete, { desc = "Delete current buffer" })
-- vim.keymap.set("n", "<leader>bl", vim.cmd.ls, { desc = "List all buffers" })
-- -- Function to go to a specific buffer by number
-- local function goto_buffer()
-- 	vim.ui.input({ prompt = "Enter buffer number: " }, function(input)
-- 		if input then
-- 			local buffer_number = tonumber(input)
-- 			if buffer_number and vim.fn.bufexists(buffer_number) == 1 then
-- 				vim.cmd("buffer " .. buffer_number)
-- 			else
-- 				vim.notify("Invalid buffer number: " .. input, vim.log.levels.ERROR)
-- 			end
-- 		end
-- 	end)
-- end
--
-- -- Keymap to prompt for buffer number and switch
-- vim.keymap.set("n", "<leader>bb", goto_buffer, { desc = "Switch to buffer by number" })

-- ================================
-- Selection
-- ================================
vim.keymap.set("n", "<leader>sa", "ggVG", { desc = "Select all text" })

-- ================================
-- Plugin-Specific Mappings
-- ================================
-- Live Server
-- vim.keymap.set("n", "<leader>ls", ":term live-server .<CR>", { desc = "Start live server" })

-- Dadbod SQL
vim.keymap.set("n", "<leader>od", vim.cmd.DBUI, { desc = "Open Dadbod UI" })

-- ================================
-- LSP Mappings
-- ================================
vim.keymap.set(
	"n",
	"<leader>ca",
	vim.lsp.buf.code_action,
	{ noremap = true, silent = true, desc = "Trigger code actions" }
)

-- ================================
-- Terminal Mappings
-- ================================
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })

-- ================================
-- Window Management
-- ================================
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>wh", ":split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "Switch to the next window" })
vim.keymap.set("n", "<leader>wd", "<C-w>c", { desc = "Close current window" })

-- ================================
-- Quickfix Navigation
-- ================================
-- vim.keymap.set("n", "<leader>cn", ":cnext<CR>", { desc = "Next item in quickfix" })
-- vim.keymap.set("n", "<leader>cp", ":cprev<CR>", { desc = "Previous item in quickfix" })

-- ================================
-- Toggle Relative Numbers
-- ================================
vim.keymap.set("n", "<leader>tr", function()
	vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative numbers" })

-- ================================
-- Command history
-- ================================
-- Disable `q:` command history window
vim.keymap.set("n", "q:", "<Nop>", { desc = "Disable command history window" })

-- ================================
-- Neotree
-- ================================
vim.keymap.set("n", "<leader>ot", ":Neotree reveal<CR>", { desc = "Toggle Neotree" })
