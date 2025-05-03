-- lua/jose/plugins/code/formatter.lua
return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		log_level = vim.log.levels.WARN,
		notify_on_error = true,
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
			xml = { "prettierd", "prettier", stop_after_first = true },
			lua = { "stylua" },
			python = { "isort", "black" },
			php = { "prettier", "pretty-php" },
			java = { "google-java-format-aosp" },
		},
		formatters = {
			-- Copy your full formatters table here
			["google-java-format-aosp"] = {
				command = "google-java-format", -- Let conform find command
				-- Explicitly add "--aosp" AND "-" for stdin
				args = { "--aosp", "-" },
				-- We likely don't need stdin = true/false here as the "-" handles it
				-- require_cwd = false -- Might be needed if CWD issues arise, but try without first
			},
			google_java_format = {
				prepend_args = { "--aosp" },
				timeout_ms = 4000,
			},
			clang_format = {
				command = "clang-format",
				args = {
					"--style",
					"{IndentWidth: 4, TabWidth: 4, UseTab: Never}", -- Inline configuration for 4 spaces and no tabs
				},
				stdin = true,
			},
		},
		format_after_save = {
			lsp_fallback = true,
			async = true,
			timeout_ms = 1000,
		},
	},
	keys = {
		{
			"<leader>fm",
			function()
				require("conform").format({
					async = false,
					timeout_ms = 4000,
					lsp_format = "fallback",
				})
			end,
			desc = "Format file or range (conform)",
		},
	},
}
