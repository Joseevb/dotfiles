-- lua/jose/plugins/code/lsp/lspconfig.lua

local blink_cmp = require("blink.cmp")

-- Capabilities: Start with default LSP capabilities and enhance with nvim-cmp.
local capabilities = blink_cmp.get_lsp_capabilities()

local lsp_handlers = require("jose.lsp.handlers")
local on_attach_base = lsp_handlers.on_attach_base
local map_lsp_key = lsp_handlers.map_lsp_key

-- Capabilities: Configure folding range
-- Removed duplicate definition
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- Global Diagnostic UI Configuration: Defines how diagnostics look across all LSPs.
-- Could potentially be moved to a general UI configuration file if preferred.
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl_group = "DiagnosticSign" .. type
	vim.fn.sign_define("LspDiagnostics" .. type, { text = icon, texthl = hl_group, numhl = hl_group })
end

-- Use vim.diagnostic.config directly
vim.diagnostic.config({
	virtual_text = { spacing = 4, severity_sort = true, source = "if_many" },
	signs = { active = signs }, -- Use defined signs
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { source = "if_many", border = "rounded" },
})

-- Enhanced on_attach: For TypeScript/JavaScript with Telescope and specific actions.
local on_attach_ts = function(client, bufnr)
	on_attach_base(client, bufnr) -- Include base mappings

	local telescope_ok, telescope = pcall(require, "telescope.builtin")

	if telescope_ok then -- Add Telescope mappings if available
		map_lsp_key(bufnr, "n", "gi", telescope.lsp_implementations, "Go to Implementation (Telescope)")
		map_lsp_key(bufnr, "n", "gr", telescope.lsp_references, "Go to References (Telescope)")
	end

	-- TS/JS specific code actions
	-- Note: <leader>co and <leader>cm map to the same action (Organize Imports)
	map_lsp_key(bufnr, "n", "<leader>co", function()
		vim.lsp.buf.code_action({
			context = {
				only = { "source.organizeImports" },
				diagnostics = vim.diagnostic.get(0),
			},
			apply = true,
		})
	end, "Organize Imports")
	map_lsp_key(bufnr, "n", "<leader>cm", function()
		vim.lsp.buf.code_action({
			context = {
				only = { "source.organizeImports" },
				diagnostics = vim.diagnostic.get(0),
			},
			apply = true,
		})
	end, "Organize Imports")
	map_lsp_key(bufnr, "n", "<leader>cq", function()
		vim.lsp.buf.code_action({
			context = {
				only = { "quickfix" },
				diagnostics = vim.diagnostic.get(0),
			},
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

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		{
			"williamboman/mason-lspconfig.nvim",
			opts = function(_, parent_opts)
				-- Ensure parent_opts is a table to avoid errors
				parent_opts = parent_opts or {}

				-- Safely extract server names or default to an empty table
				local servers = parent_opts.servers or {}
				local ensure_installed = servers

				local opts = {
					ensure_installed = ensure_installed,
					automatic_installation = true,
					automatic_enable = {
						exclude = { "jdtls" },
					},
				}
				return opts
			end,
		},
		"saghen/blink.cmp",
		{ "folke/neodev.nvim", opts = {} },
		-- "folke/neoconf.nvim", -- Assuming neoconf is set up elsewhere
		"nvim-lua/plenary.nvim",
		"stevearc/dressing.nvim", -- Optional: Better UI for vim.ui.select
	},

	opts = {
		servers = {
			-- Define your servers and their specific configurations here
			lua_ls = {
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						diagnostics = { globals = { "vim" } },
						telemetry = { enable = false },
					},
				},
			},
			ts_ls = {
				settings = {
					typescript = { preferences = { importModuleSpecifierPreference = "relative" } },
					javascript = { preferences = { importModuleSpecifierPreference = "relative" } },
				},
			},
			eslint = {}, -- Basic setup, will inherit base on_attach
			emmet_language_server = {
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
				init_options = { preferences = { includeLanguages = { javascript = "javascriptreact" } } },
			},
			tailwindcss = {
				settings = {
					tailwindcss = {
						validate = true,
						-- Uncomment and configure linting rules as needed
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
			},
			bashls = {},
			dockerls = {},
			yamlls = {},
			pyright = {},
			intelephense = {},
			clangd = {},
			biome = {},
			html = {},
			cssls = {},
			jsonls = {},
			graphql = {},
			rust_analyzer = {},
			-- Add any other servers you need here
		},
		setup = {
			ts_ls = {
				on_attach = on_attach_ts,
			},
		},
		-- Add any other global lspconfig options here
		-- For example:
		diagnostic = {
			virtual_text = { spacing = 4, severity_sort = true, source = "if_many" },
			signs = { active = {} }, -- Signs configured in config function
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = { source = "if_many", border = "rounded" },
		},
	},
	config = function(_, opts)
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig") -- Need mason_lspconfig for setup_handlers

		-- Configure mason-lspconfig's setup_handlers
		-- This tells mason-lspconfig how to set up each server it manages *after* installation.
		mason_lspconfig.setup({
			-- Default handler for servers not explicitly listed below
			handlers = function(server_name)
				-- Check if server is defined in opts.servers table
				local server_opts = opts.servers[server_name]
				if not server_opts then
					-- Server not defined in opts.servers, skip setup via this handler
					-- (Mason might still handle installation, but lspconfig setup is skipped here)
					return
				end

				local custom_setup = opts.setup and opts.setup[server_name] or {} -- Check for specific overrides in opts.setup

				local on_attach = custom_setup.on_attach or on_attach_base

				-- Get capabilities, merging base capabilities with specific ones if any (though none defined in custom_setup here)
				-- Always start with default capabilities and merge in custom/cmp ones
				local server_capabilities = vim.tbl.deep_extend(
					"force",
					vim.lsp.protocol.make_client_capabilities(),
					capabilities,
					custom_setup.capabilities or {}
				)

				server_opts.capabilities = server_capabilities
				server_opts.on_attach = on_attach

				lspconfig[server_name].setup(server_opts)
			end,

			-- Explicit handlers for servers that need special logic not covered by the default handler
			-- Note: The ts_ls handler in the original code was redundant because the default handler + opts.setup.ts_ls covers it.
			-- Removing the redundant explicit ts_ls handler.
			-- Example: Add specific handlers here if a server needs unique initialization or complex setup logic.
			-- ["eslint"] = function() lspconfig.eslint.setup({ on_attach = on_attach_base, capabilities = capabilities }) end,
		})

		-- Apply the global diagnostic configuration again here if needed, though
		-- the direct call before the return statement should handle it.
		-- vim.diagnostic.config(opts.diagnostic)
	end,
}
