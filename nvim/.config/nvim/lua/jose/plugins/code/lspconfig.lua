-- lspconfig.lua (or wherever you configure LSPs)
return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },

	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "folke/neodev.nvim", opts = {} },
		"folke/neoconf.nvim",
	},
	config = function()
		require("neoconf").setup({})

		local mason_lspconfig = require("mason-lspconfig")
		local nvim_lsp = require("lspconfig")
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		-- Common on_attach function for all LSP servers
		local on_attach = function(_)
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					require("conform").format({ bufnr = args.buf })
				end,
			})
		end

		-- Automatically set up all LSP servers installed via Mason with common properties
		mason_lspconfig.setup_handlers({
			-- Default handler for all servers
			function(server_name)
				nvim_lsp[server_name].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end,
			-- Custom handler for specific server (e.g., emmet)
			["emmet_language_server"] = function()
				nvim_lsp["emmet_language_server"].setup({
					on_attach = on_attach,
					capabilities = capabilities,
					cmd = { "emmet-language-server", "--stdio" },
					filetypes = { "html", "css", "javascript", "javascriptreact", "php" },
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
