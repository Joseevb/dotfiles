return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "folke/neodev.nvim", opts = {} },
		"folke/neoconf.nvim",
	},

	config = function()
		-- 🛠️ Load plugins
		require("neoconf").setup({})
		require("neodev").setup({})

		-- 🚀 LSP Setup
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")

		-- 🌍 Define default capabilities
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		-- 🔧 Default `on_attach` function for all LSPs
		local function on_attach(client, bufnr)
			local opts = { noremap = true, silent = true, buffer = bufnr }
			local keymap = vim.keymap.set

			keymap("n", "gD", vim.lsp.buf.declaration, opts)
			keymap("n", "gd", vim.lsp.buf.definition, opts)
			keymap("n", "gr", vim.lsp.buf.references, opts)
			keymap("n", "K", vim.lsp.buf.hover, opts)
			keymap("n", "<C-k>", vim.lsp.buf.signature_help, opts)
			keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
			keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
			keymap("n", "<leader>f", function()
				vim.lsp.buf.format({ async = true })
			end, opts)

			-- Autoformat before save (only if supported)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format()
					end,
				})
			end
		end

		-- 🛠️ Ensure Mason installs required LSPs
		mason_lspconfig.setup({
			ensure_installed = {
				"lua_ls",
				"ts_ls",
				"html",
				"cssls",
				"eslint",
				"jsonls",
				"bashls",
				"dockerls",
				"yamlls",
				"pyright",
				"tailwindcss",
				"graphql",
				"intelephense",
				"clangd",
				"biome",
			},
			automatic_installation = true,
		})

		-- 🚀 Configure each installed LSP
		mason_lspconfig.setup_handlers({
			function(server_name)
				-- 🔥 Prevent `jdtls` from being handled here (managed separately)
				if server_name ~= "jdtls" then
					lspconfig[server_name].setup({
						on_attach = on_attach,
						capabilities = capabilities,
					})
				end
			end,

			-- 🔧 Custom LSP configurations (if needed)
			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					on_attach = on_attach,
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = { library = vim.api.nvim_get_runtime_file("", true) },
							telemetry = { enable = false },
						},
					},
				})
			end,

			["emmet_language_server"] = function()
				lspconfig.emmet_language_server.setup({
					on_attach = on_attach,
					capabilities = capabilities,
					cmd = { "emmet-language-server", "--stdio" },
					filetypes = {
						"html",
						"css",
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
						"php",
					},
					init_options = {
						preferences = {
							includeLanguages = {
								html = "html",
								javascript = "javascriptreact",
								css = "css",
							},
						},
					},
				})
			end,
		})
	end,
}
