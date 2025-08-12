return {
	"ravitemer/mcphub.nvim",
	build = "npm install -g mcp-hub@latest",
	opts = {
		builtin_tools = {
			edit_file = {
				parser = {
					track_issues = true, -- Track parsing issues for LLM feedback
					extract_inline_content = true, -- Handle content on marker lines
				},
				locator = {
					fuzzy_threshold = 0.8, -- Minimum similarity for fuzzy matches (0.0-1.0)
					enable_fuzzy_matching = true, -- Allow fuzzy matching when exact fails
				},
				ui = {
					go_to_origin_on_complete = true, -- Jump back to original file on completion
					keybindings = {
						accept = ".", -- Accept current change
						reject = ",", -- Reject current change
						next = "n", -- Next diff
						prev = "p", -- Previous diff
						accept_all = "ga", -- Accept all remaining changes
						reject_all = "gr", -- Reject all remaining changes
					},
				},
				feedback = {
					include_parser_feedback = true, -- Include parsing feedback for LLM
					include_locator_feedback = true, -- Include location feedback for LLM
					include_ui_summary = true, -- Include UI interaction summary
					ui = {
						include_session_summary = true, -- Include session summary in feedback
						include_final_diff = true, -- Include final diff in feedback
						send_diagnostics = true, -- Include diagnostics after editing
						wait_for_diagnostics = 500, -- Wait time for diagnostics (ms)
						diagnostic_severity = vim.diagnostic.severity.WARN, -- Min severity to include
					},
				},
			},
		},
	},
}
