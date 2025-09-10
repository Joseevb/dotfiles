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
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = false
function _G.custom_fold_text()
	local line = vim.fn.getline(vim.v.foldstart)
	local num_lines = vim.v.foldend - vim.v.foldstart + 1
	return string.format("   %s … [%d lines]", line:gsub("^%s*", ""), num_lines)
end

vim.o.foldtext = "v:lua.custom_fold_text()"

vim.g.mapleader = " "

vim.pack.add({
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/benomahony/oil-git.nvim" },
	{ src = "https://github.com/JezerM/oil-lsp-diagnostics.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/nvim-mini/mini.completion" },
	{ src = "https://github.com/nvim-mini/mini.icons" },
	{ src = "https://github.com/nvim-mini/mini.snippets" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/supermaven-inc/supermaven-nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/JavaHello/spring-boot.nvim" },
})

require("fzf-lua").setup({
	"fzf-tmux",
	"hide",
})

require("mini.completion").setup({
	window = {
		info = {
			border = "rounded",
		},
	},
})

require("mason").setup({})
require("mason-lspconfig").setup({})

local detail = false
require("oil").setup({
	default_file_explorer = true,
	delete_to_trash = true,
	columns = {
		"icon",
		"size",
	},
	watch_for_changes = false,
	view_options = {
		show_hidden = true,
	},
	keymaps = {
		["gd"] = {
			desc = "Toggle file detail view",
			callback = function()
				detail = not detail
				if detail then
					require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
				else
					require("oil").set_columns({ "icon" })
				end
			end,
		},
	},
})

require("oil-git").setup({})
require("oil-lsp-diagnostics").setup({})
require("gitsigns").setup({})
require("mini.icons").setup({})

local gen_loader = require("mini.snippets").gen_loader
require("mini.snippets").setup({
	snippets = {
		gen_loader.from_lang(),
	},
})

require("supermaven-nvim").setup({
	keymaps = {
		accept_suggestion = "<Tab>",
		clear_suggestion = "<C-]>",
		accept_word = "<C-j>",
	},
	ignore_filetypes = { cpp = true }, -- or { "cpp", }
	color = {
		suggestion_color = "#555555", -- A darker gray instead of white (#ffffff)
		cterm = 244,
	},
	log_level = "off", -- set to "off" to disable logging completely
	disable_inline_completion = false, -- disables inline completion for use with cmp
	disable_keymaps = false, -- disables built in keymaps for more manual control
	condition = function()
		return false
	end,
})

require("which-key").setup({
	preset = "helix",
})

require("nvim-treesitter.configs").setup({
	ensure_installed = "all",
	sync_install = true,
	auto_install = true,
	ignore_install = {
		"ipkg",
	},
	modules = {},
	highlight = {
		enable = true,
	},
})

require("nvim-ts-autotag").setup({})
local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		c = { "clang-format" },
		cpp = { "clang-format" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		yaml = { "prettierd", "prettier", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		xml = { "xmlformatter" },
		lua = { "stylua" },
		python = { "isort", "black" },
		php = { "prettier", "pretty-php" },
		java = { "google-java-format" },
	},
	formatters = {
		["google-java-format-aosp"] = {
			command = "google-java-format",
			args = { "--aosp", "-" },
		},
	},
	format_after_save = {
		lsp_fallback = true,
		async = true,
		timeout_ms = 1000,
	},
})

require("spring_boot").setup({})

local lsp_configurations = {
	lua_ls = {
		settings = {
			Lua = {
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
				},
			},
		},
	},
	jdtls = {
		cmd = {
			"jdtls",
			"--jvm-arg=" .. string.format("-javaagent:%s", vim.fn.expand("$MASON/share/jdtls/lombok.jar")),
		},
		init_options = {
			bundles = require("spring_boot").java_extensions(),
		},
	},
}

-- Custom configuration for LSPs
for server, config in pairs(lsp_configurations) do
	vim.lsp.config(server, config)
end

local map = vim.keymap.set

map("n", "<leader>e", "<cmd>Oil --float<CR>", { desc = "Open Oil" })
map("n", "<leader>ss", "<cmd>FzfLua<CR>", { desc = "Open FzfLua" })
map("n", "<leader>sw", "<cmd>FzfLua grep_cword<CR>", { desc = "Search word" })
map("n", "<leader>sf", "<cmd>FzfLua files<CR>", { desc = "Search files" })
map("n", "<leader>sb", "<cmd>FzfLua buffers<CR>", { desc = "Search buffers" })
map("n", "<leader>sz", "<cmd>FzfLua zoxide<CR>", { desc = "Search buffers" })
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down in visual mode" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up in visual mode" })
map("n", "gt", "]t", { noremap = true, silent = true, desc = "Next tag" })
map("n", "gT", "[t", { noremap = true, silent = true, desc = "Previous tag" })

map("n", "<leader>ff", function()
	conform.format({ lsp_format = "fallback" })
end, { desc = "LSP format buffer" })

map("n", "]t", function()
	local n = vim.v.count1 -- number prefix, defaults to 1
	vim.cmd(n .. "tabnext")
end, { noremap = true, silent = true, desc = "Next tab (with count)" })

map("n", "[t", function()
	local n = vim.v.count1
	vim.cmd(n .. "tabprevious")
end, { noremap = true, silent = true, desc = "Previous tab (with count)" })

function _G.peek_fold()
	local lnum = vim.fn.line(".")

	-- Check if we're on a closed fold
	if vim.fn.foldclosed(lnum) == -1 then
		vim.notify("Not on a closed fold", vim.log.levels.INFO)
		return
	end

	local start_lnum = vim.fn.foldclosed(lnum)
	local end_lnum = vim.fn.foldclosedend(lnum)

	---@type string[]
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

vim.cmd.colorscheme("catppuccin")
