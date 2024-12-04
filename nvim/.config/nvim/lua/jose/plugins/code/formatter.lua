return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				lua = { "stylua" },
				python = { "isort", "black" },
				php = { "prettier", "pretty-php" },
				-- java = { "google-java-format" },
			},
			format_after_save = {
				lsp_fallback = true,
				async = true,
				timeout_ms = 1000,
			},
		})

		-- conform.formatters.prettier = {
		-- 	prepend_args = function()
		-- 		return { "--use-tabs", "true", "--tab-width", "4" }
		-- 	end,
		-- }

		conform.formatters.google_java_format = {
			prepend_args = function()
				print("Applying google-java-format with --aosp")
				return { "--aosp" }
			end,
			timeout_ms = 3000,
		}

		vim.keymap.set({ "n", "v" }, "<leader>fa", function()
			conform.format({
				async = false,
				timeout_ms = 500,
				lsp_format = "fallback",
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
