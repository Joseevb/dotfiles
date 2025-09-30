return {
	"stevearc/conform.nvim",
	opts = {

		formatters_by_ft = {
			c = { "clang-format" },
			cpp = { "clang-format" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			xml = { "xmlformatter" },
			lua = { "stylua" },
			python = { "isort", "black" },
			php = { "prettier", "pretty-php" },
			java = { "google-java-format" },
		},
		formatters = {
			["google-java-format-aosp"] = {
				command = "google-java-format",
				args = { "--aosp", "-" },
			},
		},
		format_after_save = {
			lsp_fallback = true,
			async = true,
			timeout_ms = 1000,
		},
	},
}
