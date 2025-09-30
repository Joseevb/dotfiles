return {
	{ "nvim-mini/mini.tabline", version = false, opts = {} },
	{ "nvim-mini/mini-git", version = false, main = "mini.git", opts = {} },
	{ "nvim-mini/mini.statusline", version = false, opts = {} },
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
		recommended = true,
		desc = "Highlight colors in your code. Also includes Tailwind CSS support.",
		event = "BufEnter",
		opts = function()
			local hi = require("mini.hipatterns")
			return {
				-- custom LazyVim option to enable the tailwind integration
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
					-- full: the whole css class will be highlighted
					-- compact: only the color will be highlighted
					style = "full",
				},
				highlighters = {
					fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
					hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
					todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
					note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
					hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
					shorthand = {
						pattern = "()#%x%x%x()%f[^%x%w]",
						group = function(_, _, data)
							---@type string
							local match = data.full_match
							local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
							local hex_color = "#" .. r .. r .. g .. g .. b .. b

							return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
						end,
						extmark_opts = { priority = 2000 },
					},
				},
			}
		end,
		config = function(_, opts)
			if type(opts.tailwind) == "table" and opts.tailwind.enabled then
				-- reset hl groups when colorscheme changes
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
						---@type string
						local match = m.full_match
						---@type string, number
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
}
