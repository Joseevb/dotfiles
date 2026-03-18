local jsInlayHints = {
	includeInlayParameterNameHints = "all",
	includeInlayParameterNameHintsWhenArgumentMatchesName = false,
	includeInlayFunctionParameterTypeHints = true,
	includeInlayVariableTypeHints = true,
	includeInlayVariableTypeHintsWhenTypeMatchesName = false,
	includeInlayPropertyDeclarationTypeHints = true,
	includeInlayFunctionLikeReturnTypeHints = true,
	includeInlayEnumMemberValueHints = true,
}

return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {},
		dependencies = { "mason-org/mason.nvim" },
	},
	{ "marilari88/twoslash-queries.nvim", opts = {} },
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "●",
				},
				severity_sort = true,
			},
			inlay_hints = { enabled = true },
			capabilities = {
				workspace = {
					fileOperations = {
						didRename = true,
						willRename = true,
					},
				},
			},
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							hint = { enable = true },
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
							},
						},
					},
				},
				emmet_ls = {
					filetypes = {
						"html",
						"css",
						"scss",
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
					},
					settings = {
						emmet = {
							includeLanguages = {
								typescriptreact = "javascriptreact",
							},
						},
					},
				},
				ts_ls = {
					on_attach = function(client, bufnr)
						require("twoslash-queries").attach(client, bufnr)
					end,
					settings = {
						typescript = {
							inlayHints = jsInlayHints,
						},
						javascript = { inlayHints = jsInlayHints },
					},
				},
			},
		},
		config = function(_, opts)
			vim.diagnostic.config(opts.diagnostics)

			for server, config in pairs(opts.servers) do
				vim.lsp.config(server, config)
			end
		end,
	},
	{
		"mfussenegger/nvim-jdtls",
		dependencies = {
			"mfussenegger/nvim-dap",
			"neovim/nvim-lspconfig",
			"nvim-neotest/neotest",
			"rcasia/neotest-java",
			"rcarriga/nvim-dap-ui",
		},
		ft = { "java", "class", "gradle" },
		config = function()
			local function on_attach(_, bufnr)
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, buffer = bufnr, desc = desc })
				end

				map("n", "<leader>sd", function()
					vim.diagnostic.open_float()
				end, "Show Line Diagnostics")

				-- JDTLS specific mappings
				map("n", "<leader>co", require("jdtls").organize_imports, "Organize Imports")

				map("n", "<leader>ev", function()
					require("jdtls").extract_variable({ visual = false })
				end, "Extract Variable")
				map("v", "<leader>ev", function()
					require("jdtls").extract_variable({ visual = true })
				end, "Extract Variable (Visual)")
				map("n", "<leader>ec", function()
					require("jdtls").extract_constant({ visual = false })
				end, "Extract Constant")
				map("v", "<leader>ec", function()
					require("jdtls").extract_constant({ visual = true })
				end, "Extract Constant (Visual)")

				map("n", "<leader>ei", require("jdtls").extract_interface, "Extract Interface")
				map("n", "<leader>ee", require("jdtls").extract_enum, "Extract Enum")
				map("n", "<leader>em", require("jdtls").extract_method, "Extract Method")
				map("n", "<leader>ef", require("jdtls").extract_field, "Extract Field")
				map("n", "<leader>el", require("jdtls").extract_local_variable, "Extract Local Variable")
				map("n", "<leader>ek", require("jdtls").extract_class, "Extract Class")
				map("n", "<leader>er", require("jdtls").rename_file, "Rename Compilation Unit")
				map("n", "<leader>om", require("jdtls").open_main_class, "Open Main Class")

				-- Other specific JDTLS commands
				map("n", "<leader>jD", require("jdtls").resolve_dependency, "Resolve Dependency")
				map("n", "<leader>jp", require("jdtls").project_root, "Show Project Root")

				-- only call DAP after client is attached
				require("jdtls.dap").setup_dap_main_class_configs()
				map("n", "<leader>dt", require("jdtls").test_class, "Run test class")
				map("n", "<leader>dn", require("jdtls").test_nearest_method, "Run test method")
			end
			require("jdtls").on_attach = on_attach
		end,
	},
	{
		"JavaHello/spring-boot.nvim",
		ft = "java",
		dependencies = {
			"mfussenegger/nvim-jdtls",
			"ibhagwan/fzf-lua",
		},
		opts = function()
			local mason_path = vim.fn.expand("$MASON") .. "/packages"

			return {
				ls_path = mason_path
					.. "/vscode-spring-boot-tools/extension/language-server/spring-boot-language-server-1.63.0-SNAPSHOT-exec.jar",
				jdtls_name = "jdtls",
				log_file = vim.fn.stdpath("cache") .. "/spring-boot.log",
			}
		end,
	},

	{
		"jinzhongjia/LspUI.nvim",
		branch = "main",
		enabled = false,
		opts = {
			prompt = {
				border = true,
				borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
			},

			-- Code Action configuration
			code_action = {
				enable = true,
				command_enable = true,
				gitsigns = false,
				extend_gitsigns = false,
				ui = {
					title = "Code Action",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "q",
					exec = "<CR>",
				},
			},

			-- Hover configuration
			hover = {
				enable = true,
				command_enable = true,
				ui = {
					title = "Hover",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "q",
				},
			},

			-- Rename configuration
			rename = {
				enable = true,
				command_enable = true,
				auto_save = false,
				ui = {
					title = "Rename",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "<C-c>",
					exec = "<CR>",
				},
			},

			-- Diagnostic configuration
			diagnostic = {
				enable = true,
				command_enable = true,
				ui = {
					title = "Diagnostic",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "q",
					exec = "<CR>",
				},
			},

			-- Definition configuration
			definition = {
				enable = true,
				command_enable = true,
				ui = {
					title = "Definition",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "q",
					exec = "<CR>",
					vsplit = "v",
					split = "s",
					tabe = "t",
				},
			},

			-- Reference configuration
			reference = {
				enable = true,
				command_enable = true,
				ui = {
					title = "Reference",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "q",
					exec = "<CR>",
					vsplit = "v",
					split = "s",
					tabe = "t",
				},
			},

			-- Implementation configuration
			implementation = {
				enable = true,
				command_enable = true,
				ui = {
					title = "Implementation",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "q",
					exec = "<CR>",
					vsplit = "v",
					split = "s",
					tabe = "t",
				},
			},

			-- Type Definition configuration
			type_definition = {
				enable = true,
				command_enable = true,
				ui = {
					title = "Type Definition",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "q",
					exec = "<CR>",
					vsplit = "v",
					split = "s",
					tabe = "t",
				},
			},

			-- Declaration configuration
			declaration = {
				enable = true,
				command_enable = true,
				ui = {
					title = "Declaration",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "q",
					exec = "<CR>",
					vsplit = "v",
					split = "s",
					tabe = "t",
				},
			},

			-- Call Hierarchy configuration
			call_hierarchy = {
				enable = true,
				command_enable = true,
				ui = {
					title = "Call Hierarchy",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "q",
					exec = "<CR>",
					expand = "o",
					jump = "e",
					vsplit = "v",
					split = "s",
					tabe = "t",
				},
			},

			-- Lightbulb configuration
			lightbulb = {
				enable = true,
				command_enable = true,
				icon = "💡",
				action_kind = {
					QuickFix = "🔧",
					Refactor = "♻️",
					RefactorExtract = "📤",
					RefactorInline = "📥",
					RefactorRewrite = "✏️",
					Source = "📄",
					SourceOrganizeImports = "📦",
				},
			},

			-- Inlay Hint configuration
			inlay_hint = {
				enable = true,
				command_enable = true,
			},

			-- Signature Help configuration
			signature = {
				enable = true,
				command_enable = true,
				ui = {
					title = "Signature Help",
					border = "rounded",
					winblend = 0,
				},
				keys = {
					quit = "q",
				},
			},
		},
	},

	{
		"MysticalDevil/inlay-hints.nvim",
		event = "LspAttach",
		dependencies = { "neovim/nvim-lspconfig" },
		opts = {},
	},

	{
		"chrisgrieser/nvim-lsp-endhints",
		event = "LspAttach",
		opts = {}, -- required, even if empty
	},
}
