-- sets
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

vim.o.foldtext = "v:lua.custom_fold_text()"
function _G.custom_fold_text()
	local line = vim.fn.getline(vim.v.foldstart)
	local num_lines = vim.v.foldend - vim.v.foldstart + 1

	-- Detect if fold starts with import
	if line:match("^%s*import") or line:match("^%s*from") then
		return " Imports … [" .. num_lines .. " lines]"
	end

	return string.format(" %s … [%d lines]", line:gsub("^%s*", ""), num_lines)
end
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.g.mapleader = " "

-- plugins
vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.completion" },
	{ src = "https://github.com/nvim-mini/mini.icons" },
	{ src = "https://github.com/nvim-mini/mini.snippets" },
	{ src = "https://github.com/supermaven-inc/supermaven-nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/JavaHello/spring-boot.nvim" },
	{ src = "https://github.com/nvim-mini/mini.tabline" },
	{ src = "https://github.com/nvim-mini/mini-git" },
	{ src = "https://github.com/nvim-mini/mini.diff" },
	{ src = "https://github.com/nvim-mini/mini.statusline" },
	{ src = "https://codeberg.org/mfussenegger/nvim-dap.git" },
})

require("mini.git").setup({})
require("mini.diff").setup({})
require("mini.statusline").setup({})

require("mini.completion").setup({
	window = {
		info = {
			border = "rounded",
		},
	},
})

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
	ensure_installed = {
		"c",
		"cpp",
		"lua",
		"python",
		"rust",
		"tsx",
		"typescript",
		"javascript",
		"css",
		"html",
		"json",
		"yaml",
		"markdown",
		"xml",
		"java",
	},
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

require("mini.tabline").setup({})

-- lsp
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

-- keymaps

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
	conform.format({ lsp_format = "fallback" })
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

-- autocommands
vim.api.nvim_set_hl(0, "YankHighlight", {
	background = "#6c7086",
	bold = true,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({
			timeout = 200,
			higroup = "YankHighlight",
		})
	end,
})

function _G.pack_update_command(args)
	if next(args.fargs) ~= nil then
		local plugin_names = args.fargs
		vim.notify("Updating specific packs: " .. table.concat(plugin_names, ",") .. "...", vim.log.levels.INFO)
		vim.pack.update(plugin_names)
	else
		vim.notify("Updating all packs...", vim.log.levels.INFO)
		vim.pack.update()
	end

	vim.notify("Pack update process initiated!", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("PackUpdate", _G.pack_update_command, {
	nargs = "*",
	desc = "Update installed packs (plugins/dependencies)",
	complete = "customlist,v:lua.get_available_packs",
})

function _G.get_available_packs(ArgLead)
	local all_packs_data = vim.pack.get()
	local all_pack_names = {}
	for _, pack_info in ipairs(all_packs_data) do
		if pack_info.spec and pack_info.spec.name then
			table.insert(all_pack_names, pack_info.spec.name)
		end
	end

	local suggestions = {}
	for _, pack_name in ipairs(all_pack_names) do
		if pack_name:sub(1, #ArgLead) == ArgLead then
			table.insert(suggestions, pack_name)
		end
	end
	return suggestions
end

local function load_plugins()
	local plugins = {}

	-- Get the directory of the current init.lua file
	local config_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
	local plugins_path = config_path .. "/lua/plugins"

	-- Check if directory exists
	local stat = vim.loop.fs_stat(plugins_path)
	if not stat or stat.type ~= "directory" then
		print("Plugins directory doesn't exist or isn't a directory")
		return plugins
	end

	-- Use vim.fs.dir to iterate through the directory
	for name, file_type in vim.fs.dir(plugins_path) do
		if file_type == "file" and name:match("%.lua$") and name ~= "init.lua" then
			local filename = name:match("(.+)%.lua$")

			-- Add the plugins directory to package.path if needed
			local plugins_lua_path = config_path .. "/lua/?.lua"
			if not package.path:find(plugins_lua_path, 1, true) then
				package.path = package.path .. ";" .. plugins_lua_path
			end

			local ok, plugin_config = pcall(require, "plugins." .. filename)

			if ok and type(plugin_config) == "table" then
				if plugin_config[1] ~= nil then
					vim.list_extend(plugins, plugin_config)
				else
					table.insert(plugins, plugin_config)
				end
			elseif not ok then
				print("Error requiring " .. filename .. ": " .. tostring(plugin_config))
			end
		end
	end

	return plugins
end

local plugins = load_plugins()

for _, plugin in ipairs(plugins) do
	vim.pack.add({ plugin.src })
	vim.schedule(function()
		if plugin.setup_name then
			local ok, module = pcall(require, plugin.setup_name)
			if ok then
				module.setup(plugin.opts)
			else
				print("Failed to require " .. plugin.setup_name)
			end
		end
	end)
end

-- colorscheme
vim.cmd.colorscheme("catppuccin")
