return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "folke/neodev.nvim", opts = {} }, -- Let neodev handle its own setup via opts
		-- Potentially used for project-local settings (ensure configured elsewhere if needed)
		-- "folke/neoconf.nvim", -- Assuming neoconf is set up in its own plugin spec

		"nvim-lua/plenary.nvim",
	},

	config = function()
		-- Core Modules Required within this config
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local blink_cmp = require("blink.cmp")

		-- Capabilities: Start with default LSP capabilities and enhance with nvim-cmp.
		local capabilities = blink_cmp.get_lsp_capabilities()

		local lsp_handlers = require("jose.lsp.handlers")
		local on_attach_base = lsp_handlers.on_attach_base
		local map_lsp_key = lsp_handlers.map_lsp_key

		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}

		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}

		-- Global Diagnostic UI Configuration: Defines how diagnostics look across all LSPs.
		-- Could potentially be moved to a general UI configuration file if preferred.
		-- do -- Use a 'do' block for local scope
		local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
		for type, icon in pairs(signs) do
			local hl_group = "DiagnosticSign" .. type
			vim.fn.sign_define("LspDiagnostics" .. type, { text = icon, texthl = hl_group, numhl = hl_group })
		end

		vim.diagnostic.config({
			virtual_text = { spacing = 4, severity_sort = true, source = "if_many" },
			signs = {
				text = signs,
			},
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = { source = "if_many", border = "rounded" },
		})
		-- end

		-- -- Helper function to define keymaps within on_attach closures
		-- local map_lsp_key = function(bufnr, mode, lhs, rhs, desc)
		-- 	vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, buffer = bufnr, desc = "LSP: " .. desc })
		-- end
		--
		-- -- Base on_attach: Shared keymaps for most language servers.
		-- local on_attach_base = function(client, bufnr)
		-- 	-- defined in snacks.picker
		-- 	-- map_lsp_key(bufnr, "n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
		-- 	-- map_lsp_key(bufnr, "n", "gd", vim.lsp.buf.definition, "Go to Definition")
		-- 	-- map_lsp_key(bufnr, "n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
		-- 	-- map_lsp_key(bufnr, "n", "gr", vim.lsp.buf.references, "Go to References")
		-- 	-- map_lsp_key(bufnr, "n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
		-- 	map_lsp_key(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename")
		-- 	map_lsp_key(bufnr, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
		-- 	map_lsp_key(bufnr, "n", "K", function()
		-- 		local winid = require("ufo").peekFoldedLinesUnderCursor()
		-- 		if not winid then
		-- 			vim.lsp.buf.hover()
		-- 		end
		-- 	end, "Hover")
		--
		-- 	map_lsp_key(bufnr, "n", "<leader>sd", vim.diagnostic.open_float, "Show Line Diagnostics")
		-- 	-- Also useful: Navigate diagnostics
		-- 	map_lsp_key(bufnr, "n", "[d", function()
		-- 		vim.diagnostic.jump({ count = -1, float = true })
		-- 	end, "Go to Previous Diagnostic")
		-- 	map_lsp_key(bufnr, "n", "]d", function()
		-- 		vim.diagnostic.jump({ count = 1, float = true })
		-- 	end, "Go to Next Diagnostic")
		-- end

		-- Enhanced on_attach: For TypeScript/JavaScript with Telescope and specific actions.
		local on_attach_ts = function(client, bufnr)
			on_attach_base(client, bufnr) -- Include base mappings

			-- TS/JS specific code actions
			map_lsp_key(bufnr, "n", "<leader>co", function()
				vim.lsp.buf.code_action({
					context = {
						only = {
							"source.organizeImports",
						},
						diagnostics = vim.diagnostic.get(0),
					},
					apply = true,
				})
			end, "Organize Imports")
			map_lsp_key(bufnr, "n", "<leader>cm", function()
				vim.lsp.buf.code_action({
					context = {
						only = { "source.fixAll", "source.organizeImports" },
						diagnostics = vim.diagnostic.get(0),
					},
					apply = true,
				})
			end, "Add Missing Imports")
			map_lsp_key(bufnr, "n", "<leader>cq", function()
				vim.lsp.buf.code_action({
					context = { only = { "quickfix" }, diagnostics = vim.diagnostic.get(0) },
					apply = true,
				})
			end, "Quick Fix")

			-- Go to Source Definition (ts_ls specific)
			map_lsp_key(bufnr, "n", "gS", function()
				client.request("textDocument/executeCommand", {
					command = "_typescript.goToSourceDefinition",
					arguments = { vim.uri_from_bufnr(bufnr), vim.lsp.util.make_position_params(0, "utf-8") },
				}, function(err, result)
					-- Simplified error/result handling
					if err then
						vim.notify("Error finding source: " .. vim.inspect(err), vim.log.levels.ERROR)
						return
					end
					if result and result[1] then
						vim.lsp.util.show_document(result[1], "utf-8", { focus = true })
					else
						vim.notify("Source definition not found.", vim.log.levels.INFO)
					end
				end, bufnr)
			end, "Go to Source Definition")
		end

		-- Mason-LSPConfig Integration: Handles installation of listed servers.
		mason_lspconfig.setup({
			ensure_installed = {
				"lua_ls",
				"ts_ls",
				"html",
				"cssls",
				"jsonls",
				"bashls",
				"dockerls",
				"yamlls",
				"pyright",
				"tailwindcss",
				"graphql",
				"intelephense",
				"clangd",
				"eslint",
				"biome",
				"jdtls",
				-- Specific handler for eslint
				["eslint"] = function()
					lspconfig.eslint.setup({
						on_attach = on_attach_base, -- Base keymaps are sufficient
						capabilities = capabilities,
					})
				end,

				-- Specific handler for biome
				["biome"] = function()
					lspconfig.biome.setup({
						on_attach = on_attach_base, -- Base keymaps
						capabilities = capabilities,
					})
				end,
				-- Add/Remove servers as needed
			},
			automatic_installation = true,
		})

		-- Mason-LSPConfig Handlers: Configure individual servers after installation.
		-- This loop ensures the correct 'on_attach' and capabilities are passed
		-- to each server's specific lspconfig setup function.
		mason_lspconfig.setup_handlers({
			-- Default handler for most servers
			function(server_name)
				if server_name == "jdtls" then
					return
				end -- Skip jdtls (handled elsewhere)

				lspconfig[server_name].setup({
					on_attach = on_attach_base, -- Use base keymaps
					capabilities = capabilities, -- Use shared capabilities
				})
			end,

			-- Specific handler for ts_ls
			["ts_ls"] = function()
				lspconfig.ts_ls.setup({
					on_attach = on_attach_ts, -- Use enhanced keymaps
					capabilities = capabilities,
					settings = { -- Optional: Example settings
						-- typescript = { preferences = { importModuleSpecifierPreference = "non-relative" } }
						typescript = { preferences = { importModuleSpecifierPreference = "relative" } },
					},
				})
			end,

			-- Specific handler for lua_ls (Neovim config development)
			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					on_attach = on_attach_base,
					capabilities = capabilities,
					settings = {
						Lua = {
							workspace = { checkThirdParty = false }, -- Avoid potential slowness/warnings
							diagnostics = { globals = { "vim" } },
							telemetry = { enable = false },
						},
					},
				})
			end,

			-- Specific handler for emmet
			["emmet_language_server"] = function()
				lspconfig.emmet_language_server.setup({
					on_attach = on_attach_base,
					capabilities = capabilities,
					filetypes = { -- Ensure all relevant types are listed
						"html",
						"css",
						"scss",
						"less",
						"sass", -- Styles
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact", -- JS/TS/React
						"vue",
						"svelte",
						"astro",
						"php",
						"twig", -- Frameworks/Templating
						"xml",
						"xsl", -- XML related
					},
					-- init_options from your original config:
					init_options = { preferences = { includeLanguages = { javascript = "javascriptreact" } } },
				})
			end,

			["tailwindcss"] = function()
				lspconfig.tailwindcss.setup({
					on_attach = on_attach_base,
					capabilities = capabilities,
					settings = {
						tailwindcss = {
							validate = true,
							-- lint = {
							-- 	cssConflict = "warning",
							-- 	invalidApply = "error",
							-- 	invalidConfigPath = "error",
							-- 	invalidScreen = "error",
							-- 	invalidTailwindDirective = "error",
							-- 	invalidVariant = "error",
							-- 	recommendedVariantOrder = "error",
							-- 	unrecognizedAtDirective = "error",
							-- 	unrecognizedScreen = "error",
							-- 	unrecognizedVariant = "error",
							-- },
						},
					},
				})
			end,

			-- Add more specific handlers here if a server needs unique
			-- 'on_attach' logic, capabilities, or settings.
		})

		-- Removed print statement for cleaner startup
		-- print("nvim-lspconfig setup complete.")
	end,

	-- No top-level 'keys' are defined here as mappings are buffer-local (on_attach).
	-- keys = {},
}
-- return {
-- 	"neovim/nvim-lspconfig",
-- 	event = { "BufReadPre", "BufNewFile" },
-- 	dependencies = {
-- 		"williamboman/mason.nvim",
-- 		"williamboman/mason-lspconfig.nvim",
-- 		"saghen/blink.cmp",
-- 		{ "folke/neodev.nvim", opts = {} },
-- 		-- "folke/neoconf.nvim", -- Assuming neoconf is set up elsewhere
-- 		"nvim-lua/plenary.nvim",
-- 		"stevearc/dressing.nvim", -- Optional: Better UI for vim.ui.select
-- 	},
--
-- 	opts = {
-- 		servers = {
-- 			-- Define your servers and their specific configurations here
-- 			lua_ls = {
-- 				settings = {
-- 					Lua = {
-- 						workspace = { checkThirdParty = false },
-- 						diagnostics = { globals = { "vim" } },
-- 						telemetry = { enable = false },
-- 					},
-- 				},
-- 			},
-- 			ts_ls = {
-- 				settings = {
-- 					typescript = { preferences = { importModuleSpecifierPreference = "relative" } },
-- 					javascript = { preferences = { importModuleSpecifierPreference = "relative" } },
-- 				},
-- 			},
-- 			eslint = {}, -- Basic setup, will inherit base on_attach
-- 			emmet_language_server = {
-- 				filetypes = { -- Ensure all relevant types are listed
-- 					"html",
-- 					"css",
-- 					"scss",
-- 					"less",
-- 					"sass", -- Styles
-- 					"javascript",
-- 					"javascriptreact",
-- 					"typescript",
-- 					"typescriptreact", -- JS/TS/React
-- 					"vue",
-- 					"svelte",
-- 					"astro",
-- 					"php",
-- 					"twig", -- Frameworks/Templating
-- 					"xml",
-- 					"xsl", -- XML related
-- 				},
-- 				init_options = { preferences = { includeLanguages = { javascript = "javascriptreact" } } },
-- 			},
-- 			tailwindcss = {
-- 				settings = {
-- 					tailwindcss = {
-- 						validate = true,
-- 						-- Uncomment and configure linting rules as needed
-- 						-- lint = {
-- 						-- 	cssConflict = "warning",
-- 						-- 	invalidApply = "error",
-- 						-- 	invalidConfigPath = "error",
-- 						-- 	invalidScreen = "error",
-- 						-- 	invalidTailwindDirective = "error",
-- 						-- 	invalidVariant = "error",
-- 						-- 	recommendedVariantOrder = "error",
-- 						-- 	unrecognizedAtDirective = "error",
-- 						-- 	unrecognizedScreen = "error",
-- 						-- 	unrecognizedVariant = "error",
-- 						-- },
-- 					},
-- 				},
-- 			},
-- 			bashls = {},
-- 			dockerls = {},
-- 			yamlls = {},
-- 			pyright = {},
-- 			intelephense = {},
-- 			clangd = {},
-- 			biome = {},
-- 			html = {},
-- 			cssls = {},
-- 			jsonls = {},
-- 			graphql = {},
-- 			rust_analyzer = {},
-- 			-- Add any other servers you need here
-- 		},
-- 		-- Add any other global lspconfig options here
-- 		-- For example:
-- 		diagnostic = {
-- 			virtual_text = { spacing = 4, severity_sort = true, source = "if_many" },
-- 			signs = { active = {} }, -- Signs configured in config function
-- 			underline = true,
-- 			update_in_insert = false,
-- 			severity_sort = true,
-- 			float = { source = "if_many", border = "rounded" },
-- 		},
-- 	},
--
-- 	config = function(_, opts)
-- 		local lspconfig = require("lspconfig")
-- 		local mason_lspconfig = require("mason-lspconfig")
-- 		local blink_cmp = require("blink.cmp")
--
-- 		-- Global Diagnostic UI Configuration: Defines how diagnostics look across all LSPs.
-- 		-- Could potentially be moved to a general UI configuration file if preferred.
-- 		local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
-- 		for type, icon in pairs(signs) do
-- 			local hl_group = "DiagnosticSign" .. type
-- 			vim.fn.sign_define("LspDiagnostics" .. type, { text = icon, texthl = hl_group, numhl = hl_group })
-- 		end
--
-- 		-- Use vim.diagnostic.config directly
-- 		vim.diagnostic.config({
-- 			virtual_text = { spacing = 4, severity_sort = true, source = "if_many" },
-- 			signs = { active = signs }, -- Use defined signs
-- 			underline = true,
-- 			update_in_insert = false,
-- 			severity_sort = true,
-- 			float = { source = "if_many", border = "rounded" },
-- 		})
--
-- 		-- Helper function to define keymaps within on_attach closures
-- 		local map_lsp_key = function(bufnr, mode, lhs, rhs, desc)
-- 			vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, buffer = bufnr, desc = "LSP: " .. desc })
-- 		end
--
-- 		-- Base on_attach: Shared keymaps for most language servers.
-- 		local on_attach_base = function(_, bufnr)
-- 			map_lsp_key(bufnr, "n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
-- 			map_lsp_key(bufnr, "n", "gd", vim.lsp.buf.definition, "Go to Definition")
-- 			map_lsp_key(bufnr, "n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
-- 			map_lsp_key(bufnr, "n", "gr", vim.lsp.buf.references, "Go to References")
-- 			-- vim.keymap.set("n", "K", vim.lsp.buf.hover, { silent = true, buffer = bufnr, desc = "LSP: Hover" }) -- Added K for hover
-- 			map_lsp_key(bufnr, "n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
-- 			map_lsp_key(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename")
-- 			map_lsp_key(bufnr, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
--
-- 			map_lsp_key(bufnr, "n", "<leader>DE", vim.diagnostic.open_float, "Show Line Diagnostics")
-- 			-- Also useful: Navigate diagnostics
-- 			map_lsp_key(bufnr, "n", "[d", function()
-- 				vim.diagnostic.jump({ count = -1, float = true })
-- 			end, "Go to Previous Diagnostic")
-- 			map_lsp_key(bufnr, "n", "]d", function()
-- 				vim.diagnostic.jump({ count = 1, float = true })
-- 			end, "Go to Next Diagnostic")
-- 		end
--
-- 		-- Enhanced on_attach: For TypeScript/JavaScript with Telescope and specific actions.
-- 		local on_attach_ts = function(client, bufnr)
-- 			on_attach_base(client, bufnr) -- Include base mappings
--
-- 			local telescope_ok, telescope = pcall(require, "telescope.builtin")
--
-- 			if telescope_ok then -- Add Telescope mappings if available
-- 				map_lsp_key(bufnr, "n", "gi", telescope.lsp_implementations, "Go to Implementation (Telescope)")
-- 				map_lsp_key(bufnr, "n", "gr", telescope.lsp_references, "Go to References (Telescope)")
-- 			end
--
-- 			-- TS/JS specific code actions
-- 			map_lsp_key(bufnr, "n", "<leader>co", function()
-- 				vim.lsp.buf.code_action({
-- 					context = {
-- 						only = { "source.organizeImports" },
-- 						diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
-- 					},
-- 					apply = true,
-- 				})
-- 			end, "Organize Imports")
-- 			map_lsp_key(bufnr, "n", "<leader>cm", function()
-- 				vim.lsp.buf.code_action({
-- 					context = {
-- 						only = { "source.organizeImports" },
-- 						diagnostics = vim.diagnostic.get(0),
-- 					},
-- 					apply = true,
-- 				})
-- 			end, "Organize Imports")
-- 			map_lsp_key(bufnr, "n", "<leader>cq", function()
-- 				vim.lsp.buf.code_action({
-- 					context = {
-- 						only = { "quickfix" },
-- 						diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
-- 					},
-- 					apply = true,
-- 				})
-- 			end, "Quick Fix")
--
-- 			-- Go to Source Definition (ts_ls specific)
-- 			map_lsp_key(bufnr, "n", "gS", function()
-- 				client.request("textDocument/executeCommand", {
-- 					command = "_typescript.goToSourceDefinition",
-- 					arguments = { vim.uri_from_bufnr(bufnr), vim.lsp.util.make_position_params(0, "utf-8") },
-- 				}, function(err, result)
-- 					-- Simplified error/result handling
-- 					if err then
-- 						vim.notify("Error finding source: " .. vim.inspect(err), vim.log.levels.ERROR)
-- 						return
-- 					end
-- 					if result and result[1] then
-- 						vim.lsp.util.show_document(result[1], "utf-8", { focus = true })
-- 					else
-- 						vim.notify("Source definition not found.", vim.log.levels.INFO)
-- 					end
-- 				end, bufnr)
-- 			end, "Go to Source Definition")
-- 		end
--
-- 		-- Configure mason-lspconfig to install servers listed in opts.servers
-- 		mason_lspconfig.setup({
-- 			ensure_installed = vim.tbl_keys(opts.servers), -- Install all servers defined in opts.servers
-- 			automatic_installation = true,
-- 		})
--
-- 		-- Set up servers using mason_lspconfig.setup_handlers
-- 		mason_lspconfig.setup_handlers({
-- 			-- Default handler for most servers
-- 			function(server_name)
-- 				local server_opts = opts.servers[server_name] or {} -- Get specific server options
--
-- 				-- Merge blink.cmp capabilities with any server-specific capabilities
-- 				server_opts.capabilities = blink_cmp.get_lsp_capabilities(server_opts.capabilities)
--
-- 				-- Assign the correct on_attach function
-- 				if server_name == "ts_ls" then
-- 					server_opts.on_attach = on_attach_ts
-- 				else
-- 					server_opts.on_attach = on_attach_base
-- 				end
--
-- 				lspconfig[server_name].setup(server_opts)
-- 			end,
--
-- 			-- You can add specific handlers here if needed, but the default handler
-- 			-- is configured to pull options from opts.servers and assign on_attach
-- 			-- based on server_name.
-- 			-- Example:
-- 			-- ["some_server"] = function()
-- 			--   lspconfig.some_server.setup({
-- 			--     on_attach = my_specific_on_attach_function,
-- 			--     capabilities = blink_cmp.get_lsp_capabilities(opts.servers.some_server.capabilities),
-- 			--     settings = opts.servers.some_server.settings,
-- 			--   })
-- 			-- end,
-- 		})
-- 	end,
-- }
