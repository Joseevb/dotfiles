local blink_cmp = require("blink.cmp")

-- Capabilities: Start with default LSP capabilities and enhance with nvim-cmp.
local capabilities = blink_cmp.get_lsp_capabilities()

-- Capabilities: Configure folding range
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- Define your servers and their specific configurations here
local servers = {
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
		keys = {
			{
				"<leader>rn",
				function()
					vim.lsp.buf.execute_command({
						command = "_typescript.organizeImports",
						arguments = { vim.fn.expand("%:p") },
					})
				end,
				desc = "Rename",
				on_attach = function(_, bufnr)
					local bufmap = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
					end

					bufmap("n", "<leader>co", function()
						vim.lsp.buf.execute_command({
							command = "_typescript.organizeImports",
							arguments = { vim.fn.expand("%:p") },
						})
					end, "Organize Imports")
				end,
			},
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
}

return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	lazy = false,
	config = function()
		print("Mason: Starting configuration...")
		require("mason").setup()

		require("mason-tool-installer").setup({
			ensure_installed = {
				"prettierd",
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint",
				"eslint_d",
				"google-java-format",
			},
		})

		local mason_lspconfig = require("mason-lspconfig")

		-- Safely extract server names for ensure_installed
		local ensure_installed_lsp_servers = {}
		if servers then
			for server_name, config in pairs(servers) do
				table.insert(ensure_installed_lsp_servers, server_name)
				vim.lsp.config(server_name, config)
				vim.lsp.enable(server_name)
			end
		end

		mason_lspconfig.setup({
			ensure_installed = ensure_installed_lsp_servers,
			automatic_enable = {
				exclude = { "jdtls" },
			},
		})
	end,
	keys = {
		{
			"<leader>rn",
			function()
				vim.lsp.buf.rename()
			end,
			desc = "Rename",
		},
		{
			"<leader>ca",
			function()
				vim.lsp.buf.code_action()
			end,
			desc = "Code Action",
		},
		{
			"<leader>cA",
			function()
				vim.lsp.buf.code_action({
					context = {
						only = {
							"source",
						},
						diagnostics = {},
					},
				})
			end,
			desc = "Source Action",
		},
		{
			"<leader>sd",
			function()
				vim.diagnostic.open_float()
			end,
			desc = "Show Line Diagnostics",
		},
		{
			"gr",
			function()
				vim.lsp.buf.references()
			end,
			desc = "Go to References",
		},
		{
			"<C-k>",
			function()
				vim.lsp.buf.signature_help()
			end,
			desc = "Signature Help",
		},
	},
}
