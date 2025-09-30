return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = { "OXY2DEV/markview.nvim" },
	lazy = false,
	opts = {
		-- LazyVim config for treesitter
		indent = { enable = true },
		highlight = { enable = true },
		folds = { enable = true },
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"html",
			"javascript",
			"jsdoc",
			"json",
			"jsonc",
			"lua",
			"luadoc",
			"luap",
			"markdown",
			"markdown_inline",
			"printf",
			"python",
			"query",
			"regex",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"xml",
			"yaml",
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufEnter",
		opts = { mode = "cursor", max_lines = 3 },
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = "VeryLazy",
		opts = {
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				-- LazyVim extention to create buffer-local keymaps
				keys = {
					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
						["]a"] = "@parameter.inner",
					},
					goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
						["[a"] = "@parameter.inner",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[C"] = "@class.outer",
						["[A"] = "@parameter.inner",
					},
				},
			},
		},
		config = function(_, opts)
			local TS = require("nvim-treesitter-textobjects")
			TS.setup(opts)

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("lazyvim_treesitter_textobjects", { clear = true }),
				callback = function(ev)
					---@type table<string, table<string, string>>
					local moves = vim.tbl_get(opts, "move", "keys") or {}

					for method, keymaps in pairs(moves) do
						for key, query in pairs(keymaps) do
							local desc = query:gsub("@", ""):gsub("%..*", "")
							desc = desc:sub(1, 1):upper() .. desc:sub(2)
							desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
							desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
							if not (vim.wo.diff and key:find("[cC]")) then
								vim.keymap.set({ "n", "x", "o" }, key, function()
									require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
								end, {
									buffer = ev.buf,
									desc = desc,
									silent = true,
								})
							end
						end
					end
				end,
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		event = "BufEnter",
		opts = {},
	},
}
