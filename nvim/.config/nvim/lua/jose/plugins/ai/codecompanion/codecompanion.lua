local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

vim.api.nvim_create_autocmd({ "User" }, {
	pattern = "CodeCompanionRequest*",
	group = group,
	callback = function(request)
		if request.match == "CodeCompanionRequestStarted" then
			print(vim.inspect(request.data))
		end
	end,
})

return {
	"olimorris/codecompanion.nvim",
	opts = {
		strategies = {
			chat = {
				adapter = "gemini",
				keymaps = {
					close = {
						modes = {
							n = "<C-c>",
							i = "<C-A-c>",
						},
						index = 4,
						callback = "keymaps.close",
						description = "Close Chat",
					},
				},
			},
			inline = {
				adapter = "gemini",
			},
			cmd = {
				adapter = "gemini",
			},
			tools = {
				opts = {
					auto_submit_errors = true,
					auto_submit_success = true,
				},
			},
		},

		send = {
			callback = function(chat)
				vim.cmd("stopinsert")
				chat:submit()
				chat:add_buf_message({ role = "llm", content = "" })
			end,
			index = 1,
			description = "Send",
		},

		extensions = {
			history = {
				enabled = true,
				opts = {
					-- Keymap to open history from chat buffer (default: gh)
					keymap = "gh",
					-- Automatically generate titles for new chats
					auto_generate_title = true,
					---On exiting and entering neovim, loads the last chat on opening chat
					continue_last_chat = true,
					---When chat is cleared with `gx` delete the chat from history
					delete_on_clearing_chat = false,
					-- Picker interface ("telescope" or "snacks" or "default")
					picker = "snacks",
					---Enable detailed logging for history extension
					enable_logging = false,
					---Directory path to save the chats
					dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
					-- Save all chats by default
					auto_save = true,
					-- Keymap to save the current chat manually
					save_chat_keymap = "sc",
				},
			},

			mcphub = {
				callback = "mcphub.extensions.codecompanion",
				opts = {
					show_result_in_chat = true, -- Show mcp tool results in chat
					make_vars = true, -- Convert resources to #variables
					make_slash_commands = true, -- Add prompts as /slash commands
				},
			},

			vectorcode = {
				opts = {
					add_tool = true,
				},
			},
			extmarks = {
				enabled = true,
				callback = "jose.plugins.ai.codecompanion.plugins.extmarks", -- Module path for the extension
				opts = {
					-- Options for the extmarks module (copied from its default_opts)
					unique_line_sign_text = "",
					first_line_sign_text = "┌",
					last_line_sign_text = "└",
					extmark = {
						sign_hl_group = "DiagnosticWarn",
						sign_text = "│",
						priority = 1000,
					},
				},
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{
			-- Make sure to set this up properly if you have lazy=true
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "codecompanion" },
			},
			ft = { "markdown", "codecompanion" },
		},
		-- CodeCompanion Extensions
		"ravitemer/codecompanion-history.nvim",
	},
	config = function(_, opts)
		require("codecompanion").setup(opts)
		require("jose.plugins.ai.codecompanion.plugins.spinner"):init()
	end,
	keys = {
		{
			"<leader>ac",
			function()
				vim.cmd("CodeCompanionChat Toggle")
			end,
			desc = "Toggle CodeCompanion Chat",
		},
		{
			"<leader>ah",
			function()
				vim.cmd("CodeCompanionHistory")
			end,
			desc = "Toggle CodeCompanion Chat",
		},
	},
}
