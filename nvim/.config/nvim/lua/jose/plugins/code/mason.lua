return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		require("mason").setup()

		require("mason-lspconfig").setup({
			automatic_installation = true,
			ensure_installed = {
				"cssls",
				"eslint",
				"html",
				"jsonls",
				"ts_ls",
				"pyright",
				"tailwindcss",
				"emmet_language_server",
				"intelephense",
			},
		})

		require("mason-tool-installer").setup({
			ensure_installed = {
				"prettierd",
				"prettierd",
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint",
				"eslint_d",
				"google-java-format",
			},
		})
	end,
}
