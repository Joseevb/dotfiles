return {
	"saghen/blink.cmp",
	-- optional: provides snippets for the snippet source
	dependencies = { "rafamadriz/friendly-snippets" },

	-- use a release tag to download pre-built binaries
	version = "1.*",
	-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
	-- build = 'cargo build --release',
	-- If you use nix, you can build from source using latest nightly rust with:
	-- build = 'nix run .#build-plugin',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
		-- 'super-tab' for mappings similar to vscode (tab to accept)
		-- 'enter' for enter to accept
		-- 'none' for no mappings
		--
		-- All presets have the following mappings:
		-- C-space: Open menu or open docs if already open
		-- C-n/C-p or Up/Down: Select next/previous item
		-- C-e: Hide menu
		-- C-k: Toggle signature help (if signature.enabled = true)
		--
		-- See :h blink-cmp-config-keymap for defining your own keymap
		keymap = { preset = "enter" },
		signature = {
			enabled = true,
			window = {
				show_documentation = true,
				border = { "rounded", "double", "shadow", "padded" },
			},
		},

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
			border = { "rounded", "double", "shadow", "padded" },
		},

		-- (Default) Only show the documentation popup when manually triggered
		completion = {
			list = {
				selection = {
					auto_insert = true,
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = {
					border = "rounded",
				},
			},
			menu = {
				border = "rounded",
				draw = { gap = 2 },
			},
			ghost_text = {
				enabled = true,
			},
			trigger = {
				show_on_trigger_characters = true,
			},
		},

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = { "lsp", "snippets", "buffer", "path" },
		},

		-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
		-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- See the fuzzy documentation for more information
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
-- return {
-- 	"hrsh7th/nvim-cmp",
-- 	event = "InsertEnter",
-- 	dependencies = {
-- 		"hrsh7th/cmp-buffer", -- source for text in buffer
-- 		"hrsh7th/cmp-path", -- source for file system paths
-- 		{
-- 			"L3MON4D3/LuaSnip",
-- 			version = "v2.*",
-- 			-- install jsregexp (optional!).
-- 			build = "make install_jsregexp",
-- 		},
-- 		"saadparwaiz1/cmp_luasnip",
-- 		"rafamadriz/friendly-snippets",
-- 		"onsails/lspkind.nvim", -- vs-code like pictograms
-- 		"mlaursen/vim-react-snippets",
-- 	},
-- 	opts = function()
-- 		local cmp = require("cmp")
-- 		local lspkind = require("lspkind")
-- 		local luasnip = require("luasnip")
-- 		require("vim-react-snippets").lazy_load()
--
-- 		require("luasnip.loaders.from_vscode").lazy_load()
-- 		-- require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
-- 		require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
--
-- 		cmp.setup({
-- 			snippet = {
-- 				expand = function(args)
-- 					luasnip.lsp_expand(args.body)
-- 				end,
-- 			},
-- 			window = {
-- 				completion = cmp.config.window.bordered(),
-- 				documentation = cmp.config.window.bordered(),
-- 			},
-- 			experimental = {
-- 				ghost_text = true,
-- 			},
-- 			mapping = cmp.mapping.preset.insert({
-- 				-- ["<S-Tab>"] = cmp.mapping.select_prev_item(cmp_select),
-- 				-- ["<Tab>"] = cmp.mapping.select_next_item(cmp_select),
-- 				["<C-d>"] = cmp.mapping.scroll_docs(-4),
-- 				["<C-f>"] = cmp.mapping.scroll_docs(4),
-- 				["<C-Space>"] = cmp.mapping.complete(),
-- 				["<C-e>"] = cmp.mapping.close(),
-- 				["<CR>"] = cmp.mapping.confirm({
-- 					behavior = cmp.ConfirmBehavior.Replace,
-- 					select = true,
-- 				}),
-- 			}),
-- 			sources = cmp.config.sources({
-- 				{ name = "nvim_lsp" },
-- 				{ name = "luasnip" },
-- 				{ name = "buffer" },
-- 				{ name = "path" },
-- 			}),
-- 		})
--
-- 		vim.cmd([[
--       set completeopt=menuone,noinsert,noselect
--       highlight! default link CmpItemKind CmpItemMenuDefault
--     ]])
-- 	end,
-- }
