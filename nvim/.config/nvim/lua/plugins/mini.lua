return {
	{ "nvim-mini/mini.tabline", version = false, opts = {} },
	{ "nvim-mini/mini-git", version = false, main = "mini.git", opts = {} },
	{
		"nvim-mini/mini.statusline",
		version = false,
		opts = {},
		config = function()
			-- Get only the filename (tail of the path)
			local get_filename_only = function()
				local path = vim.api.nvim_buf_get_name(0)
				return vim.fn.fnamemodify(path, ":t") or "[No Name]"
			end

			-- Function to keep the original statusline style
			local custom_active_content = function()
				-- ... all original MiniStatusline.section_* calls ...
				local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
				local git = MiniStatusline.section_git({ trunc_width = 40 })
				local diff = MiniStatusline.section_diff({ trunc_width = 75 })
				local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
				local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
				-- *** The ONLY line that changes from the default content ***
				local filename = get_filename_only()
				-- *********************************************************
				local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
				local location = MiniStatusline.section_location({ trunc_width = 75 })
				local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

				return MiniStatusline.combine_groups({
					{ hl = mode_hl, strings = { mode } },
					{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
					"%<", -- Mark general truncate point
					-- Use the MiniStatuslineFilename highlight group to keep the original style
					{ hl = "MiniStatuslineFilename", strings = { filename } },
					"%=", -- End left alignment
					{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
					{ hl = mode_hl, strings = { search, location } },
				})
			end

			-- Apply the configuration
			require("mini.statusline").setup({
				content = {
					active = custom_active_content,
				},
			})
		end,
	},
	{
		"nvim-mini/mini.snippets",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local gen_loader = require("mini.snippets").gen_loader
			require("mini.snippets").setup({
				snippets = {
					gen_loader.from_lang(),
				},
			})
		end,
	},
	{
		"nvim-mini/mini.completion",
		enabled = false,
		dependencies = { "rafamadriz/friendly-snippets" },
		version = false,
		opts = {},
	},
	{
		"nvim-mini/mini.diff",
		event = "VeryLazy",
		keys = {
			{
				"<leader>go",
				function()
					require("mini.diff").toggle_overlay(0)
				end,
				desc = "Toggle mini.diff overlay",
			},
		},
		opts = {
			view = {
				style = "sign",
				signs = {
					add = "▎",
					change = "▎",
					delete = "",
				},
			},
		},
	},

	{
		"nvim-mini/mini.hipatterns",
		version = false, -- always use the latest
		event = "BufReadPre",
		opts = function()
			local hi = require("mini.hipatterns")

			local M = {
				hl = {},
				-- Tailwind color map from LazyVim's implementation
				colors = {
					slate = {
						[50] = "f8fafc",
						[100] = "f1f5f9",
						[200] = "e2e8f0",
						[300] = "cbd5e1",
						[400] = "94a3b8",
						[500] = "64748b",
						[600] = "475569",
						[700] = "334155",
						[800] = "1e293b",
						[900] = "0f172a",
						[950] = "020617",
					},
					gray = {
						[50] = "f9fafb",
						[100] = "f3f4f6",
						[200] = "e5e7eb",
						[300] = "d1d5db",
						[400] = "9ca3af",
						[500] = "6b7280",
						[600] = "4b5563",
						[700] = "374151",
						[800] = "1f2937",
						[900] = "111827",
						[950] = "030712",
					},
					-- add more tailwind palettes if you want
				},
			}

			local opts = {
				tailwind = {
					enabled = true,
					ft = {
						"astro",
						"css",
						"heex",
						"html",
						"html-eex",
						"javascript",
						"javascriptreact",
						"rust",
						"svelte",
						"typescript",
						"typescriptreact",
						"vue",
					},
					style = "full", -- "full" | "compact"
				},
				highlighters = {
					hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
					shorthand = {
						pattern = "()#%x%x%x()%f[^%x%w]",
						group = function(_, _, data)
							local match = data.full_match
							local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
							local hex_color = "#" .. r .. r .. g .. g .. b .. b
							return hi.compute_hex_color_group(hex_color, "bg")
						end,
						extmark_opts = { priority = 2000 },
					},
				},
			}

			if type(opts.tailwind) == "table" and opts.tailwind.enabled then
				vim.api.nvim_create_autocmd("ColorScheme", {
					callback = function()
						M.hl = {}
					end,
				})

				opts.highlighters.tailwind = {
					pattern = function()
						if not vim.tbl_contains(opts.tailwind.ft, vim.bo.filetype) then
							return
						end
						if opts.tailwind.style == "full" then
							return "%f[%w:-]()[%w:-]+%-[a-z%-]+%-%d+()%f[^%w:-]"
						elseif opts.tailwind.style == "compact" then
							return "%f[%w:-][%w:-]+%-()[a-z%-]+%-%d+()%f[^%w:-]"
						end
					end,
					group = function(_, _, m)
						local match = m.full_match
						local color, shade = match:match("[%w-]+%-([a-z%-]+)%-(%d+)")
						shade = tonumber(shade)
						local bg = vim.tbl_get(M.colors, color, shade)
						if bg then
							local hl = "MiniHipatternsTailwind" .. color .. shade
							if not M.hl[hl] then
								M.hl[hl] = true
								local bg_shade = shade == 500 and 950 or shade < 500 and 900 or 100
								local fg = vim.tbl_get(M.colors, color, bg_shade)
								vim.api.nvim_set_hl(0, hl, { bg = "#" .. bg, fg = "#" .. fg })
							end
							return hl
						end
					end,
					extmark_opts = { priority = 2000 },
				}
			end

			return opts
		end,
		config = function(_, opts)
			require("mini.hipatterns").setup(opts)
		end,
	},
	{
		"nvim-mini/mini.ai",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({ -- code block
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
					d = { "%f[%d]%d+" }, -- digits
					e = { -- Word with case
						{
							"%u[%l%d]+%f[^%l%d]",
							"%f[%S][%l%d]+%f[^%l%d]",
							"%f[%P][%l%d]+%f[^%l%d]",
							"^[%l%d]+%f[^%l%d]",
						},
						"^().*()$",
					},
					u = ai.gen_spec.function_call(), -- u for "Usage"
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
				},
			}
		end,
	},
	{
		"nvim-mini/mini.starter",
		opts = function()
			vim.api.nvim_create_user_command("Dashboard", function()
				require("mini.starter").open()
			end, {})

			local pad = string.rep(" ", 2)
			local new_section = function(name, action, section)
				return { name = name, action = action, section = section }
			end

			local starter = require("mini.starter")

			return {
				evaluate_single = true,
				items = {
					new_section("Projects", ":ProjectFzf", "FzfLua"),
					new_section("Find file", ":FzfLua files", "FzfLua"),
					new_section("Config", ":FzfLua files cwd=" .. vim.fn.stdpath("config"), "Config"),
					new_section("Lazy", ":Lazy", "Config"),
					new_section("Mason", ":Mason", "Config"),
					starter.sections.recent_files(10, true),
					starter.sections.builtin_actions(),
				},
				content_hooks = {
					starter.gen_hook.adding_bullet(pad .. "░ ", false),
					starter.gen_hook.aligning("center", "center"),
				},
				footer = os.date(" %A, %d %B %Y"),
			}
		end,
	},
	{
		"nvim-mini/mini.diff",
		event = "VeryLazy",
		keys = {
			{
				"<leader>go",
				function()
					require("mini.diff").toggle_overlay(0)
				end,
				desc = "Toggle mini.diff overlay",
			},
		},
		opts = {
			view = {
				style = "sign",
				signs = {
					add = "▎",
					change = "▎",
					delete = "",
				},
			},
		},
	},
	{
		"nvim-mini/mini.indentscope",
		version = false,
		event = "BufEnter",
		opts = {
			-- symbol = "▏",
			symbol = "│",
			options = { try_as_border = true },
			draw = {
				-- Delay (in ms) between event and start of drawing scope indicator
				delay = 10,
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"Trouble",
					"alpha",
					"dashboard",
					"fzf",
					"help",
					"lazy",
					"mason",
					"neo-tree",
					"notify",
					"snacks_dashboard",
					"snacks_notif",
					"snacks_terminal",
					"snacks_win",
					"toggleterm",
					"trouble",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "SnacksDashboardOpened",
				callback = function(data)
					vim.b[data.buf].miniindentscope_disable = true
				end,
			})
		end,
	},
}
